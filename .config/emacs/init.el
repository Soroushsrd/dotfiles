;; init.el -*- lexical-binding: t; -*-

(setq shell-file-name "/bin/bash")
(setq explicit-shell-file-name "/bin/bash")
;;; Custom file — keep machine-generated junk out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs/themes/"))
(add-to-list 'load-path              (expand-file-name "~/.config/emacs/themes/"))
(load custom-file 'noerror)
(let ((dir (expand-file-name "~/.rbenv/shims")))
  (add-to-list 'exec-path dir)
  (setenv "PATH" (concat dir ":" (getenv "PATH"))))


;;;; Package setup
(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(defun my/load (file)
  "Load FILE from the lisp/ subdirectory of 'user-emacs-directory'."
  (load (expand-file-name (concat "lisp/" file) user-emacs-directory)
        nil 'nomessage))

;; order matters
(my/load "init-defaults")
(my/load "init-treesit")   
(my/load "init-evil")
(my/load "init-lsp")
(my/load "init-org")
(my/load "escape-dashboard")
(my/load "init-ui")
(my/load "init-tools")
(my/load "init-langs")

(with-eval-after-load 'evil
  (evil-set-initial-state 'escape-mode 'emacs))
