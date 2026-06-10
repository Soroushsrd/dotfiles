;;; init-org.el -*- lexical-binding:t ; -*-

;;;; Org
(use-package org
  :ensure nil
  :init
  (setq org-directory "~/org/")
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
        org-confirm-babel-evaluate nil
        org-startup-with-inline-images t
        org-capture-templates
        '(("t" "Todo" entry
           (file+headline "~/org/tasks.org" "Inbox")
           "* TODO %?\n  CREATED: %U\n" :empty-lines 1)
          ("w" "Work Task" entry
           (file+headline "~/org/tasks.org" "Work Tasks")
           "* TODO %?\n  CREATED: %U\n" :empty-lines 1)
          ("p" "Personal" entry
           (file+headline "~/org/tasks.org" "Personal")
           "* TODO %?\n  CREATED: %U\n" :empty-lines 1))
        org-agenda-custom-commands
        '(("n" "My Weekly Agenda"
           ((agenda "" ((org-agenda-span 'week)))
            (todo "PROG" ((org-agenda-overriding-header "In Progress")))
            (todo "TODO" ((org-agenda-overriding-header "To Do")))
            (todo "DONE" ((org-agenda-overriding-header "Done"))))
           nil))))

(use-package evil-org
  :after (evil org)
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))
