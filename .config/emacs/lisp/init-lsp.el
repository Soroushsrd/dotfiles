;;; init-lsp.el -*- lexical-binding:t ; -*-

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

;;;; LSP — lsp-mode
(setq read-process-output-max (* 3 1024 1024)) ; 3mb, rust-analyzer is chatty
(setq gc-cons-threshold 100000000)

(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((rustic-mode  . lsp-deferred)
         (rust-ts-mode . lsp-deferred)
         (c-mode       . lsp-deferred)
         (c++-mode     . lsp-deferred)
         (c-ts-mode    . lsp-deferred)
         (c++-ts-mode  . lsp-deferred)
         (zig-ts-mode  . lsp-deferred)
         (tuareg-mode  . lsp-deferred)
         (lsp-mode     . lsp-enable-which-key-integration))
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-idle-delay 0.3
        lsp-log-io nil                     ; set t only when debugging
        lsp-completion-provider :capf
        lsp-headerline-breadcrumb-enable nil)

  ;; --- Inlay hints 
  (setq lsp-inlay-hint-enable t)

  ;; --- rust-analyzer tuning ---
  (setq lsp-rust-analyzer-server-display-inlay-hints t
        lsp-rust-analyzer-display-parameter-hints t
        lsp-rust-analyzer-display-chaining-hints t
        lsp-rust-analyzer-display-closure-return-type-hints t
        lsp-rust-analyzer-display-lifetime-elision-hints-enable "skip_trivial"
        lsp-inlay-hint-type-format "%s")

  ;; --- clangd
  (setq lsp-clients-clangd-args
        '("--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=iwyu"
          "--header-insertion-decorators=1"
          "--fallback-style=llvm"
          "--query-driver=/usr/bin/g++-*,/usr/bin/clang++-*")))

(setq rustic-treesitter-derive nil)  ; don't layer rust-ts-mode under rustic


;; Inlay hint face 
(with-eval-after-load 'lsp-mode
  (set-face-attribute 'lsp-inlay-hint-face nil :foreground "#54546D" :height 0.8))

;;;; lsp-ui — only for hover docs (K), sideline off
(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-enable nil          
        lsp-ui-doc-enable t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-show-with-cursor nil    
        lsp-ui-doc-show-with-mouse nil
        lsp-ui-doc-max-width 100
        lsp-ui-doc-max-height 25))

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
  (set-face-attribute 'eldoc-box-border nil :background "#444444"))


;; K to show docs (Doom-style) 
(defun my/lsp-bind-K ()
  (evil-local-set-key 'normal (kbd "K") #'lsp-ui-doc-glance))
(add-hook 'lsp-ui-mode-hook #'my/lsp-bind-K)

