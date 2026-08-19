;;; init-org.el -*- lexical-binding:t ; -*-
(use-package org
  :ensure nil
  :init
  (setq org-directory "~/org/")
  :bind (("C-c c" . org-capture)
         ("C-c s" . org-todo-list)
         ("C-c a" . org-agenda))
  :hook (org-babel-after-execute . org-redisplay-inline-images)
  :config
  (setq org-todo-keywords
        '((sequence "TODO(t)" "PROG(p)" "|" "DONE(d)"))
        org-todo-keyword-faces
        '(("TODO" . (:foreground "#ff6c6b" :weight bold))
          ("PROG" . (:foreground "#ECBE7B" :weight bold))
          ("DONE" . (:foreground "#98be65" :weight bold)))
        org-agenda-files (list (expand-file-name "tasks.org" org-directory))
        org-archive-location "~/org/archive.org::* Archived Tasks"
        org-return-follows-link t
        org-log-done 'time
        org-log-into-drawer t
        org-confirm-babel-evaluate nil
        org-startup-with-inline-images t
        ;; refile
        org-refile-targets '((org-agenda-files . (:maxlevel . 3)))
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        ;; agenda
        org-agenda-start-on-weekday 1
        org-agenda-skip-scheduled-if-done t
        org-agenda-skip-deadline-if-done t
        org-capture-templates
        '(("t" "Todo" entry
           (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\nSCHEDULED: %^t\n:PROPERTIES:\n:CREATED: %U\n:END:\n" :empty-lines 1)
          ("w" "Work Task" entry
           (file+headline "~/org/tasks.org" "Work Tasks")
           "* TODO %?\nSCHEDULED: %^t\n:PROPERTIES:\n:CREATED: %U\n:END:\n" :empty-lines 1)
          ("p" "Personal" entry
           (file+headline "~/org/tasks.org" "Personal")
           "* TODO %?\nSCHEDULED: %^t\n:PROPERTIES:\n:CREATED: %U\n:END:\n" :empty-lines 1))

        org-agenda-custom-commands
        '(("n" "My Weekly Agenda"
           ((agenda "" ((org-agenda-span 'week)
                        (org-deadline-warning-days 7)))
            (todo "PROG" ((org-agenda-overriding-header "In Progress")))
            (todo "TODO" ((org-agenda-overriding-header "Next Up")
                          (org-agenda-max-entries 10))))))))

(require 'jobfeed)
(use-package org-ql :ensure t)
(defun my/jobfeed-agenda ()
  "Show new jobs sorted by date."
  (interactive)
  (org-ql-search jobfeed-file
    '(and (todo "NEW") (property "SCORE"))
    :sort '(date)))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :init
  (setq evil-org-key-theme '(navigation return insert textobjects additional calendar))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

;;; --- org beautification ---
(setq org-startup-indented t
      org-hide-emphasis-markers t   ; required by org-appear
      org-pretty-entities t
      org-ellipsis "…")

(use-package org-modern
  :ensure t
  :hook ((org-mode . org-modern-mode)
         (org-agenda-finalize . org-modern-agenda))
  :config
  (setq org-modern-star 'replace
        org-modern-hide-stars 'leading
        org-modern-table-vertical 1
        org-modern-block-name '("" . "")
        org-modern-todo-faces
        '(("TODO" :background "#ff6c6b" :foreground "#1c1f24" :weight bold)
          ("PROG" :background "#ECBE7B" :foreground "#1c1f24" :weight bold)
          ("DONE" :background "#98be65" :foreground "#1c1f24" :weight bold))))

(use-package org-modern-indent
  :vc (:url "https://github.com/jdtsmith/org-modern-indent" :rev :newest)
  :hook (org-mode . org-modern-indent-mode))

(use-package org-appear
  :ensure t
  :hook (org-mode . org-appear-mode)
  :config
  (setq org-appear-autoemphasis t
        org-appear-autolinks t
        org-appear-autosubmarkers t
        org-appear-trigger 'manual)      ; evil needs manual
  (add-hook 'org-mode-hook
            (lambda ()
              (add-hook 'evil-insert-state-entry-hook
                        #'org-appear-manual-start nil t)
              (add-hook 'evil-insert-state-exit-hook
                        #'org-appear-manual-stop nil t))))

(use-package valign
  :ensure t
  :hook (org-mode . valign-mode))

(provide 'init-org)
;;; init-org.el ends here
