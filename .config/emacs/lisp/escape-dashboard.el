;;; escape-dashboard.el --- The one thing in your face every day  -*- lexical-binding: t; -*-

;; A zero-dependency Emacs dashboard that removes the daily decision.
;; Open Emacs -> it tells you today's single lane and one action.
;; No menus, no choices. Log with one keystroke, close the buffer, go.

;;; --- Config -------------------------------------------------------

(defvar escape/exit-deadline "2027-06-13"
  "The date you lose the ability to leave.")

(defvar escape/data-file (expand-file-name "escape-progress.el" user-emacs-directory)
  "Where counts persist between sessions.")

(defvar escape/job-boards
  '("rustjobs.dev  (apply free, no LinkedIn needed)"
    "hnhiring.com/technologies/rust  (HN Who-is-hiring, monthly)"
    "arbeitnow.com/visa-sponsorship-jobs"
    "arc.dev/remote-jobs/rust")
  "Boards your wife runs in the Apply lane.")

;; lane per weekday: 0=Sun .. 6=Sat
(defvar escape/lanes
  '((1 . oss) (3 . oss) (5 . oss)   ; Mon Wed Fri
    (2 . apply) (4 . apply)         ; Tue Thu
    (6 . reach)                     ; Sat
    (0 . free)))                    ; Sun

(defvar escape/lane-spec
  '((oss   . ("OSS LANE"   "Open ONE small Rust PR. Merged > perfect."
              "rust-lang, tokio, datafusion, polars, or a sponsoring infra repo"))
    (apply . ("APPLY LANE" "Wife's 5 leads -> apply to the 3 strongest. Warm threads first."
              "Germany primary. NL opportunistic. Trading/fintech = your FIX edge."))
    (reach . ("REACH LANE" "2 warm DMs on Twitter. Ask for ONE intro or referral."
              "You are THE Rust guy. Use it. One ask, then stop."))
    (free  . ("FREE LANE"  "Spiral freely. Category theory, Zig, TAPL, whatever."
              "Sanctioned. Guilt-free. This is what keeps the weekdays holding."))))

;;; --- State --------------------------------------------------------

(defvar escape/counts '((pr . 0) (app . 0) (reach . 0)))

(defun escape/load ()
  (when (file-exists-p escape/data-file)
    (with-temp-buffer
      (insert-file-contents escape/data-file)
      (ignore-errors (setq escape/counts (read (current-buffer)))))))

(defun escape/save ()
  (with-temp-file escape/data-file
    (prin1 escape/counts (current-buffer))))

(defun escape/bump (key)
  (setf (alist-get key escape/counts)
        (1+ (or (alist-get key escape/counts) 0)))
  (escape/save)
  (escape/render))

(defun escape/days-left ()
  (let ((diff (- (time-to-days (date-to-time (concat escape/exit-deadline "T00:00:00")))
                 (time-to-days (current-time)))))
    (max 0 diff)))

;;; --- Render -------------------------------------------------------

(defface escape/big '((t :height 1.8 :weight bold)) "Big.")
(defface escape/lane '((t :height 1.4 :weight bold :foreground "#1D9E75")) "Lane.")
(defface escape/dim '((t :foreground "#888780")) "Dim.")
(defface escape/warn '((t :weight bold :foreground "#D85A30")) "Warn.")

(defun escape/today-lane ()
  (alist-get (string-to-number (format-time-string "%w")) escape/lanes))

(defun escape/render ()
  (with-current-buffer (get-buffer-create "*escape*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (let* ((lane (escape/today-lane))
             (spec (alist-get lane escape/lane-spec))
             (days (escape/days-left)))
        (insert "\n")
        (insert (propertize (format "  %s days to get out\n"
                                    days)
                            'face (if (< days 200) 'escape/warn 'escape/big)))
        (insert (propertize (format "  PRs %d   ·   Applications %d   ·   Reaches %d\n\n"
                                    (alist-get 'pr escape/counts)
                                    (alist-get 'app escape/counts)
                                    (alist-get 'reach escape/counts))
                            'face 'escape/dim))
        (insert (propertize "  ─────────────────────────────────────────\n\n" 'face 'escape/dim))
        (insert (propertize (format "  TODAY: %s\n" (nth 0 spec)) 'face 'escape/lane))
        (insert (format "\n  %s\n" (nth 1 spec)))
        (insert (propertize (format "  → %s\n\n" (nth 2 spec)) 'face 'escape/dim))
        (insert (propertize "  ─────────────────────────────────────────\n\n" 'face 'escape/dim))
        (when (eq lane 'apply)
          (insert (propertize "  Boards:\n" 'face 'escape/dim))
          (dolist (b escape/job-boards)
            (insert (format "    • %s\n" b)))
          (insert "\n"))
        (insert (propertize "  [p] +PR    [a] +application    [r] +reach\n" 'face 'escape/dim))
        (insert (propertize "  [g] refresh    [q] close and go work\n" 'face 'escape/dim)))
      (goto-char (point-min))
      (escape-mode))
    (switch-to-buffer "*escape*")))

;;; --- Mode ---------------------------------------------------------

(defvar escape-mode-map
  (let ((m (make-sparse-keymap)))
    (define-key m "p" (lambda () (interactive) (escape/bump 'pr)))
    (define-key m "a" (lambda () (interactive) (escape/bump 'app)))
    (define-key m "r" (lambda () (interactive) (escape/bump 'reach)))
    (define-key m "g" (lambda () (interactive) (escape/render)))
    (define-key m "q" #'quit-window)
    m))

(define-derived-mode escape-mode special-mode "Escape"
  "Your daily lane. No decisions.")

;;;###autoload
(defun escape ()
  "Show the dashboard."
  (interactive)
  (escape/load)
  (escape/render))


(provide 'escape-dashboard)
;;; escape-dashboard.el ends here
