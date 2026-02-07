;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;;; ============================================================================
;;;; Environment & Paths
;;;; ============================================================================

(add-to-list 'exec-path "/home/rusty/.opam/default/bin")
(setenv "PATH" (concat "/home/rusty/.opam/default/bin:" (getenv "PATH")))
;;;; ============================================================================
;;;; Theme & UI
;;;; ============================================================================

(load-file "~/kanagawa-theme-source-code.el")
(load-file "~/dotfiles/.config/doom/cargo-toml.el")
(load-file "~/dotfiles/.config/doom/cpp-templates.el")
;; (load-file "~/dotfiles/.config/doom/osmium.el")

(defun my/apply-dark-theme-custom ()
  "Apply custom faces for dark themes only."
  (when (eq (car custom-enabled-themes) 'solarized-gruvbox-dark)
    (setq doom-palenight-padded-modeline t)
    (custom-set-faces!
      '(default :background "#16161D")
      '(mode-line :foreground "#ffffff")
      '(treemacs-window-background-face :background "#16161D")
      '(dired-header :background "#16161D")
      ;; Eldoc box faces
      '(eldoc-box-body :background "#1a1a1a" :foreground "#ffffff")
      '(eldoc-box-border :background "#444444")
      ;; Code blocks in documentation (Markdown)
      '(markdown-code-face :background "#2a2a3a" :foreground "#c0caf5")
      '(markdown-inline-code-face :background "#2a2a3a" :foreground "#c0caf5")
      ;; Generic doc markup face
      '(font-lock-doc-markup-face :background "#2a2a3a" :foreground "#c0caf5"))))



(defun my/set-theme-by-time()
  "Set theme based on current time of the day."
  (let ((hour (string-to-number (format-time-string "%H"))))
    (if (and (>= hour 7) (< hour 12))
        ;; (progn
        (load-theme 'doom-solarized-light t)
      ;; (setq doom-gruvbox-light-variant "hard"))
      (progn
        (load-theme 'doom-palenight t)
        (my/apply-dark-theme-custom)))))

;; (add-hook 'emacs-startup-hook #'my/set-theme-by-time)


;; (run-at-time "0 sec" 3600 #'my/set-theme-by-time)

;; (load-theme 'doom-solarized-light t)
;; (load-theme 'solarized-gruvbox-dark t)
(my/apply-dark-theme-custom)
(setq doom-font (font-spec :family "JetBrainsMono NFM SemiBold" :size 15))
(setq doom-theme 'kanagawa)

(after! lsp-mode
  (setq lsp-semantic-tokens-enable t
        lsp-enable-file-watchers nil))

;; (after! solaire-mode
;;   (solaire-global-mode -1))

;; Dashboard
(defun doom-dashboard-draw-ascii-banner-fn ()
  (let* ((banner
          '("       ██████╗ ███████╗██╗    ██╗██████╗ ██╗████████╗███████╗    ██╗████████╗"
            "       ██╔══██╗██╔════╝██║    ██║██╔══██╗██║╚══██╔══╝██╔════╝    ██║╚══██╔══╝"
            "       ██████╔╝█████╗  ██║ █╗ ██║██████╔╝██║   ██║   █████╗      ██║   ██║   "
            "       ██╔══██╗██╔══╝  ██║███╗██║██╔══██╗██║   ██║   ██╔══╝      ██║   ██║   "
            "       ██║  ██║███████╗╚███╔███╔╝██║  ██║██║   ██║   ███████╗    ██║   ██║   "
            "       ╚═╝  ╚═╝╚══════╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝    ╚═╝   ╚═╝   "
            "                                                                             "
            "                    ██╗███╗   ██╗    ██████╗ ██╗   ██╗███████╗████████╗      "
            "                    ██║████╗  ██║    ██╔══██╗██║   ██║██╔════╝╚══██╔══╝      "
            "                    ██║██╔██╗ ██║    ██████╔╝██║   ██║███████╗   ██║         "
            "                    ██║██║╚██╗██║    ██╔══██╗██║   ██║╚════██║   ██║         "
            "                    ██║██║ ╚████║    ██║  ██║╚██████╔╝███████║   ██║         "
            "                    ╚═╝╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝         "))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property
     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat
                 (propertize line 'face 'doom-dashboard-banner)
                 (make-string (max 0 (- longest-line (length line))) 32)))
               "\n"))
     'face 'doom-dashboard-banner))
  (insert "\n\n"))

(setq +doom-dashboard-ascii-banner-fn #'doom-dashboard-draw-ascii-banner-fn)

(custom-set-faces!
  '(doom-dashboard-banner :foreground "#a855f7" :weight bold))

;; Transparency
(add-to-list 'default-frame-alist '(alpha-background . 90))
(set-frame-parameter nil 'alpha-background 90)

(unless (display-graphic-p)
  (defun my/apply-terminal-transparency (&optional frame)
    (unless (display-graphic-p frame)
      (set-face-background 'default "unspecified-bg" frame)))
  (add-hook 'after-make-frame-functions 'my/apply-terminal-transparency)
  (add-hook 'window-setup-hook 'my/apply-terminal-transparency))

;; Centaur Tabs
(after! centaur-tabs
  (setq centaur-tabs-style "chamfer"
        centaur-tabs-set-bar 'over
        centaur-tabs-set-close-button nil
        centaur-tabs-adjust-buffer-order 'right)
  (custom-set-faces!
    '(centaur-tabs-default :background "#16161D")))

;;;; ============================================================================
;;;; Editor Behavior
;;;; ============================================================================
(setq shr-inhibit-scripts nil)
(setq display-line-numbers-type 'relative
      confirm-kill-emacs nil
      scroll-margin 20
      scroll-conservatively 101
      scroll-preserve-screen-position t
      select-enable-clipboard t
      select-enable-primary t)

;; Mouse avoidance
(use-package! avoid
  :config
  (mouse-avoidance-mode 'exile))

;; Wakatime
;; (use-package! wakatime-mode
;;   :config
;;   (global-wakatime-mode))

;; Using Zathura for pdfs when inside terminal
(defun my/open-pdf-in-zathura (file)
  "Open FILE in Zathura."
  (interactive "fPDF file: ")
  (start-process "zathura" nil "zathura" (expand-file-name file)))
(map! :leader
      :desc "Open PDF in Zathura"
      "o z" #'my/open-pdf-in-zathura)
;;;; ============================================================================
;;;; Clipboard (Wayland)
;;;; ============================================================================

(setq wl-copy-process nil)

(defun wl-copy (text)
  (setq wl-copy-process (make-process :name "wl-copy"
                                      :buffer nil
                                      :command '("wl-copy" "-f" "-n")
                                      :connection-type 'pipe
                                      :noquery t))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))

(defun wl-paste ()
  (if (and wl-copy-process (process-live-p wl-copy-process))
      nil
    (with-temp-buffer
      (call-process "wl-paste" nil t nil "-n")
      (call-process-region (point-min) (point-max) "tr" t t nil "-d" "\r")
      (buffer-string))))

(setq interprogram-cut-function 'wl-copy
      interprogram-paste-function 'wl-paste)

;;;; ============================================================================
;;;; Org Mode
;;;; ============================================================================
(after! ob-ditaa
  (defun org-babel-execute:ditaa (body params)
    "Execute ditaa code with BODY and PARAMS using standalone ditaa executable."
    (let* ((out-file (or (cdr (assq :file params))
                         (error "ditaa requires a :file parameter")))
           (cmdline (cdr (assq :cmdline params)))
           (in-file (org-babel-temp-file "ditaa-"))
           (cmd (format "ditaa %s %s %s"
                        (or cmdline "")
                        (org-babel-process-file-name in-file)
                        (org-babel-process-file-name out-file))))
      (with-temp-file in-file (insert body))
      (message "%s" cmd)
      (shell-command cmd)
      nil)))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((ditaa . t)))

(setq org-confirm-babel-evaluate nil)
(setq org-startup-with-inline-images t)


(setq org-directory "~/org/"
      org-agenda-files (list (expand-file-name "tasks.org" org-directory))
      org-archive-location "~/org/archive.org::* Archived Tasks"
      org-todo-keywords '((sequence "TODO(t)" "PROG(p)" "DONE(d)"))
      org-todo-keyword-faces '(("TODO" . (:foreground "#ff6c6b" :weight bold))
                               ("PROG" . (:foreground "#ECBE7B" :weight bold))
                               ("DONE" . (:foreground "#98be65" :weight bold)))
      org-agenda-custom-commands
      '(("n" "My Weekly Agenda"
         ((agenda "" ((org-agenda-span 'week)))
          (todo "PROG" ((org-agenda-overriding-header "In Progress")))
          (todo "TODO" ((org-agenda-overriding-header "To Do:")))
          (todo "DONE" ((org-agenda-overriding-header "Done"))))
         nil))
      org-tag-alist '((:startgroup . nil)
                      ("work" . ?w)
                      ("daily" . ?p)
                      ("project" . ?j)
                      ("meeting" . ?m)
                      ("urgent" . ?u)
                      (:endgroup . nil))
      org-capture-templates
      '(("t" "Todo" entry
         (file+headline "~/org/tasks.org" "Inbox")
         "** TODO %?\n   CREATED: %U\n")
        ("w" "Work Task" entry
         (file+headline "~/org/tasks.org" "Work Tasks")
         "** TODO %?\n   CREATED: %U\n")
        ("p" "Personal" entry
         (file+headline "~/org/tasks.org" "Personal")
         "** TODO %?\n   CREATED: %U\n")))

;; Auto-save tasks file when idle
(add-hook 'org-mode-hook
          (lambda ()
            (when (string-match-p "tasks\\.org$" (buffer-file-name))
              (auto-save-mode 1))))

;;;; ============================================================================
;;;; LSP & Language Support
;;;; ============================================================================

;; Assembly
(use-package! nasm-mode
  :mode "\\.asm\\'")

(after! nasm-mode
  (setq nasm-basic-offset 4))
;;;; scheme
(setq geiser-default-implementation 'mit)

;; Rust
;; (after! rustic
;;   (setq rustic-lsp-client 'eglot))
;; Zig
(use-package! zig-mode
  :hook (zig-mode . eglot-ensure))

;; LSP UI
(after! lsp-ui
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-show-with-cursor nil
        lsp-ui-doc-delay 0.2
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-max-width 80
        lsp-ui-doc-max-height 20))
;; Eglot
(use-package! eglot
  :init
  (setq eglot-enable-semantic-tokens t)
  :hook ((tuareg-mode . eglot-ensure)
         ;; (rustic-mode . eglot-ensure)
         (toml-ts-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c++-mode . eglot-ensure))
  :config
  (setq eglot-connect-timeout 60)

  ;; Language servers
  (add-to-list 'eglot-server-programs '(tuareg-mode . ("ocamllsp")))
  (add-to-list 'eglot-server-programs '(rustic-mode . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs '(zig-mode . ("zls")))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) .
                 ("clangd"
                  "--background-index"
                  "--clang-tidy"
                  "--completion-style=detailed"
                  "--header-insertion=never"
                  "--fallback-style=llvm"
                  "--compile-commands-dir=build"
                  "--query-driver=/usr/bin/g++-*,/usr/bin/clang++-*"))))

;; Inlay hints
(with-eval-after-load 'eglot
  (custom-set-faces
   '(eglot-inlay-hint-face ((t (:foreground "#54546D" :height 0.8))))))


;; FlyMake
(set-popup-rule! "^\\*Flymake diagnostics"
  :side 'bottom
  :size 0.4
  :select t)

;; Eldoc
(after! eldoc
  (setq eldoc-echo-area-use-multiline-p t
        eldoc-echo-area-prefer-doc-buffer nil))

;; Eldoc Box
(use-package! eldoc-box
  :config
  (setq eldoc-box-max-pixel-width 800
        eldoc-box-max-pixel-height 600
        eldoc-box-position-function #'eldoc-box--default-at-point-position-function-1
        eldoc-idle-delay 0.1)
  (set-face-attribute 'eldoc-box-border nil :background "#444444")
  ;; (set-face-attribute 'eldoc-box-body nil :background "#1a1a1a" :foreground "#ffffff")
  )


(defun my/show-error-at-point ()
  "Show eldoc box only if there's an error/warning at current point."
  (interactive)
  (when (bound-and-true-p eglot--managed-mode)
    (let ((diagnostics (flymake-diagnostics (point))))
      (if diagnostics
          (eldoc-box-help-at-point)
        (message "No diagnostics at point")))))

;; Company
(after! company
  (setq company-idle-delay 0.0
        company-minimum-prefix-length 1)
  (add-to-list 'company-backends 'cargo-toml-helper-company-backend)
  (custom-set-faces
   '(company-tooltip-selection ((t (:background "#3a3f5a" :foreground "#ffffff"))))))

;; Cargo TOML helper
(setq cargo-toml-helper-show-inline-versions t)
(add-hook 'toml-mode-hook #'cargo-toml-helper-setup)

;; Auto cargo fmt
(defun my/cargo-fmt-all ()
  "Run 'cargo fmt --all' in the project root and refresh diagnostics."
  (when (and (derived-mode-p 'rust-mode 'rustic-mode)
             (locate-dominating-file default-directory "Cargo.toml"))
    (let ((project-root (locate-dominating-file default-directory "Cargo.toml"))
          (current-buffer (current-buffer)))
      (set-process-sentinel
       (start-process "cargo-fmt" nil "cargo" "fmt" "--all")
       (lambda (process event)
         (when (string-match-p "finished" event)
           (with-current-buffer current-buffer
             (revert-buffer t t t)
             (when (eglot-managed-p)
               (run-with-timer 0.5 nil
                               (lambda ()
                                 (eglot--signal-textDocument/didChange)
                                 (eglot--signal-textDocument/didSave))))
             (message "cargo fmt completed and diagnostics refreshed"))))))))

(add-hook 'after-save-hook #'my/cargo-fmt-all)

;; Auto CMake regeneration
(defun my/auto-cmake-on-save ()
  "Regenerate build files when CMakeLists.txt is saved."
  (when (and (buffer-file-name)
             (string-match-p "CMakeLists\\.txt$" (buffer-file-name)))
    (let* ((project-root (locate-dominating-file default-directory "CMakeLists.txt"))
           (default-directory (or project-root default-directory)))
      (message "Running cmake -B build...")
      (make-process
       :name "cmake-rebuild"
       :buffer "*CMake*"
       :command '("cmake" "-B" "build")
       :sentinel (lambda (proc event)
                   (when (string-match-p "finished" event)
                     (message "CMake finished, restarting Eglot...")
                     (dolist (buf (buffer-list))
                       (with-current-buffer buf
                         (when (and (derived-mode-p 'c-mode 'c++-mode)
                                    (eglot-managed-p))
                           (eglot-reconnect (eglot-current-server)))))))))))

(add-hook 'after-save-hook #'my/auto-cmake-on-save)

;; Tree-sitter
(setq treesit-language-source-alist
      '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (c "https://github.com/tree-sitter/tree-sitter-c")))

;; Flycheck inline
(use-package! flycheck-inline
  :config
  (global-flycheck-mode-enable-in-buffer))

;;;; ============================================================================
;;;; PDF & LaTeX
;;;; ============================================================================

(setq +latex-viewers '(zathura))

(after! pdf-tools
  ;; Dark mode colors
  (setq pdf-view-midnight-colors '("#f8f8f2" . "#282828"))
  (add-hook 'pdf-view-mode-hook 'pdf-view-midnight-minor-mode)

  ;; Display settings
  (setq pdf-view-display-size 'fit-page
        pdf-view-resize-factor 1.1
        pdf-view-use-scaling t
        pdf-view-use-imagemagick nil
        pdf-view-continuous t
        pdf-view-page-spacing 2
        pdf-view-mode-line-indicator
        '(" PDF"
          (pdf-view-midnight-minor-mode " ☾")
          " [" (:eval (number-to-string (pdf-view-current-page)))
          "/" (:eval (number-to-string (pdf-cache-number-of-pages)))
          "]"))

  ;; PDF outline in imenu
  (add-hook 'pdf-view-mode-hook
            (lambda ()
              (setq-local imenu-create-index-function
                          #'pdf-outline-imenu-create-index))))

;; Smart PDF opening (GUI: pdf-tools, Terminal: zathura)
(defun my/smart-open-pdf ()
  "Open PDF with pdf-view-mode in GUI, zathura in terminal."
  (when (and buffer-file-name
             (string-match-p "\\.pdf\\'" buffer-file-name))
    (cond
     ((display-graphic-p)
      (when (require 'pdf-tools nil 'noerror)
        (pdf-view-mode)))
     (t
      (let ((file buffer-file-name))
        (kill-buffer)
        (message "Opening PDF in zathura: %s" file)
        (start-process "zathura" nil "zathura" file))))))

(add-to-list 'auto-mode-alist '("\\.pdf\\'" . my/smart-open-pdf))
(add-hook 'find-file-hook
          (lambda ()
            (when (eq major-mode 'my/smart-open-pdf)
              (my/smart-open-pdf))))

;;;; ============================================================================
;;;; Additional Tools
;;;; ============================================================================

;; Treemacs
(after! treemacs
  (treemacs-follow-mode t)
  (lsp-treemacs-sync-mode 1))

;; Imenu list
(use-package! imenu-list
  :config
  (setq imenu-list-focus-after-activation t
        imenu-list-auto-resize t
        imenu-list-position 'left))

;; EWW
(after! eww
  (set-popup-rule! "^\\*eww\\*" :ignore t))

(defun my/eww-split-bottom (url)
  "Open eww in bottom split window."
  (interactive (list (read-string "Enter URL or keywords: ")))
  (split-window-below)
  (other-window 1)
  (eww url))

;; Eldoc popup
(set-popup-rule! "^\\*eldoc" :side 'bottom :size 0.3 :select nil)

;; Git/Magit
(setq epg-pinentry-mode 'loopback
      magit-commit-show-gpg-key-id t
      magit-commit-signoff-by-default t)
(setq magit-commit-arguments '("--gpg-sign"))
(use-package! git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config
  (setq git-gutter:update-interval 0.02))
(use-package! git-gutter-fringe
  :after git-gutter
  :config
  (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240] nil nil 'bottom))

;; C++ templates
(setq cpp-template-author-name "Soroosh Sardashti"
      cpp-template-author-email "sardashtisoroosh@gmail.com")

;;;; ============================================================================
;;;; Keybindings
;;;; ============================================================================

(defun my/list-errors ()
  "List errors using the appropriate backend (Flymake or Flycheck)."
  (interactive)
  (cond
   ;; If Eglot is managing this buffer, use Flymake
   ((and (fboundp 'eglot-managed-p) (eglot-managed-p))
    (call-interactively #'flymake-show-buffer-diagnostics))
   ;; If Flycheck is active, use it
   ((and (boundp 'flycheck-mode) flycheck-mode)
    (call-interactively #'flycheck-list-errors))
   ;; If Flymake is active (but not Eglot), use it
   ((and (boundp 'flymake-mode) flymake-mode)
    (call-interactively #'flymake-show-buffer-diagnostics))
   ;; Fallback
   (t
    (message "No error checking system active in this buffer"))))

;; Leader bindings
(map! :leader
      :desc "Eval and print" "j" #'eval-print-last-sexp
      :desc "Eval last sexp" "r" #'eval-last-sexp
      :desc "Paste from clipboard" "v" #'wl-paste
      :desc "Toggle vterm" "t t" #'+vterm/toggle
      :desc "Toggle treemacs" "'" #'+treemacs/toggle
      :desc "Next buffer" "TAB" #'evil-next-buffer
      :desc "List errors" "e" #'my/list-errors
      :desc "Org capture" "c" #'org-capture
      :desc "Open tasks file" "o t" (lambda () (interactive) (find-file "~/org/tasks.org"))
      :desc "Custom agenda view" "o n" (lambda () (interactive) (org-agenda nil "n"))
      :desc "Open imenu" "o i" #'imenu-list-smart-toggle
      :desc "Open eww in split" "o e" #'my/eww-split-bottom
      :desc "Go to next error" "n e" #'merlin-error-next)

;; C++ template bindings
(map! :leader
      (:prefix ("m" . "templates")
               "p" #'cpp-template-new-project
               "c" #'cpp-template-new-class
               "h" #'cpp-template-new-header-only-class
               "m" #'cpp-template-insert-method
               "g" #'cpp-template-insert-getter-setter
               "s" #'cpp-template-insert-singleton-pattern
               "r" #'cpp-template-insert-smart-ptr-typedef
               "i" #'cpp-template-insert-pimpl-pattern))

;; Normal mode bindings
(map! :n "C-j" (lambda () (interactive)
                 (if (and (boundp 'lsp-mode) lsp-mode)
                     (lsp-ui-doc-scroll-down)
                   (eldoc-box-scroll-up)))
      :n "C-k" (lambda () (interactive)
                 (if (and (boundp 'lsp-mode) lsp-mode)
                     (lsp-ui-doc-scroll-up)
                   (eldoc-box-scroll-down))))

(map! :n "y" #'evil-yank
      :n "p" #'evil-paste-after
      :n "<backtab>" #'evil-prev-buffer
      :n "M-h" #'evil-window-left
      :n "M-j" #'evil-window-down
      :n "M-k" #'evil-window-up
      :n "M-l" #'evil-window-right)
;; :n "C-j" #'eldoc-box-scroll-up
;; :n "C-k" #'eldoc-box-scroll-down)

;; Eglot mode bindings
(map! :map eglot-mode-map
      :n "E" #'my/show-error-at-point)
;; :n "K" (if (display-graphic-p)
;;            #'eldoc-box-help-at-point
;;          #'eldoc))
(defun my/lsp-ui-doc-show-and-focus ()
  "Show lsp-ui-doc and focus into it for scrolling."
  (interactive)
  (lsp-ui-doc-show)
  (lsp-ui-doc-focus-frame))

(map! :map lsp-mode-map
      :n "K" #'my/lsp-ui-doc-show-and-focus)

(set-popup-rule! "^\\*vterm-claude\\*" :ignore t)

(defun my/claude-terminal ()
  "Open Claude CLI in a right side window."
  (interactive)
  (let ((claude-buffer "*vterm-claude*"))
    (unless (get-buffer claude-buffer)
      (let ((buf (generate-new-buffer claude-buffer)))
        (with-current-buffer buf
          (vterm-mode)
          (vterm-send-string "claude\n"))))
    (let ((win (display-buffer-in-side-window
                (get-buffer claude-buffer)
                '((side . right)
                  (slot . 0)
                  (window-width . 0.45)))))
      (select-window win))))

(map! :leader
      :desc "Claude Terminal" "o c" #'my/claude-terminal)
