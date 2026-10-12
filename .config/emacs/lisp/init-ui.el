;;; init-ui.el -*- lexical-binding:t ; -*-

;;; Code:
;;;; Tabs
(setq switch-to-buffer-obey-display-actions nil)
(use-package centaur-tabs
  :demand
  :init
  (setq centaur-tabs-style                "chamfer"
        centaur-tabs-set-bar              'left
        centaur-tabs-gray-out-icons       'buffer
        centaur-tabs-height               25
        centaur-tabs-set-icons            t
        centaur-tabs-icon-type            'nerd-icons
        centaur-tabs-set-modified-marker  t
        centaur-tabs-modified-marker      "●"
        centaur-tabs-set-close-button     nil
        centaur-tabs-show-new-tab-button  nil
        centaur-tabs-cycle-scope          'tabs
        centaur-tabs-adjust-buffer-order  'right)
  :config
  (centaur-tabs-mode t)
  (centaur-tabs-change-fonts my/font-family 110)  ; function call goes here
  (centaur-tabs-headline-match)
  (centaur-tabs-group-by-projectile-project)
  (defun centaur-tabs-hide-tab (x)
    (let ((name (format "%s" x)))
      (or (string-prefix-p "*" name)
          (string-prefix-p "magit" name)
          (string-prefix-p " " name)
          (with-current-buffer x
            (memq major-mode '(dired-mode treemacs-mode dashboard-mode)))))))

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

;;;; Theme + modeline
;; for kanagawa only
;; (use-package autothemer
;;   :ensure t)
;; (load-theme 'kanagawa t)
(use-package base16-theme
  :ensure t
  :demand t
  :init
  (setq base16-theme-256-color-source 'colors)   ; MUST be before load-theme
  :config
  (load-theme 'base16-spaceduck t))
;; (use-package kusanagi-theme
;;   :vc (:url "https://github.com/LionyxML/kusanagi-theme"
;; 	        :rev :newest)
;;   :config
;;   (load-theme 'kusanagi t))
;; (load-theme 'sexy t)
;; (load-theme 'sexy-light t)
;; (load-theme 'gruber-darker t)

;; (use-package solarized-theme   ; provides solarized-gruvbox-light
;;   :ensure t
;;   :config (load-theme 'solarized-gruvbox-light t))
;; (use-package tokyo-night
;;   :ensure t
;;   :config (load-theme 'tokyo-night))

(defvar my/bg     "#0e0f1d" "Dimmed buffer background.")
(defvar my/gutter "#0a0a14" "Dimmed chrome: gutter, mode line, tab bar.")

(defun my/dim-ui (&rest _)
  "Darken the background, gutter, mode line and tab bar."
  ;; buffer + gutter
  (set-face-attribute 'default nil :background my/bg)
  (set-face-attribute 'fringe  nil :background my/bg)
  (set-face-attribute 'line-number nil
                      :background my/gutter :foreground "#3c4270")
  (set-face-attribute 'line-number-current-line nil
                      :background my/gutter :foreground "#b3a1e6" :weight 'bold)
  ;; mode line
  (dolist (f '(mode-line mode-line-active))
    (when (facep f)
      (set-face-attribute f nil :background my/gutter :foreground "#ecf0c1"
                          :box `(:line-width (1 . 1) :color ,my/gutter))))
  (set-face-attribute 'mode-line-inactive nil
                      :background my/gutter :foreground "#686f9a"
                      :box `(:line-width (1 . 1) :color ,my/gutter))
  (with-eval-after-load 'doom-modeline
    (set-face-attribute 'doom-modeline-bar nil :background "#b3a1e6")
    (set-face-attribute 'doom-modeline-bar-inactive nil :background my/gutter))
  ;; tab bar
  (with-eval-after-load 'centaur-tabs
    (set-face-attribute 'centaur-tabs-default nil
                        :background my/gutter :foreground my/gutter)
    (set-face-attribute 'centaur-tabs-unselected nil
                        :background my/gutter :foreground "#686f9a")
    (set-face-attribute 'centaur-tabs-selected nil
                        :background my/bg :foreground "#ecf0c1")
    (set-face-attribute 'centaur-tabs-unselected-modified nil
                        :background my/gutter :foreground "#686f9a")
    (set-face-attribute 'centaur-tabs-selected-modified nil
                        :background my/bg :foreground "#b3a1e6")
    (set-face-attribute 'centaur-tabs-active-bar-face nil :background "#b3a1e6")
    (set-face-attribute 'centaur-tabs-modified-marker-selected nil
                        :background my/bg :foreground "#e39400")
    (set-face-attribute 'centaur-tabs-modified-marker-unselected nil
                        :background my/gutter :foreground "#686f9a")
    (centaur-tabs-headline-match)))

(my/dim-ui)
;; re-apply whenever a theme is (re-)enabled, e.g. the treemacs re-enable
(add-hook 'enable-theme-functions #'my/dim-ui)

(defun my/tty-transparent-bg (&optional frame)
  "Let the terminal's own background show through on TTY FRAMEs."
  (unless (display-graphic-p frame)
    (set-face-background 'default "unspecified-bg" frame)))

(add-hook 'window-setup-hook #'my/tty-transparent-bg)
(add-hook 'server-after-make-frame-hook #'my/tty-transparent-bg)


(use-package nerd-icons
  :config
  (setq nerd-icons-color-icons t))
(with-eval-after-load 'nerd-icons
  (dolist (spec '((nerd-icons-lblue   . "#7FB4CA")   ; springBlue
                  (nerd-icons-blue    . "#7E9CD8")   ; crystalBlue
                  (nerd-icons-purple  . "#957FB8")   ; oniViolet
                  (nerd-icons-green   . "#98BB6C")   ; springGreen
                  (nerd-icons-orange  . "#FFA066")   ; surimiOrange
                  (nerd-icons-yellow  . "#E6C384")   ; carpYellow
                  (nerd-icons-red     . "#E46876"))) ; waveRed
    (set-face-attribute (car spec) nil :foreground (cdr spec))))

(use-package doom-modeline
  :init (doom-modeline-mode 1))
(doom-modeline-def-segment buffer-info
  (concat (doom-modeline--buffer-mode-icon) " " (doom-modeline--buffer-name) " "))

(use-package flycheck
  :ensure t
  :hook (prog-mode . global-flycheck-mode))

(use-package flycheck-eglot
  :ensure t
  :after (flycheck eglot)
  :config (global-flycheck-eglot-mode 1))
(use-package consult-flycheck :ensure t :after (consult flycheck))


;;;; Dashboard
(use-package dashboard
  :init
  (setq dashboard-startup-banner (expand-file-name "banners/functional.png" user-emacs-directory)
        dashboard-image-banner-max-height 300
        dashboard-image-banner-max-width 300
        dashboard-center-content t
        dashboard-vertically-center-content t
        dashboard-show-shortcuts t
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-set-navigator t
        dashboard-icon-type 'nerd-icons
        dashboard-projects-backend 'project-el
        dashboard-items '((recents   . 8)
                          ;; (agenda    . 5)
                          ))
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
      (kbd "gr")  #'dashboard-refresh-buffer
      (kbd "f") #'elfeed)))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
(require 'escape-dashboard)
(add-hook 'emacs-startup-hook #'escape t)
(with-eval-after-load 'dashboard
  (set-face-attribute 'dashboard-items-face nil :foreground 'unspecified))

(provide 'init-ui)
;;; init-ui.el ends here
