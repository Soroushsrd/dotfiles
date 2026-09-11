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
(use-package corfu
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 1
        corfu-cycle t
        corfu-popupinfo-delay '(0.5 . 0.2)))

(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

(use-package corfu
  :init
  (setq global-corfu-minibuffer
        (lambda ()
          (not (memq this-command
                     '(evil-ex
                       evil-ex-search-forward
                       evil-ex-search-backward
                       evil-ex-search-word-forward
                       evil-ex-search-word-backward)))))
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 1
        corfu-cycle t))

;;;; LSP — lsp-mode
(setq read-process-output-max (* 3 1024 1024)) ; 3mb, rust-analyzer is chatty
(setq gc-cons-threshold 100000000)
;;;; LSP — Eglot
(use-package eglot
  :ensure nil ;; built-in
  :hook ((rustic-mode  . eglot-ensure)
         (rust-ts-mode . eglot-ensure)
         (c-mode       . eglot-ensure)
         (tuareg-mode  . eglot-ensure)
         (c++-mode     . eglot-ensure)
         (c-ts-mode    . eglot-ensure)
         (qml-ts-mode  . eglot-ensure)
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
                               :lifetimeElisionHints (:enable "skip_trivial")))
                  :ocamllsp
                  (:inlayHints
                   (:hintFunctionParams t
                                        :hintPatternVariables t
                                        :hintLetBindings t)
                   :extendedHover (:enable t)
                   :codelens (:enable t))))
  (add-to-list 'eglot-server-programs
               '(rust-ts-mode . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs
               '((tuareg-mode caml-mode) . ("ocamllsp")))
  (add-to-list 'eglot-server-programs
               '(cmake-mode . ("neocmakelsp" "--stdio")))
  (add-to-list 'eglot-server-programs
               `((qml-ts-mode :language-id "qml")
                 . (,(or (executable-find "qmlls")
                         (executable-find "qmlls6")
                         "qmlls")
                    "-E")))
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
  (setq eldoc-box-max-pixel-width
        (lambda () (if (display-graphic-p) 800 (max 40 (- (frame-width) 8))))
        eldoc-box-max-pixel-height
        (lambda () (if (display-graphic-p) 600 (max 8 (/ (frame-height) 3))))
        eldoc-box-offset '(16 16 16))
  ;; visible cursor inside the child frame (upstream sets cursor-type to nil)
  (setf (alist-get 'cursor-type eldoc-box-frame-parameters) 'box)
  ;; distinct background so the frame reads as a popup on a TTY
  (setf (alist-get 'background-color eldoc-box-frame-parameters) "#223249")
  (set-face-attribute 'eldoc-box-body nil :background "#223249" :foreground "#DCD7BA")
  (set-face-attribute 'eldoc-box-border nil :background "#7E9CD8")
  (set-face-attribute 'child-frame-border nil :background "#7E9CD8"))

(defun my/eldoc-box-offset (fn &rest args)
  (let ((eldoc-box-offset (if (display-graphic-p) '(16 16 16) '(2 2 1))))
    (apply fn args)))

(advice-add 'eldoc-box--default-upper-corner-position-function
            :around #'my/eldoc-box-offset)

;; Upstream measures with `window-text-pixel-size' and clamps against
;; (- (frame-pixel-width parent) 32). On a TTY those units are character
;; cells, so the box collapses to one row. Count visible lines instead.
(defun my/eldoc-box--tty-geometry (frame window)
  (let* ((parent (frame-parent frame))
         (max-w (max 20 (- (frame-width parent) 6)))
         (max-h (max 4  (- (frame-height parent) 6)))
         (dims (with-current-buffer (window-buffer window)
                 (save-excursion
                   (goto-char (point-min))
                   (let ((n 0) (w 0))
                     (while (not (eobp))
                       (unless (invisible-p (line-beginning-position))
                         (setq n (1+ n)
                               w (max w (- (line-end-position)
                                           (line-beginning-position)))))
                       (forward-line 1))
                     (cons n w)))))
         (height (max 1 (min max-h (car dims))))
         (width  (max 10 (min max-w (+ 2 (cdr dims)))))
         (frame-resize-pixelwise t)
         (pos (funcall eldoc-box-position-function width height)))
    (set-frame-size frame width height t)
    (set-frame-position frame (car pos) (cdr pos))))

(define-advice eldoc-box--update-childframe-geometry
    (:around (fn frame window) tty-safe)
  (if (display-graphic-p frame)
      (funcall fn frame window)
    (my/eldoc-box--tty-geometry frame window)))
(defun my/lsp-doc-at-point ()
  "Render `eldoc-doc-buffer' in a child frame; focus it if already shown."
  (interactive)
  (if (eldoc-box--frame-visible-p)
      (eldoc-box-focus-frame)
    (eldoc)
    (run-at-time
     0.15 nil
     (lambda ()
       (let ((doc (and (buffer-live-p eldoc--doc-buffer)
                       (with-current-buffer eldoc--doc-buffer
                         (buffer-substring (point-min) (point-max))))))
         (cond
          ((null doc) (message "No documentation at point"))
          ((or (display-graphic-p) (featurep 'tty-child-frames))
           (let ((eldoc-box-position-function eldoc-box-at-point-position-function))
             (eldoc-box--display doc)
             (setq eldoc-box--help-at-point-last-point (point))
             (run-with-timer 0.1 nil #'eldoc-box--help-at-point-cleanup)))
          (t (eldoc-doc-buffer t))))))))

(when (featurep 'tty-child-frames)
  (standard-display-unicode-special-glyphs)
  (tty-tip-mode 1))          ; tooltips in the terminal

(unless (display-graphic-p)
  (prettify-special-glyphs-mode 1))  ; nicer truncation/continuation glyphs


(with-eval-after-load 'evil
  (with-eval-after-load 'eglot
    (evil-define-key 'normal eglot-mode-map
      (kbd "K") #'my/lsp-doc-at-point)))

(provide 'init-lsp)
;;; init-lsp.el ends here
