;;; claude-agent.el --- Zed-like Claude Code agent for Emacs -*- lexical-binding: t -*-

;;; Commentary:
;; Interactive Claude Code agent with streaming chat and diff review.
;; Requires the `claude` CLI tool (npm i -g @anthropic-ai/claude-code).

;;; Code:

(require 'json)
(require 'cl-lib)

;;;; ============================================================
;;;; Customization
;;;; ============================================================

(defgroup claude-agent nil
  "Claude Code agent integration."
  :group 'tools
  :prefix "claude-agent-")

(defcustom claude-agent-cli-path "claude"
  "Path to the claude CLI binary."
  :type 'string
  :group 'claude-agent)

(defcustom claude-agent-default-model "sonnet"
  "Default model alias or full name."
  :type 'string
  :group 'claude-agent)

(defcustom claude-agent-default-permission-mode "acceptEdits"
  "Default permission mode."
  :type '(choice (const "acceptEdits")
          (const "plan")
          (const "bypassPermissions")
          (const "default")
          (const "dontAsk"))
  :group 'claude-agent)

(defcustom claude-agent-panel-width 80
  "Width of the agent chat panel."
  :type 'integer
  :group 'claude-agent)

;;;; ============================================================
;;;; Faces
;;;; ============================================================

(defface claude-agent-prompt-face
  '((t (:foreground "#8ec07c" :weight bold)))
  "Face for user prompts."
  :group 'claude-agent)

(defface claude-agent-response-face
  '((t (:foreground "#a8a8a8")))
  "Face for assistant responses."
  :group 'claude-agent)

(defface claude-agent-tool-face
  '((t (:foreground "#458588")))
  "Face for tool use indicators."
  :group 'claude-agent)

(defface claude-agent-diff-added
  '((t (:foreground "#b8bb26" :background "#1e3c1f")))
  "Face for added lines in diff."
  :group 'claude-agent)

(defface claude-agent-diff-removed
  '((t (:foreground "#fb4934" :background "#3c1f1e")))
  "Face for removed lines in diff."
  :group 'claude-agent)

(defface claude-agent-diff-file-header
  '((t (:foreground "#fabd2f" :weight bold)))
  "Face for file headers in diff."
  :group 'claude-agent)

(defface claude-agent-diff-hunk-header
  '((t (:foreground "#458588")))
  "Face for hunk headers in diff."
  :group 'claude-agent)

(defface claude-agent-diff-context
  '((t (:foreground "#a8a8a8")))
  "Face for context lines in diff."
  :group 'claude-agent)

(defface claude-agent-separator
  '((t (:foreground "#585858")))
  "Face for separators."
  :group 'claude-agent)

(defface claude-agent-status-face
  '((t (:foreground "#b16286" :weight bold)))
  "Face for status messages."
  :group 'claude-agent)

(defface claude-agent-header-face
  '((t (:foreground "#fabd2f")))
  "Face for the mode/model header line."
  :group 'claude-agent)

;;;; ============================================================
;;;; State
;;;; ============================================================

(defvar claude-agent--process nil "The claude CLI process.")
(defvar claude-agent--session-id nil "Current session ID for multi-turn.")
(defvar claude-agent--partial-line "" "Accumulator for incomplete JSON lines.")
(defvar claude-agent--streaming-p nil "Non-nil when streaming a response.")
(defvar claude-agent--edits nil
  "List of captured edits. Each is a plist (:file :old :new :patch :status).")
(defvar claude-agent--current-tool nil "Name of currently executing tool.")
(defvar claude-agent--working-dir nil "Working directory for the agent.")
(defvar claude-agent--model nil "Current model (set per-session).")
(defvar claude-agent--permission-mode nil "Current permission mode (set per-session).")

;;;; ============================================================
;;;; Chat Buffer -- no read-only, uses simple markers
;;;; ============================================================

;; The chat buffer is plain text with faces. No read-only properties.
;; Layout:
;;   [header lines]
;;   [chat history -- responses inserted here at --output-end]
;;   --- separator ---
;;   > [user input area starts at --input-start]

(defvar claude-agent--output-end nil
  "Marker at end of chat output (before input separator).")
(defvar claude-agent--input-start nil
  "Marker at start of user input (after `> `).")

(defvar claude-agent-chat-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") #'claude-agent-send)
    (define-key map (kbd "C-c C-k") #'claude-agent-stop)
    map)
  "Keymap for claude-agent-chat-mode.")

(define-derived-mode claude-agent-chat-mode text-mode "Claude-Agent"
  "Major mode for Claude Code agent chat panel."
  (setq-local word-wrap t)
  (setq-local wrap-prefix "  ")
  (setq-local truncate-lines nil)
  (setq-local show-trailing-whitespace nil))

;;;; ============================================================
;;;; Diff Review Mode
;;;; ============================================================

(defvar claude-agent-diff-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "a") #'claude-agent-diff-accept-hunk)
    (define-key map (kbd "x") #'claude-agent-diff-reject-hunk)
    (define-key map (kbd "A") #'claude-agent-diff-accept-all)
    (define-key map (kbd "X") #'claude-agent-diff-reject-all)
    (define-key map (kbd "n") #'claude-agent-diff-next-hunk)
    (define-key map (kbd "p") #'claude-agent-diff-prev-hunk)
    (define-key map (kbd "q") #'claude-agent-diff-quit)
    (define-key map (kbd "RET") #'claude-agent-diff-visit-file)
    map)
  "Keymap for claude-agent-diff-mode.")

(define-derived-mode claude-agent-diff-mode special-mode "Claude-Diff"
  "Major mode for reviewing Claude agent file changes."
  (setq-local truncate-lines t)
  (setq-local show-trailing-whitespace nil)
  (setq-local buffer-read-only t))

;;;; ============================================================
;;;; Chat Panel UI
;;;; ============================================================

(defun claude-agent--get-chat-buffer ()
  "Get or create the chat buffer."
  (let ((buf (get-buffer-create "*claude-agent*")))
    (with-current-buffer buf
      (unless (eq major-mode 'claude-agent-chat-mode)
        (claude-agent-chat-mode)
        (claude-agent--init-chat-buffer)))
    buf))

(defun claude-agent--header-string ()
  "Build the header string showing current model and permission mode."
  (let ((model (or claude-agent--model claude-agent-default-model))
        (perm (or claude-agent--permission-mode claude-agent-default-permission-mode)))
    (format "model: %s | mode: %s" model perm)))

(defun claude-agent--init-chat-buffer ()
  "Initialize the chat buffer with header and input area."
  (erase-buffer)
  ;; Header
  (insert (propertize "--- Claude Agent ---\n" 'face 'claude-agent-separator))
  (insert (propertize (concat (claude-agent--header-string) "\n") 'face 'claude-agent-header-face))
  (insert (propertize "C-c C-c send | C-c C-k stop | SPC a r review | SPC a m model | SPC a p mode\n"
                      'face 'claude-agent-separator))
  (insert (propertize (make-string 60 ?-) 'face 'claude-agent-separator))
  (insert "\n\n")
  ;; Output end marker -- all chat output is inserted before this
  (setq claude-agent--output-end (point-marker))
  (set-marker-insertion-type claude-agent--output-end nil)
  ;; Input separator and prompt
  (insert (propertize (concat (make-string 60 ?-) "\n") 'face 'claude-agent-separator))
  (insert (propertize "> " 'face 'claude-agent-prompt-face))
  ;; Input start marker -- user types after this
  (setq claude-agent--input-start (point-marker))
  (set-marker-insertion-type claude-agent--input-start nil)
  (goto-char (point-max)))

(defun claude-agent--show-panel ()
  "Display the chat panel in a side window."
  (let ((buf (claude-agent--get-chat-buffer)))
    (display-buffer buf
                    `((display-buffer-in-side-window)
                      (side . right)
                      (window-width . ,claude-agent-panel-width)))
    (let ((win (get-buffer-window buf)))
      (when win
        (select-window win)
        (goto-char (point-max))))))

(defun claude-agent--append-output (text face)
  "Append TEXT with FACE to the chat output area."
  (let ((buf (get-buffer "*claude-agent*")))
    (when (and buf (buffer-live-p buf))
      (with-current-buffer buf
        (save-excursion
          (goto-char claude-agent--output-end)
          (insert (propertize text 'face face))
          (set-marker claude-agent--output-end (point)))
        ;; Auto-scroll to show latest output, but don't move cursor out of input area
        (dolist (win (get-buffer-window-list buf nil t))
          (set-window-point win
                            (if (>= (window-point win) (marker-position claude-agent--input-start))
                                (window-point win)  ;; keep cursor in input area
                              (marker-position claude-agent--output-end))))))))

(defun claude-agent--append-status (text)
  "Append a status line TEXT to the chat."
  (claude-agent--append-output (concat "\n" text "\n") 'claude-agent-status-face))

;;;; ============================================================
;;;; Process Management
;;;; ============================================================

(defun claude-agent--build-command (prompt)
  "Build the command list for claude CLI with PROMPT."
  (let ((model (or claude-agent--model claude-agent-default-model))
        (perm (or claude-agent--permission-mode claude-agent-default-permission-mode)))
    (append (list claude-agent-cli-path
                  "-p"
                  "--output-format" "stream-json"
                  "--verbose"
                  "--include-partial-messages"
                  "--model" model
                  "--permission-mode" perm)
            ;; Use --resume for subsequent turns in same session
            (when claude-agent--session-id
              (list "--resume" claude-agent--session-id))
            (list prompt))))

(defun claude-agent--start-process (prompt)
  "Start a claude CLI process with PROMPT."
  ;; Kill existing process if running
  (when (and claude-agent--process (process-live-p claude-agent--process))
    (delete-process claude-agent--process))
  ;; Reset per-turn state
  (setq claude-agent--partial-line ""
        claude-agent--streaming-p t
        claude-agent--edits nil
        claude-agent--current-tool nil)
  (let* ((dir (or claude-agent--working-dir
                  (and (fboundp 'projectile-project-p)
                       (projectile-project-p)
                       (projectile-project-root))
                  default-directory))
         (default-directory dir)
         (cmd (claude-agent--build-command prompt)))
    (setq claude-agent--working-dir dir)
    (claude-agent--append-status "[Thinking...]")
    (setq claude-agent--process
          (make-process
           :name "claude-agent"
           :buffer nil
           :command cmd
           :connection-type 'pty
           :filter #'claude-agent--process-filter
           :sentinel #'claude-agent--process-sentinel
           :noquery t))
    ;; Close stdin so claude doesn't wait for input
    (process-send-eof claude-agent--process)))

(defun claude-agent--strip-ansi (str)
  "Remove ANSI escape sequences and carriage returns from STR."
  (replace-regexp-in-string "\r" ""
                            (replace-regexp-in-string "\033\\[[0-9;]*[a-zA-Z]" "" str)))

(defun claude-agent--process-filter (_proc output)
  "Process filter for claude CLI OUTPUT. Accumulates and parses JSON lines."
  (setq claude-agent--partial-line
        (concat claude-agent--partial-line (claude-agent--strip-ansi output)))
  (let ((lines (split-string claude-agent--partial-line "\n")))
    ;; Last element may be partial (incomplete line)
    (setq claude-agent--partial-line (car (last lines)))
    ;; Process all complete lines (everything except the last element)
    (dolist (line (butlast lines))
      (when (and line (not (string-empty-p (string-trim line))))
        (condition-case err
            (let ((json (json-read-from-string line)))
              (claude-agent--handle-event json))
          (error nil))))))

(defun claude-agent--process-sentinel (_proc event)
  "Process sentinel. EVENT describes what happened."
  (setq claude-agent--streaming-p nil)
  (let ((ev (string-trim event)))
    (cond
     ((string-match-p "finished" ev)
      (claude-agent--append-status "[Done]")
      (when claude-agent--edits
        (claude-agent--append-output
         (format "\n[%d file change(s) -- SPC a r to review]\n"
                 (length claude-agent--edits))
         'claude-agent-status-face)))
     ((string-match-p "\\(killed\\|signal\\)" ev)
      (claude-agent--append-status "[Stopped]"))
     (t
      (claude-agent--append-status (format "[Process: %s]" ev)))))
  ;; Move cursor to input area and enter insert state for next prompt
  (let ((buf (get-buffer "*claude-agent*")))
    (when (and buf (buffer-live-p buf))
      (let ((win (get-buffer-window buf)))
        (when win
          (with-selected-window win
            (goto-char claude-agent--input-start)
            (when (and (bound-and-true-p evil-mode)
                       (fboundp 'evil-insert-state))
              (evil-insert-state))))))))

;;;; ============================================================
;;;; JSON Event Dispatch
;;;; ============================================================

(defun claude-agent--handle-event (json)
  "Dispatch a parsed JSON event."
  (let ((type (alist-get 'type json)))
    (cond
     ;; Init -- capture session ID
     ((string= type "system")
      (let ((sid (alist-get 'session_id json)))
        (when sid (setq claude-agent--session-id sid))))

     ;; Streaming text deltas
     ((string= type "stream_event")
      (claude-agent--handle-stream-event (alist-get 'event json)))

     ;; Full assistant message (tool_use blocks)
     ((string= type "assistant")
      (claude-agent--handle-assistant-message (alist-get 'message json)))

     ;; User message (tool results)
     ((string= type "user")
      (claude-agent--handle-user-message json))

     ;; Final result
     ((string= type "result")
      (let ((cost (alist-get 'total_cost_usd json)))
        (when cost
          (claude-agent--append-status (format "[Cost: $%.4f]" cost))))))))

(defun claude-agent--handle-stream-event (event)
  "Handle a stream_event EVENT for real-time text display."
  (when event
    (let ((etype (alist-get 'type event)))
      (cond
       ;; Text delta -- the main streaming content
       ((string= etype "content_block_delta")
        (let* ((delta (alist-get 'delta event))
               (dtype (alist-get 'type delta)))
          (cond
           ((string= dtype "text_delta")
            (let ((text (alist-get 'text delta)))
              (when text
                (claude-agent--append-output text 'claude-agent-response-face))))
           ;; Tool input JSON delta (partial tool args) -- ignore
           ((string= dtype "input_json_delta") nil))))

       ;; Content block start
       ((string= etype "content_block_start")
        (let* ((block (alist-get 'content_block event))
               (btype (alist-get 'type block)))
          (when (string= btype "tool_use")
            (let ((name (alist-get 'name block)))
              (setq claude-agent--current-tool name)
              (claude-agent--append-output
               (format "\n[%s] " name) 'claude-agent-tool-face)))))

       ;; Content block stop
       ((string= etype "content_block_stop")
        (when claude-agent--current-tool
          (claude-agent--append-output " done\n" 'claude-agent-tool-face)
          (setq claude-agent--current-tool nil)))))))

(defun claude-agent--tool-detail (name input)
  "Format a one-line detail string for tool NAME with INPUT."
  (cond
   ((string= name "Read")
    (let ((f (alist-get 'file_path input)))
      (when f (format "%s" (abbreviate-file-name f)))))
   ((string= name "Edit")
    (let ((f (alist-get 'file_path input)))
      (when f (format "%s" (abbreviate-file-name f)))))
   ((string= name "Write")
    (let ((f (alist-get 'file_path input)))
      (when f (format "%s" (abbreviate-file-name f)))))
   ((string= name "Bash")
    (let ((cmd (alist-get 'command input))
          (desc (alist-get 'description input)))
      (or desc cmd)))
   ((string= name "Glob")
    (let ((pat (alist-get 'pattern input)))
      (when pat (format "\"%s\"" pat))))
   ((string= name "Grep")
    (let ((pat (alist-get 'pattern input))
          (path (alist-get 'path input)))
      (format "\"%s\"%s" (or pat "")
              (if path (format " in %s" (abbreviate-file-name path)) ""))))
   ((string= name "WebSearch")
    (let ((q (alist-get 'query input)))
      (when q (format "\"%s\"" q))))
   ((string= name "Task")
    (let ((desc (alist-get 'description input)))
      (when desc desc)))
   (t nil)))

(defun claude-agent--handle-assistant-message (msg)
  "Handle a full assistant MESSAGE. Show detailed tool use activity."
  (when msg
    (let ((content (alist-get 'content msg)))
      (when (vectorp content)
        (cl-loop
         for block across content
         when (string= (alist-get 'type block) "tool_use")
         do (let* ((name (alist-get 'name block))
                   (input (alist-get 'input block))
                   (detail (claude-agent--tool-detail name input)))
              (claude-agent--append-output
               (format "  %s%s\n" name (if detail (format ": %s" detail) ""))
               'claude-agent-tool-face)))))))

(defun claude-agent--truncate (str max)
  "Truncate STR to MAX chars, adding ... if needed."
  (if (and str (> (length str) max))
      (concat (substring str 0 max) "...")
    (or str "")))

(defun claude-agent--handle-user-message (json)
  "Handle a user message JSON. Show tool results and capture edits."
  (let ((result (alist-get 'tool_use_result json)))
    (when result
      ;; Show tool result summary
      (cond
       ;; Edit result -- capture for diff review
       ((alist-get 'oldString result)
        (let ((file-path (alist-get 'filePath result))
              (old-string (alist-get 'oldString result))
              (new-string (alist-get 'newString result))
              (patch (alist-get 'structuredPatch result)))
          (when (and file-path old-string new-string)
            (push (list :file file-path
                        :old old-string
                        :new new-string
                        :patch (when (vectorp patch) (append patch nil))
                        :status 'pending)
                  claude-agent--edits)
            (claude-agent--append-output
             (format "  -> edited %s\n" (file-name-nondirectory file-path))
             'claude-agent-tool-face))))
       ;; Bash result -- show stdout snippet
       ((alist-get 'stdout result)
        (let ((stdout (alist-get 'stdout result)))
          (when (and stdout (not (string-empty-p stdout)))
            (claude-agent--append-output
             (format "  -> %s\n" (claude-agent--truncate
                                  (car (split-string stdout "\n")) 80))
             'claude-agent-tool-face))))
       ;; File read result
       ((alist-get 'filePath result)
        (let ((f (alist-get 'filePath result))
              (lines (alist-get 'numLines result)))
          (claude-agent--append-output
           (format "  -> %s (%s lines)\n"
                   (file-name-nondirectory f) (or lines "?"))
           'claude-agent-tool-face)))))))

;;;; ============================================================
;;;; User Commands -- Chat
;;;; ============================================================

(defun claude-agent-open ()
  "Open the Claude agent chat panel."
  (interactive)
  (claude-agent--show-panel))

(defun claude-agent-send ()
  "Send the current input to Claude."
  (interactive)
  (let ((buf (get-buffer "*claude-agent*")))
    (unless buf (error "No agent panel open"))
    (with-current-buffer buf
      (when claude-agent--streaming-p
        (error "Agent is still responding, use C-c C-k to stop"))
      (let* ((prompt (string-trim
                      (buffer-substring-no-properties
                       claude-agent--input-start (point-max)))))
        (when (string-empty-p prompt)
          (error "Empty prompt"))
        ;; Show prompt in chat history
        (claude-agent--append-output
         (concat (propertize "You: " 'face 'claude-agent-prompt-face) prompt "\n\n")
         'claude-agent-response-face)
        ;; Clear input area
        (delete-region claude-agent--input-start (point-max))
        ;; Start process
        (claude-agent--start-process prompt)))))

(defun claude-agent-stop ()
  "Stop the current claude process."
  (interactive)
  (when (and claude-agent--process (process-live-p claude-agent--process))
    (delete-process claude-agent--process)
    (setq claude-agent--streaming-p nil)
    (message "Claude agent stopped.")))

(defun claude-agent-reset ()
  "Reset the agent -- clear chat, new session."
  (interactive)
  (claude-agent-stop)
  (setq claude-agent--session-id nil
        claude-agent--edits nil
        claude-agent--working-dir nil)
  (let ((buf (get-buffer "*claude-agent*")))
    (when buf
      (with-current-buffer buf
        (claude-agent--init-chat-buffer))))
  (message "Claude agent reset."))

;;;; ============================================================
;;;; Model & Permission Mode Selection
;;;; ============================================================

(defvar claude-agent--model-choices
  '("sonnet" "opus" "haiku"
    "claude-sonnet-4-5-20250929"
    "claude-opus-4-6"
    "claude-haiku-4-5-20251001")
  "Available model choices.")

(defvar claude-agent--permission-mode-choices
  '("acceptEdits" "plan" "bypassPermissions" "default" "dontAsk")
  "Available permission modes.")

(defun claude-agent-select-model ()
  "Select the model for the agent."
  (interactive)
  (let ((model (completing-read
                (format "Model (current: %s): "
                        (or claude-agent--model claude-agent-default-model))
                claude-agent--model-choices nil nil nil nil
                (or claude-agent--model claude-agent-default-model))))
    (setq claude-agent--model model)
    ;; Update header in chat buffer
    (claude-agent--update-header)
    (message "Model set to: %s" model)))

(defun claude-agent-select-permission-mode ()
  "Select the permission mode for the agent."
  (interactive)
  (let ((mode (completing-read
               (format "Permission mode (current: %s): "
                       (or claude-agent--permission-mode claude-agent-default-permission-mode))
               claude-agent--permission-mode-choices nil t nil nil
               (or claude-agent--permission-mode claude-agent-default-permission-mode))))
    (setq claude-agent--permission-mode mode)
    (claude-agent--update-header)
    (message "Permission mode set to: %s" mode)))

(defun claude-agent--update-header ()
  "Update the header line in the chat buffer."
  (let ((buf (get-buffer "*claude-agent*")))
    (when (and buf (buffer-live-p buf))
      (with-current-buffer buf
        (save-excursion
          (goto-char (point-min))
          ;; Find the header line (second line)
          (forward-line 1)
          (let ((line-start (point)))
            (forward-line 1)
            (delete-region line-start (point))
            (goto-char line-start)
            (insert (propertize (concat (claude-agent--header-string) "\n")
                                'face 'claude-agent-header-face))))))))

;;;; ============================================================
;;;; Diff Review UI
;;;; ============================================================

(defun claude-agent-review ()
  "Open the diff review buffer showing all pending edits."
  (interactive)
  (unless claude-agent--edits
    (error "No file changes to review"))
  (let ((buf (get-buffer-create "*claude-agent-diff*")))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (claude-agent-diff-mode)
        (claude-agent--render-diffs)))
    (pop-to-buffer buf)))

(defun claude-agent--render-diffs ()
  "Render all edits into the diff review buffer."
  (let ((inhibit-read-only t)
        (idx 0))
    (insert (propertize "Claude Agent - Review Changes\n" 'face 'claude-agent-diff-file-header))
    (insert (propertize (format "%d change(s) | a:accept x:reject A:all X:reject-all n/p:nav q:quit\n"
                                (length claude-agent--edits))
                        'face 'claude-agent-separator))
    (insert (propertize (make-string 70 ?-) 'face 'claude-agent-separator))
    (insert "\n\n")
    (dolist (edit (reverse claude-agent--edits))
      (claude-agent--render-one-hunk edit idx)
      (setq idx (1+ idx)))
    (goto-char (point-min))
    (claude-agent-diff-next-hunk)))

(defun claude-agent--render-one-hunk (edit idx)
  "Render one EDIT hunk at index IDX."
  (let* ((file (plist-get edit :file))
         (old-str (plist-get edit :old))
         (new-str (plist-get edit :new))
         (status (plist-get edit :status))
         (patch (plist-get edit :patch))
         (hunk-start (point)))
    ;; File header
    (insert (propertize (format "--- %s " (file-name-nondirectory file))
                        'face 'claude-agent-diff-file-header))
    ;; Status badge
    (insert (pcase status
              ('pending  (propertize "[PENDING]"  'face '(:foreground "#fabd2f" :weight bold)))
              ('accepted (propertize "[ACCEPTED]" 'face '(:foreground "#b8bb26" :weight bold)))
              ('rejected (propertize "[REJECTED]" 'face '(:foreground "#fb4934" :weight bold)))))
    (insert "\n")
    (insert (propertize (abbreviate-file-name file) 'face '(:foreground "#585858")))
    (insert "\n")
    ;; Render diff
    (if patch
        (claude-agent--render-structured-patch patch)
      (claude-agent--render-simple-diff old-str new-str))
    (insert "\n")
    ;; Overlay for navigation/actions
    (let ((ov (make-overlay hunk-start (point))))
      (overlay-put ov 'claude-agent-hunk t)
      (overlay-put ov 'claude-agent-hunk-idx idx)
      (overlay-put ov 'claude-agent-edit edit))))

(defun claude-agent--render-structured-patch (patch)
  "Render PATCH (list of hunk alists from structuredPatch)."
  (dolist (hunk patch)
    (let* ((old-start (alist-get 'oldStart hunk))
           (old-lines (alist-get 'oldLines hunk))
           (new-start (alist-get 'newStart hunk))
           (new-lines (alist-get 'newLines hunk))
           (lines (alist-get 'lines hunk)))
      (insert (propertize (format "@@ -%d,%d +%d,%d @@\n"
                                  old-start old-lines new-start new-lines)
                          'face 'claude-agent-diff-hunk-header))
      (when (vectorp lines)
        (cl-loop for line across lines do
                 (cond
                  ((string-prefix-p "+" line)
                   (insert (propertize (concat line "\n") 'face 'claude-agent-diff-added)))
                  ((string-prefix-p "-" line)
                   (insert (propertize (concat line "\n") 'face 'claude-agent-diff-removed)))
                  (t
                   (insert (propertize (concat line "\n") 'face 'claude-agent-diff-context)))))))))

(defun claude-agent--render-simple-diff (old-str new-str)
  "Render a simple diff between OLD-STR and NEW-STR."
  (dolist (line (split-string old-str "\n"))
    (insert (propertize (concat "- " line "\n") 'face 'claude-agent-diff-removed)))
  (dolist (line (split-string new-str "\n"))
    (insert (propertize (concat "+ " line "\n") 'face 'claude-agent-diff-added))))

;;;; ============================================================
;;;; Diff Review Actions
;;;; ============================================================

(defun claude-agent--hunk-at-point ()
  "Get the hunk overlay at point."
  (cl-find-if (lambda (ov) (overlay-get ov 'claude-agent-hunk))
              (overlays-at (point))))

(defun claude-agent-diff-accept-hunk ()
  "Accept the hunk at point (keep the change)."
  (interactive)
  (let ((ov (claude-agent--hunk-at-point)))
    (unless ov (error "No hunk at point"))
    (let ((edit (overlay-get ov 'claude-agent-edit)))
      (plist-put edit :status 'accepted)
      (claude-agent--refresh-diff)
      (message "Hunk accepted."))))

(defun claude-agent-diff-reject-hunk ()
  "Reject the hunk at point (revert the file change)."
  (interactive)
  (let ((ov (claude-agent--hunk-at-point)))
    (unless ov (error "No hunk at point"))
    (let* ((edit (overlay-get ov 'claude-agent-edit))
           (file (plist-get edit :file))
           (old-str (plist-get edit :old))
           (new-str (plist-get edit :new)))
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (goto-char (point-min))
          (when (search-forward new-str nil t)
            (replace-match old-str t t))
          (save-buffer)
          (revert-buffer t t t)))
      (plist-put edit :status 'rejected)
      (claude-agent--refresh-diff)
      (message "Hunk rejected -- file reverted."))))

(defun claude-agent-diff-accept-all ()
  "Accept all pending hunks."
  (interactive)
  (dolist (edit claude-agent--edits)
    (when (eq (plist-get edit :status) 'pending)
      (plist-put edit :status 'accepted)))
  (claude-agent--refresh-diff)
  (message "All hunks accepted."))

(defun claude-agent-diff-reject-all ()
  "Reject all pending hunks (revert all changes)."
  (interactive)
  (when (y-or-n-p "Reject all pending changes? ")
    (dolist (edit (reverse claude-agent--edits))
      (when (eq (plist-get edit :status) 'pending)
        (let ((file (plist-get edit :file))
              (old-str (plist-get edit :old))
              (new-str (plist-get edit :new)))
          (when (file-exists-p file)
            (with-current-buffer (find-file-noselect file)
              (goto-char (point-min))
              (when (search-forward new-str nil t)
                (replace-match old-str t t))
              (save-buffer)
              (revert-buffer t t t))))
        (plist-put edit :status 'rejected)))
    (claude-agent--refresh-diff)
    (message "All hunks rejected -- files reverted.")))

(defun claude-agent-diff-next-hunk ()
  "Move to the next hunk."
  (interactive)
  (let ((pos (point))
        (found nil))
    (let ((cur-ov (claude-agent--hunk-at-point)))
      (when cur-ov
        (goto-char (overlay-end cur-ov))))
    (while (and (not found) (< (point) (point-max)))
      (if (cl-find-if (lambda (ov) (overlay-get ov 'claude-agent-hunk))
                      (overlays-at (point)))
          (setq found t)
        (goto-char (next-overlay-change (point)))))
    (unless found
      (goto-char pos)
      (message "No more hunks."))))

(defun claude-agent-diff-prev-hunk ()
  "Move to the previous hunk."
  (interactive)
  (let ((pos (point))
        (found nil))
    (let ((cur-ov (claude-agent--hunk-at-point)))
      (when cur-ov
        (goto-char (max (point-min) (1- (overlay-start cur-ov))))))
    (while (and (not found) (> (point) (point-min)))
      (goto-char (previous-overlay-change (point)))
      (when (cl-find-if (lambda (ov) (overlay-get ov 'claude-agent-hunk))
                        (overlays-at (point)))
        (setq found t)))
    (unless found
      (goto-char pos)
      (message "No previous hunks."))))

(defun claude-agent-diff-visit-file ()
  "Visit the file for the hunk at point."
  (interactive)
  (let ((ov (claude-agent--hunk-at-point)))
    (unless ov (error "No hunk at point"))
    (let* ((edit (overlay-get ov 'claude-agent-edit))
           (file (plist-get edit :file)))
      (when (file-exists-p file)
        (find-file-other-window file)))))

(defun claude-agent-diff-quit ()
  "Quit the diff review buffer."
  (interactive)
  (quit-window t))

(defun claude-agent--refresh-diff ()
  "Re-render the diff review buffer."
  (let ((buf (get-buffer "*claude-agent-diff*"))
        (pos (point)))
    (when buf
      (with-current-buffer buf
        (let ((inhibit-read-only t))
          (erase-buffer)
          (claude-agent--render-diffs))
        (goto-char (min pos (point-max)))))))

;;;; ============================================================
;;;; Evil Integration
;;;; ============================================================

(defun claude-agent--setup-evil ()
  "Set up Evil keybindings for claude-agent modes."
  (when (bound-and-true-p evil-mode)
    ;; Chat panel -- insert mode for typing
    (evil-set-initial-state 'claude-agent-chat-mode 'insert)

    ;; Diff review -- normal mode
    (evil-set-initial-state 'claude-agent-diff-mode 'normal)
    (evil-define-key 'normal claude-agent-diff-mode-map
      (kbd "a")   #'claude-agent-diff-accept-hunk
      (kbd "x")   #'claude-agent-diff-reject-hunk
      (kbd "A")   #'claude-agent-diff-accept-all
      (kbd "X")   #'claude-agent-diff-reject-all
      (kbd "n")   #'claude-agent-diff-next-hunk
      (kbd "p")   #'claude-agent-diff-prev-hunk
      (kbd "q")   #'claude-agent-diff-quit
      (kbd "RET") #'claude-agent-diff-visit-file
      (kbd "j")   #'next-line
      (kbd "k")   #'previous-line
      (kbd "G")   #'end-of-buffer
      (kbd "gg")  #'beginning-of-buffer)

    ;; Chat panel evil bindings
    (evil-define-key 'insert claude-agent-chat-mode-map
      (kbd "C-c C-c") #'claude-agent-send
      (kbd "C-c C-k") #'claude-agent-stop)
    (evil-define-key 'normal claude-agent-chat-mode-map
      (kbd "C-c C-c") #'claude-agent-send
      (kbd "C-c C-k") #'claude-agent-stop
      (kbd "q")       #'quit-window)))

(with-eval-after-load 'evil
  (claude-agent--setup-evil))

(when (bound-and-true-p evil-mode)
  (claude-agent--setup-evil))

;;;; ============================================================
;;;; Provide
;;;; ============================================================

(provide 'claude-agent)

;;; claude-agent.el ends here
