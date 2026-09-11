;;; init-defaults.el -*- lexical-binding: t; -*-

;;; Code:
;;;; Sane defaults
(setq frame-resize-pixelwise t)
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

(setq display-line-numbers-type 'absolute)
(global-display-line-numbers-mode)

;;;; opam
(let ((opam-bin (expand-file-name "~/.opam/default/bin"))
      (opam-lib (expand-file-name "~/.opam/default/lib")))
  (when (file-directory-p opam-bin)
    (add-to-list 'exec-path opam-bin)
    (setenv "PATH" (concat opam-bin path-separator (getenv "PATH")))
    (setenv "OPAM_SWITCH_PREFIX" (expand-file-name "~/.opam/default"))
    (setenv "CAML_LD_LIBRARY_PATH"
            (concat opam-lib "/stublibs" path-separator
                    opam-lib "/ocaml/stublibs" path-separator
                    opam-lib "/ocaml"))))

;;;; Fonts
;; (defvar my/font-family "Robotomono Nerd Font Propo")
(defvar my/font-family "Jetbrainsmono Nerd Font Propo")
(set-face-attribute 'default nil
                    :family my/font-family
                    ;; :family "JetBrainsMono Nerd Font"
                    :height 130
                    :weight 'bold)
(set-face-attribute 'fixed-pitch nil
                    :family my/font-family
                    :height 1.0
                    :weight 'bold
                    :slant 'italic)
(set-face-attribute 'variable-pitch nil
                    :family "Inter"
                    :height 1.0)

(setq-default line-spacing 0.15)

;;;; Clipboard (Wayland)
(setq wl-copy-process nil)

(defun wl-copy (text)
  "Set copying settings for the TEXT."
  (setq wl-copy-process (make-process :name "wl-copy"
                                      :buffer nil
                                      :command '("wl-copy" "-f" "-n")
                                      :connection-type 'pipe
                                      :noquery t))
  (process-send-string wl-copy-process text)
  (process-send-eof wl-copy-process))

(defun wl-paste ()
  "Set pasting settings."
  (if (and wl-copy-process (process-live-p wl-copy-process))
      nil
    (with-temp-buffer
      (call-process "wl-paste" nil t nil "-n")
      (call-process-region (point-min) (point-max) "tr" t t nil "-d" "\r")
      (buffer-string))))

(setq interprogram-cut-function 'wl-copy
      interprogram-paste-function 'wl-paste)

;; project roots
(with-eval-after-load 'project
  (setq project-find-functions
        (cons 'project-try-vc (remq 'project-try-vc project-find-functions)))
  (setq project-vc-extra-root-markers
        '("dune-project" "mix.exs" "build.zig" "compile_commands.json" ".project")))
(setopt xterm-update-cursor t)

(provide 'init-defaults)
;;; init-defaults.el ends here
