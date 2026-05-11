;;; init.el -*- lexical-binding: t; -*-

;;; Custom file — keep machine-generated junk out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "~/.config/emacs/themes/"))
(load custom-file 'noerror)

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

;;;; Sane defaults
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 100)

(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      ring-bell-function 'ignore
      use-short-answers t
      scroll-margin 20
      scroll-conservatively 50
      scroll-preserve-screen-position t
      select-enable-clipboard t
      select-enable-primary t
      confirm-kill-emacs nil)

(global-auto-revert-mode 1)
(setq auto-revert-verbose nil)
(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(setq show-paren-delay 0)

(recentf-mode 1)
(setq recentf-max-saved-items 200)

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)

;;;; Fonts
(set-face-attribute 'default nil
                    :family "CaskaydiaCove Nerd Font Propo"
                    :height 120 :weight 'semibold)
(setq-default line-spacing 0.15)

;;;; Clipboard (Wayland)
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
  (evil-mode 1))

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

  ;; Files
  "f p" '((lambda () (interactive) (find-file user-init-file)) :which-key "edit init.el")
  "f s" '(save-buffer :which-key "save")

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

  ;; File tree
  "'"   '(my/treemacs-here :which-key "file tree (here)")

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

;;;; which-key
(use-package which-key
  :config
  (setq which-key-idle-delay 0.3)
  (which-key-mode))

