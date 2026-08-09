;; init-langs.el -*- lexical-binding: t; -*-

;;;; Code:
;;;; Language modes
(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode)))

(use-package toml-mode)

(use-package rustic
  :init (setq rustic-lsp-client 'eglot))
;;;; Racket
(use-package racket-mode
  :mode ("\\.rkt\\'" . racket-mode)
  :hook ((racket-mode . racket-xp-mode)          ; background check + xref + eldoc
         (racket-repl-mode . racket-xp-mode))
  :config
  (setq racket-show-functions '(racket-show-echo-area))) ; hints in echo area, not overlays

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
(defun my/rust-fmt-on-save ()
  "Format the current Rust buffer in place via eglot (rust-analyzer)."
  (when (and (derived-mode-p 'rust-ts-mode 'rustic-mode)
             (eglot-managed-p))
    (eglot-format)))
(defun my/clang-fmt-on-save ()
  "Run eglot-format on save for C/C++ buffers."
  (when (and (derived-mode-p 'c-mode 'c++-mode 'c-ts-mode 'c++-ts-mode)
             (eglot-managed-p))
    (eglot-format)))

(defun my/racket-fmt-on-save ()
  "Indent whole Racket buffer on save."
  (when (derived-mode-p 'racket-mode)
    (indent-region (point-min) (point-max))))

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
       :command '("cmake" "-B" "build" "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
       :sentinel (lambda (_proc event)
                   (when (string-match-p "finished" event)
                     (message "CMake finished, restarting Eglot...")
                     (dolist (buf (buffer-list))
                       (with-current-buffer buf
                         (when (and (derived-mode-p 'c-mode 'c++-mode 'c-ts-mode 'c++-ts-mode)
                                    (fboundp 'eglot-managed-p)
                                    (eglot-managed-p))
                           (eglot-reconnect (eglot-current-server)))))))))))


(add-hook 'before-save-hook #'my/rust-fmt-on-save)
(add-hook 'after-save-hook #'my/auto-cmake-on-save)
(add-hook 'before-save-hook #'my/clang-fmt-on-save)
(add-hook 'before-save-hook #'my/racket-fmt-on-save)

(provide 'init-langs)
;;; init-langs.el ends here
