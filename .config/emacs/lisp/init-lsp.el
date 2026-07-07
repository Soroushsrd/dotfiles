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

;;;; LSP — Eglot
(defun my/rust-kick-semantic-tokens ()
  "Force eglot to re-request semantic tokens by generating a no-op edit.
Runs once rust-analyzer is responsive, since a phantom didChange is what
actually invalidates eglot's token cache."
  (when (and (eglot-managed-p)
             (derived-mode-p 'rust-ts-mode 'rustic-mode))
    (let ((buf (current-buffer))
          (attempts 0))
      (cl-labels
          ((ready-p ()
             (let ((server (eglot-current-server)))
               (and server
                    (ignore-errors
                      (jsonrpc-request
                       server :textDocument/documentSymbol
                       (list :textDocument (eglot--TextDocumentIdentifier))
                       :timeout 0.5)
                      t))))
           (kick ()
             (with-current-buffer buf
               (let ((inhibit-modification-hooks nil)
                     (modified (buffer-modified-p)))
                 (save-excursion
                   (goto-char (point-min))
                   ;; Phantom edit: insert then delete a space.
                   ;; This fires didChange (twice), invalidating eglot's
                   ;; semantic-tokens cache and forcing a real re-fetch.
                   (insert " ")
                   (delete-char -1))
                 ;; Restore the unmodified flag so we don't dirty the buffer.
                 (unless modified (set-buffer-modified-p nil)))))
           (poll ()
             (when (and (buffer-live-p buf) (< attempts 60)) ; ~30s ceiling
               (with-current-buffer buf
                 (if (ready-p)
                     (kick)
                   (cl-incf attempts)
                   (run-with-timer 0.5 nil #'poll))))))
        (run-with-timer 0.5 nil #'poll)))))

(add-hook 'eglot-managed-mode-hook #'my/rust-kick-semantic-tokens)

(use-package eglot
  :ensure t
  :hook ((rustic-mode  . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (c-mode       . eglot-ensure)
         (zig-ts-mode . eglot-ensure)
         (c++-mode     . eglot-ensure)
         (c-ts-mode    . eglot-ensure)
         (c++-ts-mode  . eglot-ensure)
         (tuareg-mode  . eglot-ensure))
  :init
  (setq eglot-stay-out-of '(yasnippet))
  :config
  (setq eglot-connect-timeout 60
        eglot-events-buffer-size 2000000
        eglot-sync-connect 10
        eglot-send-changes-idle-time 0.1)
  (setq-default eglot-workspace-configuration
                '(:rust-analyzer
                  (:inlayHints
                   (:typeHints (:enable t)
                               :closureReturnTypeHints (:enable "always")
                               :parameterHints (:enable t)
                               :chainingHints (:enable t)))))
  (add-to-list 'eglot-server-programs
               '(rust-ts-mode . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs
               '((zig-ts-mode zig-mode) . ("zls")))
  (add-to-list 'eglot-server-programs
               '(cmake-mode . ("neocmakelsp" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode c-ts-mode c++-ts-mode) .
                 ("clangd"
                  "--background-index"
                  "--clang-tidy"
                  "--completion-style=detailed"
                  "--header-insertion=iwyu"
                  "--header-insertion-decorators=1"
                  "--fallback-style=llvm"
                  "--query-driver=/usr/bin/g++-*,/usr/bin/clang++-*")))
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
  (set-face-attribute 'eldoc-box-border nil :background "#444444"))


;; K to show docs (Doom-style)
(with-eval-after-load 'evil
  (with-eval-after-load 'eglot
    (evil-define-key 'normal eglot-mode-map
      (kbd "K") (lambda ()
                  (interactive)
                  (if (display-graphic-p)
                      (eldoc-box-help-at-point)
                    (eldoc))))))
