;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!
(add-to-list 'exec-path "/home/rusty/.opam/default/bin")

(setenv "PATH" (concat "/home/rusty/.opam/default/bin:" (getenv "PATH")))

(load-file "~/kanagawa-theme-source-code.el")
(load-file "~/Downloads/gotham-theme-source-code.el")
(load-file "~/Downloads/suscolors-theme-source-code.el")
(setq doom-theme 'kanagawa)
;; (setq doom-theme 'catppuccin)
;; (setq catppuccin-flavor 'mocha)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font Propo" :size 15 :weight 'extrabold))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:

(after! company
  (custom-set-faces
   '(company-tooltip-selection ((t (:background "#3a3f5a" :foreground "#ffffff"))))))
;; (setq doom-theme 'doom-gruvbox)
;; (custom-set-faces!
;;   '(default :background "#000000"))
;; (setq doom-theme 'doom-feather-dark)
;; (setq doom-theme 'doom-winter-is-coming-dark-blue)
;; (setq doom-theme 'doom-tokyo-night)
;; (setq doom-theme 'catppuccin)
;; (after! doom-themes
;;   (custom-set-faces!
;;     '(default :background "#000000")
;;     '(mode-line :foreground "#ffffff")
;;     '(treemacs-window-background-face :background "#000000")
;;     '(dired-header :background "#000000")))

;; (after! solaire-mode
;;   (solaire-global-mode -1))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(after! org
  (setq org-agenda-files (list (expand-file-name "tasks.org" org-directory)))
  (setq org-directory "~/org/"))

(setq org-todo-keywords
      '((sequence "TODO(t)" "PROG(p)" "DONE(d)")))

;; color coding
(setq org-todo-keyword-faces
      '(("TODO" . (:foreground "#ff6c6b" :weight bold))
        ("PROG" . (:foreground "#ECBE7B" :weight bold))
        ("DONE" . (:foreground "#98be65" :weight bold))))

;;custom commands
(setq org-agenda-custom-commands
      '(("n" "My Weekly Agenda"
         ((agenda "" ((org-agenda-span 'week)))
          (todo "PROG" ((org-agenda-overriding-header "In Progress")))
          (todo "TODO" ((org-agenda-overriding-header "To Do:")))
          (todo "DONE" ((org-agenda-overriding-header "Done"))))
         nil)))

;; archive completed tasks
(setq org-archive-location "~/org/archive.org::* Archived Tasks")

;; autosave tasks file when idle
(add-hook 'org-mode-hook
          (lambda ()
            (when (string-match-p "tasks\\.org$" (buffer-file-name))
              (auto-save-mode 1))))

;; tags for categorization
(setq org-tag-alist '((:startgroup . nil)
                      ("work" . ?w)
                      ("daily" . ?p)
                      ("project" . ?j)
                      ("meeting" . ?m)
                      ("urgent" . ?u)
                      (:endgroup . nil)))
(after! org
  ;; Set up working capture templates
  (setq org-capture-templates
        '(("t" "Todo" entry
           (file+headline "~/org/tasks.org" "Inbox")
           "** TODO %?\n   CREATED: %U\n")

          ("w" "Work Task" entry
           (file+headline "~/org/tasks.org" "Work Tasks")
           "** TODO %?\n   CREATED: %U\n")

          ("p" "Personal" entry
           (file+headline "~/org/tasks.org" "Personal")
           "** TODO %?\n   CREATED: %U\n"))))

;; Bind capture to a convenient key
(map! :leader
      :desc "Org capture" "c" #'org-capture)
;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;


;; For copy and pate operations
(setq select-enable-clipboard t
      select-enable-primary t)
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
      nil ; Don't paste if we just copied
    (with-temp-buffer
      (call-process "wl-paste" nil t nil "-n")
      (call-process-region (point-min) (point-max) "tr" t t nil "-d" "\r")
      (buffer-string))))

(setq interprogram-cut-function 'wl-copy)
(setq interprogram-paste-function 'wl-paste)

;;;;;;;;;;;;;;;;;;; LSP ;;;;;;;;;;;;;;;


(use-package! eglot
  :hook ((tuareg-mode . eglot-ensure)
         (rust-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (c++-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs
               '(tuareg-mode . ("ocamllsp")))
  (add-to-list 'eglot-server-programs
               '(rust-mode . ("rust-analyzer")))
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) . ("clangd")))

  ;; Optional: clangd specific settings for better performance
  (setq eglot-connect-timeout 60)
  (add-to-list 'eglot-server-programs
               '((c-mode c++-mode) .
                 ("clangd"
                  "--background-index"
                  "--clang-tidy"
                  "--completion-style=detailed"
                  "--header-insertion=never"))))

;; Company completion settings (applies to all modes)
(after! company
  (setq company-idle-delay 0.0
        company-minimum-prefix-length 1))

(use-package! eldoc-box
  ;; :hook (eglot-managed-mode . eldoc-box-hover-mode)
  :config
  (setq eldoc-box-max-pixel-width 800
        eldoc-box-max-pixel-height 600
        eldoc-box-position-function #'eldoc-box--default-at-point-position-function-1)
  (set-face-attribute 'eldoc-box-border nil
                      :background "#444444")
  (set-face-attribute 'eldoc-box-body nil
                      :background "#1a1a1a"
                      :foreground "#ffffff"))
(after! eldoc-box
  ;; For documentation strings with code
  (custom-set-faces!
    '(font-lock-doc-markup-face :background "#1a1a1a")))

(defun my/show-error-at-point ()
  "Show eldoc box only if there's an error/warning at current point."
  (interactive)
  (when (bound-and-true-p eglot--managed-mode)
    (let ((diagnostics (flymake-diagnostics (point))))
      (if diagnostics
          (eldoc-box-help-at-point)
        (message "No diagnostics at point")))))


(after! lsp-rust
  (setq lsp-rust-analyzer-cargo-watch-enable t))

(defun my/cargo-fmt-all ()
  "Run 'cargo fmt --all' in the project root and refresh diagnostics."
  (when (and (derived-mode-p 'rust-mode 'rustic-mode)
             (locate-dominating-file default-directory "Cargo.toml"))
    (let ((project-root (locate-dominating-file default-directory "Cargo.toml"))
          (current-buffer (current-buffer)))
      (set-process-sentinel
       (start-process "cargo-fmt" nil "cargo" "fmt" "--all")
       (lambda (process event)
         (when (string-match-p "finished" event)
           (with-current-buffer current-buffer
             (revert-buffer t t t)
             ;; Refresh diagnostics after formatting
             (when (eglot-managed-p)
               (run-with-timer 0.5 nil
                               (lambda ()
                                 (eglot--signal-textDocument/didChange)
                                 (eglot--signal-textDocument/didSave))))
             (message "cargo fmt completed and diagnostics refreshed"))))))))

;; (defun my/cargo-check ()
;;   "Run 'cargo check  in the project root without creating buffers."
;;   (when (and (derived-mode-p 'rust-mode 'rustic-mode)
;;              (locate-dominating-file default-directory "Cargo.toml"))
;;     (let ((project-root (locate-dominating-file default-directory "Cargo.toml"))
;;           (current-buffer (current-buffer)))
;;       (set-process-sentinel
;;        (start-process "cargo-check" nil "cargo" "check")
;;        (lambda (process event)
;;          (when (string-match-p "finished" event)
;;            (with-current-buffer current-buffer
;;              (revert-buffer t t t))
;;            (message "cargo check completed")))))))
;; (add-hook 'after-save-hook #'my/cargo-check)
(add-hook 'after-save-hook #'my/cargo-fmt-all)
;; ;
;;;;;;;;;;;;;;;;;; KEYBINDINGS ;;;;;;;;;;;;;;;
(map! :map eglot-mode-map
      :n "K" #'eldoc-box-help-at-point)

(map! :n
      :desc "Scroll eldoc up" "C-j" #'eldoc-box-scroll-up
      :desc "Scroll eldoc down" "C-k" #'eldoc-box-scroll-down)

(map! :map eglot-mode-map
      :n "E" #'my/show-error-at-point)

(map! :leader
      :desc "Go to next error" "n e" #'merlin-error-next)
;; (map! :leader
;;       :desc "Show error under cursor" "E" #'merlin-eldoc--merlin-error-at-point-p)

(map! :n "y" #'evil-yank)

(map! :n "p" #'evil-paste-after)

(map! :leader
      :desc "Paste from outside the editor" "v" #'wl-paste)

(map! :leader
      :desc "Toggle vterm" "t t" #'+vterm/toggle)

(map! :leader
      :desc "Toggle treemacs" "\\" #'+treemacs/toggle)

(map! :leader
      :desc "Toggle treemacs" "t m" #'+treemacs/toggle)

(map! :leader
      :desc "Next Buffer" "TAB" #'evil-next-buffer)
(map! :n
      :desc "Previous buffer" "<backtab>" #'evil-prev-buffer)


(map! :n "M-h" #'evil-window-left
      :n "M-j" #'evil-window-down
      :n "M-k" #'evil-window-up
      :n "M-l" #'evil-window-right)

(map! :leader
      :desc "List errors" "e" #'flycheck-list-errors)

(map! :leader
      :desc "Open tasks file" "o t" (lambda () (interactive) (find-file "~/org/tasks.org"))
      :desc "Custom agenda view" "o n" (lambda () (interactive) (org-agenda nil "n")))

;;;;;;;;;;;;;;;;; Editor ;;;;;;;;;;;;;;;;;;;;;;
;; Set transparency (alpha value: 0-100, where 100 is opaque)
(add-to-list 'default-frame-alist '(alpha-background . 90))
(set-frame-parameter nil 'alpha-background 90)

(setq scroll-margin 20
      scroll-conservatively 101
      scroll-preserve-screen-position t)


(setq confirm-kill-emacs nil)

(use-package wakatime-mode
  :ensure t)
(global-wakatime-mode)

(setq +latex-viewers '(zathura))


(with-eval-after-load 'eglot
  (custom-set-faces
   '(eglot-inlay-hint-face ((t (:foreground "#54546D" :height 0.8))))))



(after! pdf-tools
  ;; === THEME & COLORS ===

  ;; Dark mode for PDFs
  ;; (setq pdf-view-midnight-colors '("#ffffff" . "#1e1e1e")) ; white text on dark bg
  ;; (setq pdf-view-midnight-colors '("#c7c7c7" . "#2b2b2b")) ; softer contrast
  (setq pdf-view-midnight-colors '("#f8f8f2" . "#282828")) ; gruvbox-like
  ;; (setq pdf-view-midnight-colors '("#839496" . "#002b36")) ; solarized dark

  (add-hook 'pdf-view-mode-hook 'pdf-view-midnight-minor-mode)

  (setq pdf-view-display-size 'fit-page) ; Options: fit-width, fit-height, fit-page, or a number
  (setq pdf-view-resize-factor 1.1) ; How much to zoom in/out with +/-
  (setq pdf-view-use-scaling t) ; Enable scaling for better quality
  (setq pdf-view-use-imagemagick nil) ; Disable imagemagick (can be slow)
  (setq pdf-view-continuous t) ; Scroll continuously between pages
  (setq pdf-view-page-spacing 2) ; Pixels between pages
  ;; === MODELINE CUSTOMIZATION ===
  ;; Custom modeline format
  (setq pdf-view-mode-line-indicator
        '(" PDF"
          (pdf-view-midnight-minor-mode " ☾")
          " [" (:eval (number-to-string (pdf-view-current-page)))
          "/" (:eval (number-to-string (pdf-cache-number-of-pages)))
          "]")))


;; (after! cc-mode
;;   (add-hook 'c-mode-hook #'lsp!)
;;   (add-hook 'c++-mode-hook #'lsp!))

;; (after! company
;;   (setq company-idl-delay 0.0
;;         company-minimum-prefix-length 1))

;; Auto-install tree-sitter grammars
(setq treesit-language-source-alist
      '((cpp "https://github.com/tree-sitter/tree-sitter-cpp")
        (c "https://github.com/tree-sitter/tree-sitter-c")))

;; Run this once to install all grammars
;; (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))
(use-package! avoid
  :config
  (mouse-avoidance-mode 'exile))