;;;; Tabs
(setq switch-to-buffer-obey-display-actions nil)
(use-package centaur-tabs
  :demand
  :init
  (setq centaur-tabs-style                "bar"
        centaur-tabs-set-bar              'over
        centaur-tabs-height               32
        centaur-tabs-set-icons            t
        centaur-tabs-icon-type            'nerd-icons
        centaur-tabs-set-modified-marker  t
        centaur-tabs-modified-marker      "●"
        centaur-tabs-set-close-button     nil
        centaur-tabs-show-new-tab-button  nil
        centaur-tabs-cycle-scope          'tabs
        centaur-tabs-adjust-buffer-order  'right)
        ;; centaur-tabs-label-fixed-length   8)  ; pads label to fixed width → more breathing room
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-change-fonts "CaskaydiaCove Nerd Font Propo" 110)  ; function call goes here
  (centaur-tabs-headline-match)
  (centaur-tabs-group-by-projectile-project)
  (defun centaur-tabs-hide-tab (x)
    (let ((name (format "%s" x)))
      (or (string-prefix-p "*" name)
          (string-prefix-p "magit" name)
          (string-prefix-p " " name)
          (memq (with-current-buffer name major-mode)
                '(dired-mode treemacs-mode dashboard-mode))))))

;;;; Theme face overrides
;; Run after sexy-theme is loaded so our faces win.
(defun my/apply-face-overrides ()
  ;; ── Italic faces ─────────────────────────────────────────────────────────
  ;; (set-face-attribute 'font-lock-function-name-face nil
  ;;                     :slant 'italic)          ; fn foo(
  (set-face-attribute 'font-lock-type-face nil
                      :slant 'italic)          ; struct/enum/type names
  (set-face-attribute 'font-lock-keyword-face nil
                      :slant 'italic)          ; fn, let, pub, use, impl …
  (set-face-attribute 'font-lock-comment-face nil
                      :slant 'italic)          ; // comments
  ;; ── Variable / let-binding highlight ─────────────────────────────────────
  ;; tree-sitter (rust-ts-mode) exposes these faces:
  (set-face-attribute 'font-lock-variable-name-face nil
                      :foreground "#957FB8"   
                      :weight 'bold)
  ;; ── Method / function calls ───────────────────────────────────────────
  (set-face-attribute 'font-lock-function-name-face nil
                      :foreground "#7FB4CA"))


(add-hook 'after-init-hook #'my/apply-face-overrides)

;; If you ever reload the theme interactively, re-apply:
(advice-add 'load-theme :after (lambda (&rest _) (my/apply-face-overrides)))

;;;; Dired
(use-package dired
  :ensure nil
  :hook (dired-mode . dired-hide-details-mode)
  :config
  (setq dired-dwim-target t
        dired-recursive-copies 'always
        dired-recursive-deletes 'always
        dired-listing-switches "-alh --group-directories-first"
        delete-by-moving-to-trash t)
;; Evil-friendly keybinds inside dired
  (with-eval-after-load 'evil
    (evil-define-key 'normal dired-mode-map
      (kbd "h")   #'dired-up-directory
      (kbd "l")   #'dired-find-file
      (kbd "q")   #'quit-window
      ;; ── file creation ──────────────────────────────────────────────
      (kbd "m")   #'dired-create-directory   ; mkdir
      (kbd "a")   #'dired-create-empty-file  ; touch  (Emacs 27+)
      ;; wdired: enter with C-x C-q or "W", rename by editing, C-c C-c to commit
      (kbd "W")   #'wdired-change-to-wdired-mode)))

(use-package dired-x
  :ensure nil
  :after dired)

;;;; Completion framework
(use-package vertico :init (vertico-mode))
(use-package savehist :init (savehist-mode))
(use-package marginalia :init (marginalia-mode))
(use-package orderless
  :init (setq completion-styles '(orderless basic)
              completion-category-overrides
              '((file (styles basic partial-completion)))))
(use-package consult)
(use-package embark)
(use-package embark-consult :after (embark consult))
(use-package company
  :hook (after-init . global-company-mode)
  :config (setq company-idle-delay 0.0
                company-minimum-prefix-length 1))

;;;; LSP — Eglot
(use-package eglot
  :ensure nil
  :hook ((rust-mode    . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (c-mode       . eglot-ensure)
         (c++-mode     . eglot-ensure)
         (c-ts-mode    . eglot-ensure)
         (c++-ts-mode  . eglot-ensure)
         (tuareg-mode  . eglot-ensure))
  :init
  (setq eglot-stay-out-of '(yasnippet))
  :config
  (setq eglot-connect-timeout 60
        eglot-events-buffer-size 0
        eglot-autoshutdown t
        eglot-send-changes-idle-time 0.5)
  (add-to-list 'eglot-server-programs
               '(cmake-mode . ("neocmakelsp" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode) .
                 ("clangd"
                  "--background-index"
                  "--inlay-hints=true"
                  "--clang-tidy"
                  "--completion-style=detailed"
                  "--header-insertion=never"
                  "--header-insertion-decorators=0"
                  "--compile-commands-dir=build")))
  (add-hook 'eglot-managed-mode-hook #'eglot-inlay-hints-mode))

(with-eval-after-load 'eglot
  (set-face-attribute 'eglot-inlay-hint-face nil :foreground "#54546D" :height 0.8))

;;;; Eldoc + eldoc-box
(use-package eldoc
  :ensure nil
  :config
  (setq eldoc-echo-area-use-multiline-p t
        eldoc-echo-area-prefer-doc-buffer nil
        eldoc-idle-delay 0.1))

(use-package eldoc-box
  :after eldoc
  :config
  (setq eldoc-box-max-pixel-width 800
        eldoc-box-max-pixel-height 600
        eldoc-box-offset '(16 16 16))
  (set-face-attribute 'eldoc-box-border nil :background "#444444")

  (defun my/eldoc-box-bind-quit ()
    (with-current-buffer (get-buffer-create eldoc-box-buffer)
      (local-set-key (kbd "q") #'eldoc-box-quit-frame)
      (local-set-key (kbd "Q") #'eldoc-box-quit-frame)
      (local-set-key [escape]  #'eldoc-box-quit-frame)
      (evil-local-set-key 'normal (kbd "q") #'eldoc-box-quit-frame)
      (evil-local-set-key 'normal [escape]  #'eldoc-box-quit-frame)))

  (advice-add 'eldoc-box-help-at-point :after
              (lambda (&rest _) (my/eldoc-box-bind-quit))))

;; K to show docs (Doom-style)
(with-eval-after-load 'evil
  (with-eval-after-load 'eglot
    (evil-define-key 'normal eglot-mode-map
      (kbd "K") (lambda ()
                  (interactive)
                  (if (display-graphic-p)
                      (eldoc-box-help-at-point)
                    (eldoc))))))

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

;;;; Git
(use-package magit)

(use-package git-gutter
  :hook (prog-mode . git-gutter-mode)
  :config (setq git-gutter:update-interval 0.02))

(use-package git-gutter-fringe
  :after git-gutter
  :config
  (define-fringe-bitmap 'git-gutter-fr:added    [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
  (define-fringe-bitmap 'git-gutter-fr:deleted  [128 192 224 240] nil nil 'bottom))

;;;; Tree-sitter
(setq treesit-language-source-alist
      '((cpp  "https://github.com/tree-sitter/tree-sitter-cpp")
        (c    "https://github.com/tree-sitter/tree-sitter-c")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")))

;;;; Terminal
(use-package vterm
  :commands (vterm vterm-other-window)
  :config
  (setq vterm-max-scrollback 10000
        vterm-shell "/usr/bin/nu"
        vterm-timer-delay 0.01))

(defun my/vterm-toggle ()
  "Toggle a vterm buffer at the bottom of the frame.
   Kills the window+buffer automatically when the shell process exits."
  (interactive)
  (let ((buf (get-buffer "*vterm*")))
    (cond
     ;; already visible → hide it
     ((and buf (get-buffer-window buf))
      (delete-window (get-buffer-window buf)))
     ;; exists but hidden → show it
     (buf
      (let ((win (split-window-below -15)))
        (select-window win)
        (switch-to-buffer buf)))
     ;; doesn't exist → create it
     (t
      (let ((win (split-window-below -15)))
        (select-window win)
        (vterm)
        ;; hook fires when the vterm process (your shell) exits
        (with-current-buffer "*vterm*"
          (add-hook 'vterm-exit-functions
                    (lambda (_buf _event)
                      (let ((w (get-buffer-window "*vterm*")))
                        (when w (delete-window w)))
                      (when (get-buffer "*vterm*")
                        (kill-buffer "*vterm*")))
                    nil :local)))))))

;;;; Theme + modeline
;; (use-package doom-themes)
  ;; :config (load-theme 'doom-molokai t))

(use-package sexy-theme
  :config (load-theme 'sexy t))

(use-package nerd-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1))

;;;; Dashboard
(use-package dashboard
  :init
  (setq dashboard-startup-banner (expand-file-name "banners/rewrite-in-rust.txt" user-emacs-directory)
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-show-shortcuts nil
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-set-navigator t
        dashboard-projects-backend 'project-el
        dashboard-items '((recents   . 5)
                          (projects  . 5)
                          (agenda    . 5)
                          (bookmarks . 5)))
  :config
  (dashboard-setup-startup-hook)
  (set-face-attribute 'dashboard-banner-logo-title nil :foreground "#a855f7" :weight 'bold)
  (with-eval-after-load 'evil
    (evil-define-key 'normal dashboard-mode-map
      (kbd "j")   #'dashboard-next-line
      (kbd "k")   #'dashboard-previous-line
      (kbd "h")   #'dashboard-previous-section
      (kbd "l")   #'dashboard-next-section
      (kbd "RET") #'dashboard-return
      (kbd "gr")  #'dashboard-refresh-buffer)))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

;;;; File tree — Treemacs
(use-package treemacs
  :defer t
  :config
  (setq treemacs-width 35
        treemacs-follow-after-init t
        treemacs-is-never-other-window t
        treemacs-sorting 'alphabetic-asc
        treemacs-show-hidden-files t
        treemacs-no-png-images nil
        treemacs-indentation 2)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-git-mode 'deferred))

(use-package treemacs-evil  :after (treemacs evil))
(use-package treemacs-nerd-icons
  :after treemacs
  :config (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit :after (treemacs magit))

(defun my/treemacs-here ()
  "Open treemacs rooted at the current file's directory. Toggle if already visible."
  (interactive)
  (let* ((file (buffer-file-name))
         (dir (if file (file-name-directory file) default-directory)))
    (require 'treemacs)
    (cond
     ((eq (treemacs-current-visibility) 'visible)
      (delete-window (treemacs-get-local-window)))
     (t
      (let* ((project-name (file-name-nondirectory (directory-file-name dir)))
             (workspace (treemacs-current-workspace)))
        (dolist (proj (treemacs-workspace->projects workspace))
          (treemacs-do-remove-project-from-workspace proj 'ignore-last-project-restriction))
        (treemacs-do-add-project-to-workspace dir project-name)
        (treemacs)
        (when (and file (file-exists-p file))
          (ignore-errors (treemacs-goto-file-node file))))))))

;;;; Language modes
(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode)))

(use-package toml-mode)
(use-package rustic
  :init (setq rustic-lsp-client 'eglot))

;;;; Local lisp
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(defun my/elisp-format-on-save ()
  "Formats lisp code on save."
  (when (eq major-mode 'emacs-lisp-mode)
    (indent-region (point-min) (point-max))))

(add-hook 'before-save-hook #'my/elisp-format-on-save)

(require 'cpp-templates)
(setq cpp-template-author-name "Soroosh Sardashti"
      cpp-template-author-email "sardashtisoroosh@gmail.com"
      cpp-template-std-version "c++23")

(require 'cargo-toml-helper)
(setq cargo-toml-helper-show-inline-versions t)
(add-hook 'toml-mode-hook #'cargo-toml-helper-setup)
(with-eval-after-load 'company
  (add-to-list 'company-backends 'cargo-toml-helper-company-backend))

;;;; Auto-actions on save
(defun my/cargo-fmt-all ()
  "Run 'cargo fmt --all' in the project root and refresh diagnostics."
  (when (and (derived-mode-p 'rust-mode 'rustic-mode)
             (locate-dominating-file default-directory "Cargo.toml"))
    (let ((current-buffer (current-buffer)))
      (set-process-sentinel
       (start-process "cargo-fmt" nil "cargo" "fmt" "--all")
       (lambda (_proc event)
         (when (string-match-p "finished" event)
           (with-current-buffer current-buffer
             (revert-buffer t t t)
             (when (and (fboundp 'eglot-managed-p) (eglot-managed-p))
               (run-with-timer 0.5 nil
                               (lambda ()
                                 (eglot--signal-textDocument/didChange)
                                 (eglot--signal-textDocument/didSave))))
             (message "cargo fmt completed"))))))))

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
       :sentinel (lambda (_proc event)
                   (when (string-match-p "finished" event)
                     (message "CMake finished, restarting Eglot...")
                     (dolist (buf (buffer-list))
                       (with-current-buffer buf
                         (when (and (derived-mode-p 'c-mode 'c++-mode 'c-ts-mode 'c++-ts-mode)
                                    (fboundp 'eglot-managed-p)
                                    (eglot-managed-p))
                           (eglot-reconnect (eglot-current-server)))))))))))

(add-hook 'after-save-hook #'my/cargo-fmt-all)
(add-hook 'after-save-hook #'my/auto-cmake-on-save)

;; Quick setup for EMACS
;;    -------------------
;;    Add opam emacs directory to your load-path by appending this to your .emacs:
;;      (let ((opam-share (ignore-errors (car (process-lines "opam" "var" "share")))))
;;       (when (and opam-share (file-directory-p opam-share))
;;        ;; Register Merlin
;;        (add-to-list 'load-path (expand-file-name "emacs/site-lisp" opam-share))
;;        (autoload 'merlin-mode "merlin" nil t nil)
;;        ;; Automatically start it in OCaml buffers
;;        (add-hook 'tuareg-mode-hook 'merlin-mode t)
;;        (add-hook 'caml-mode-hook 'merlin-mode t)
;;        ;; Use opam switch to lookup ocamlmerlin binary
;;        (setq merlin-command 'opam)
;;        ;; To easily change opam switches within a given Emacs session, you can
;;        ;; install the minor mode https://github.com/ProofGeneral/opam-switch-mode
;;        ;; and use one of its "OPSW" menus.
;;        ))
;;    Take a look at https://github.com/ocaml/merlin for more information
;;;; OCaml
;;;; will uncomment these when i get back to Ocaml
;; (use-package tuareg
;;   :mode (("\\.ml[ily]?\\'" . tuareg-mode)
;;          ("\\.topml\\'"    . tuareg-mode)))

;; (use-package dune)

;; ;; Merlin from opam — only loads if opam is on PATH
;; (let ((opam-share (ignore-errors
;;                     (car (process-lines "opam" "var" "share")))))
;;   (when (and opam-share (file-directory-p opam-share))
;;     (add-to-list 'load-path (expand-file-name "emacs/site-lisp" opam-share))
;;     (autoload 'merlin-mode "merlin" nil t nil)
;;     (setq merlin-command 'opam)))
