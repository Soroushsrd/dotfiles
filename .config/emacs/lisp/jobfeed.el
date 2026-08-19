;;; jobfeed.el --- viewer config for jobs.org -*- lexical-binding: t; -*-

;; Everything here is configuration. There is no mode to write: org-agenda
;; already does what elfeed-search-mode does, it just needs telling what to
;; show and how to sort it.

(defvar jobfeed-file (expand-file-name "~/org/jobs.org"))

;;; Faces ---------------------------------------------------------------

;; State at a glance, the way elfeed distinguishes unread. Kanagawa palette.
(setq org-todo-keyword-faces
      '(("NEW"       . (:foreground "#7fb4ca" :weight bold))
        ("APPLIED"   . (:foreground "#e6c384" :weight bold))
        ("CALLBACK"  . (:foreground "#98bb6c" :weight bold))
        ("INTERVIEW" . (:foreground "#e46876" :weight bold))
        ("OFFER"     . (:foreground "#957fb8" :weight bold))
        ("REJECTED"  . (:foreground "#727169"))
        ("SKIP"      . (:foreground "#54546d"))))

;;; Sorting by score ----------------------------------------------------

(defun jobfeed--entry-score (entry)
  "Read the SCORE property of an agenda ENTRY line."
  (let ((marker (get-text-property 0 'org-marker entry)))
    (if marker
        (string-to-number (or (org-entry-get marker "SCORE") "0"))
      0)))

(defun jobfeed-cmp-score (a b)
  "Comparator for `org-agenda-cmp-user-defined'. Higher score first."
  (let ((sa (jobfeed--entry-score a))
        (sb (jobfeed--entry-score b)))
    (cond ((> sa sb) +1)
          ((< sa sb) -1))))

;;; Opening a posting ---------------------------------------------------

(defun jobfeed-open-url ()
  "Open the URL property of the entry at point in a browser."
  (interactive)
  (let* ((marker (or (org-get-at-bol 'org-marker) (point-marker)))
         (url (org-entry-get marker "URL")))
    (if url (browse-url url) (message "jobfeed: no URL on this entry"))))

;;; Agenda views --------------------------------------------------------

;; Scoping org-agenda-files inside each command matters: adding jobs.org to
;; the global list would drop several hundred job entries into your normal
;; agenda, which you do not want.
(setq org-agenda-custom-commands
      `(("j" . "Jobs")

        ("jn" "New postings, best first"
         tags-todo "TODO=\"NEW\""
         ((org-agenda-files (list jobfeed-file))
          (org-agenda-overriding-header "New postings")
          (org-agenda-cmp-user-defined #'jobfeed-cmp-score)
          (org-agenda-sorting-strategy '(user-defined-down))
          (org-agenda-prefix-format '((tags . "  ")))))

        ("ja" "In flight"
         tags-todo "TODO=\"APPLIED\"|TODO=\"CALLBACK\"|TODO=\"INTERVIEW\""
         ((org-agenda-files (list jobfeed-file))
          (org-agenda-overriding-header "Applications in flight")))

        ("jr" "Rust and compilers only"
         tags-todo "TODO=\"NEW\""
         ((org-agenda-files (list jobfeed-file))
          (org-agenda-overriding-header "Rust / compiler roles")
          (org-agenda-cmp-user-defined #'jobfeed-cmp-score)
          (org-agenda-sorting-strategy '(user-defined-down))
          ;; Regexp filter over the headline, applied on top of the score gate
          ;; the fetcher already did.
          (org-agenda-filter-by-regexp "rust\\|compiler\\|llvm\\|embedded")))))

;;; Keys ----------------------------------------------------------------

;; `b' is org-agenda-earlier by default, which does nothing useful in a tags
;; view. Reclaiming it is safe here.
(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "b") #'jobfeed-open-url))

(provide 'jobfeed)
;;; jobfeed.el ends here
