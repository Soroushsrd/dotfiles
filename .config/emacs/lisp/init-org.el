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

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :init
  (setq evil-org-key-theme '(navigation insert textobjects additional calendar))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
