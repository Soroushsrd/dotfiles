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
;;;; LSP — Eglot
(use-package eglot
  :ensure t
  :hook ((rustic-mode  . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (c-mode       . eglot-ensure)
         (c++-mode     . eglot-ensure)
         (c-ts-mode    . eglot-ensure)
         (c++-ts-mode  . eglot-ensure)
         (eglot-managed-mode . eglot-inlay-hints-mode))
  :init
  (setq eglot-stay-out-of '(yasnippet))
  :config
  (setq eglot-connect-timeout 60
        eglot-events-buffer-config '(:size 2000000 :format full)
        eglot-sync-connect 10
        eglot-send-changes-idle-time 0.1)
  (setq-default eglot-workspace-configuration
                '(:rust-analyzer
                  (:inlayHints
                   (:typeHints (:enable t)
                               :closureReturnTypeHints (:enable "always")
                               :parameterHints (:enable t)
                               :chainingHints (:enable t)
                               :lifetimeElisionHints (:enable "skip_trivial")))))
  (add-to-list 'eglot-server-programs
               '(rust-ts-mode . ("rust-analyzer")))
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
                  "--query-driver=/usr/bin/g++-*,/usr/bin/clang++-*"))))


;; Inlay hint face
(with-eval-after-load 'eglot
  (set-face-attribute 'eglot-inlay-hint-face nil :foreground "#54546D" :height 0.8))

(with-eval-after-load 'eglot
  (defvar-local my/inlay-refresh-timer nil)
  (defun my/force-inlay-refresh ()
    (when (and (bound-and-true-p eglot-inlay-hints-mode)
               (eglot-managed-p))
      ;; clear stale hints on the whole buffer, then re-request the visible window
      (eglot--update-hints-1 (point-min) (point-max))))
  (defun my/schedule-inlay-refresh (&rest _)
    (when (timerp my/inlay-refresh-timer)
      (cancel-timer my/inlay-refresh-timer))
    (setq my/inlay-refresh-timer
          (run-with-idle-timer 0.5 nil #'my/force-inlay-refresh)))
  (add-hook 'eglot-managed-mode-hook
            (lambda ()
              (add-hook 'after-change-functions
                        #'my/schedule-inlay-refresh nil t))))


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


;; ;; K to show docs (Doom-style)
;; (with-eval-after-load 'evil
;;   (with-eval-after-load 'eglot
;;     (evil-define-key 'normal eglot-mode-map
;;       (kbd "K") (lambda ()
;;                   (interactive)
;;                   (if (display-graphic-p)
;;                       (eldoc-box-help-at-point)
;;                     (eldoc))))))
;; K to show docs (Doom-style)
(defun my/lsp-doc-at-point ()
  "Show docs at point: child frame in GUI, *eldoc* window in TTY."
  (interactive)
  (if (display-graphic-p)
      (eldoc-box-help-at-point)
    (eldoc)                    ; kick off a fresh async hover request
    (run-at-time 0.15 nil (lambda () (eldoc-doc-buffer t)))))

(with-eval-after-load 'evil
  (with-eval-after-load 'eglot
    (evil-define-key 'normal eglot-mode-map
      (kbd "K") #'my/lsp-doc-at-point)))
(provide 'init-lsp)
;;; init-lsp.el ends here
