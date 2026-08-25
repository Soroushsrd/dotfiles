;;; init-evil.el -*- lexical-binding: t; -*-

;;;; Evil
(use-package evil
  :init
  (setq evil-want-keybinding nil)
  (setq evil-want-integration t)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-Y-yank-to-eol t)
  (setq evil-undo-system 'undo-redo)
  (setq evil-split-window-below t)
  (setq evil-vsplit-window-right t)
  :config
  (evil-mode 1)
  (global-evil-surround-mode 1))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package evil-surround
  :config (global-evil-surround-mode 1))

(use-package evil-commentary
  :config (evil-commentary-mode))

;;;; Leader keys
(use-package general
  :config
  (general-evil-setup)
  (general-create-definer my/leader-def
    :states '(normal visual motion)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC"))

(with-eval-after-load 'evil
  (evil-define-key 'normal 'global
    (kbd "TAB")       #'centaur-tabs-forward
    (kbd "<backtab>") #'centaur-tabs-backward))

(my/leader-def
  ;; Top-level
  "SPC" '(execute-extended-command :which-key "M-x")
  "f f"   '(find-file :which-key "dired")
  "/"   '(consult-ripgrep :which-key "search project")
  "e"    '(consult-flycheck :which-key "diagnostics")

  ;; ClaudeCode

  "a a" '(claudemacs-transient-menu   :which-key "claudemacs")
  "a t" '(claudemacs-toggle-buffer    :which-key "toggle claude")
  "a s" '(claudemacs-switch-to-session :which-key "switch session")

  ;; Files
  "f p" '((lambda () (interactive) (find-file user-init-file)) :which-key "edit init.el")
  "f s" '(save-buffer :which-key "save")
  "'" '(my/treemacs-here :which-key "Open file tree")

  ;; Buffers
  "b b" '(switch-to-buffer :which-key "switch buffer")
  "b B" '(consult-buffer :which-key "consult buffer")
  "b d" '(kill-current-buffer :which-key "close tab")
  "b k" '(kill-buffer :which-key "kill buffer")
  "b n" '(next-buffer :which-key "next buffer")
  "b p" '(previous-buffer :which-key "prev buffer")
  "b r" '(revert-buffer :which-key "revert")
  "b s" '((lambda () (interactive) (switch-to-buffer "*scratch*")) :which-key "scratch")

  ;; Windows
  "w h" '(evil-window-left :which-key "win left")
  "w j" '(evil-window-down :which-key "win down")
  "w k" '(evil-window-up :which-key "win up")
  "w l" '(evil-window-right :which-key "win right")

  ;; Search
  "s s" '(consult-line :which-key "search buffer")
  "s i" '(consult-imenu :which-key "imenu")

  ;; Code (eglot)
  "c a" '(eglot-code-actions :which-key "code action")
  "c r" '(eglot-rename :which-key "rename")
  "c f" '(eglot-format :which-key "format")
  "c d" '(xref-find-definitions :which-key "definition")
  "c R" '(xref-find-references :which-key "references")

  ;; Git
  "g g" '(magit-status :which-key "magit")

  ;; Project
  "p p" '(project-switch-project :which-key "switch project")
  "p f" '(project-find-file :which-key "find file in project")

  ;; Org
  "o a" '(org-agenda :which-key "agenda")
  "o c" '(org-capture :which-key "capture")
  "o n" '((lambda () (interactive) (org-agenda nil "n")) :which-key "weekly view")
  "o t" '((lambda () (interactive) (find-file "~/org/tasks.org")) :which-key "tasks file")

  ;; Terminal
  "t t" '(my/vterm-toggle :which-key "toggle vterm")
  "t T" '(vterm :which-key "vterm fullscreen")


  ;; C++ templates
  "m p" '(cpp-template-new-project :which-key "new project")
  "m c" '(cpp-template-new-class :which-key "new class")
  "m h" '(cpp-template-new-header-only-class :which-key "header-only class")
  "m m" '(cpp-template-insert-method :which-key "insert method")
  "m g" '(cpp-template-insert-getter-setter :which-key "getter/setter")
  "m s" '(cpp-template-insert-singleton-pattern :which-key "singleton")
  "m r" '(cpp-template-insert-smart-ptr-typedef :which-key "smart ptr typedef")
  "m i" '(cpp-template-insert-pimpl-pattern :which-key "PIMPL")

  ;; Help
  "h f" '(describe-function :which-key "describe function")
  "h v" '(describe-variable :which-key "describe variable")
  "h k" '(describe-key      :which-key "describe key")
  "h m" '(describe-mode     :which-key "describe mode")

  ;; Quit
  "q q" '(save-buffers-kill-terminal :which-key "quit")
  "q r" '(restart-emacs :which-key "restart"))

;; Window navigation — Meta+hjkl
(with-eval-after-load 'evil
  (dolist (state '(normal motion))
    (evil-define-key state 'global
      (kbd "M-h") #'evil-window-left
      (kbd "M-j") #'evil-window-down
      (kbd "M-k") #'evil-window-up
      (kbd "M-l") #'evil-window-right)))

(add-hook 'prog-mode-hook
          (lambda ()
            (local-set-key (kbd "RET") #'newline-and-indent)))

;;;; which-key
(use-package which-key
  :ensure nil ;; built-in
  :config
  (setq which-key-idle-delay 0.3)
  (which-key-mode))
