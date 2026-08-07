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
(use-package doom-themes
  :defer t)
;; :ensure t
;; :config
;; (load-theme 'doom-moonlight t))
;; (load-theme 'kanagawa-wave)
;; (use-package kusanagi-theme
;;   :vc (:url "https://github.com/LionyxML/kusanagi-theme" :rev :newest)
;;   :ensure t
;;   :config
;;   (load-theme 'kusanagi t))


;;; Leuven theme
;; (load-theme 'leuven t)
;; (defvar my/code-weight 'medium)
;; (defun my/unthin-faces (&optional _theme)
;;   "Leuven hardcodes :weight normal on many faces; re-assert weight."
;;   (dolist (face '(font-lock-keyword-face
;;                   font-lock-function-name-face
;;                   font-lock-variable-name-face
;;                   font-lock-type-face
;;                   font-lock-constant-face
;;                   font-lock-builtin-face
;;                   font-lock-string-face
;;                   font-lock-comment-face
;;                   font-lock-doc-face))
;;     (when (facep face)
;;       (set-face-attribute face nil :weight my/code-weight :slant 'normal)))
;;   ;; pure white halates badly with astigmatism
;;   (set-face-background 'default "#FBFAF7")
;;   ;; Leuven's comment gray is too low-contrast
;;   (set-face-foreground 'font-lock-comment-face "#5F6368"))

;; (add-hook 'enable-theme-functions #'my/unthin-faces)

(use-package base16-theme
  :ensure t 
  :config
  (load-theme 'base16-catppuccin-mocha t))


;; Override Nord's background with the deep slate from your image
;; (custom-set-faces
;;  '(default ((t (:background "#162635"))))
;;  '(fringe  ((t (:background "#162635"))))
;;  '(tab-line ((t (:background "#1A3042" :foreground "#162635"))))
;;  '(line-number ((t (:background "#162635"))))
;;  '(centaur-tabs-selected
;;    ((t (:background "#1A3042" :foreground "#A5D4DE"))))
;;  '(centaur-tabs-unselected
;;    ((t (:background "#162635" :foreground "#618D9D"))))
;;  '(mode-line ((t (:background "#1A3042")))))

;; used for base16-tokyodark-terminal theme
;; (custom-set-faces
;;  ;; '(default ((t (:background "#0d0d0d"))))          ; main bg
;;  '(fringe  ((t (:background "#11121d"))))          ; fringe matches
;;  '(line-number ((t (:background "#11121d")))))     ; line number gutter
;; ;; '(mode-line ((t (:background "#111111")))))      ; slightly darker modeline

(use-package nerd-icons)
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
        dashboard-show-shortcuts nil
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-set-navigator t
        dashboard-projects-backend 'project-el
        dashboard-items '((recents   . 5)
                          ;; (agenda    . 5)
                          (projects . 5)
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
      (kbd "gr")  #'dashboard-refresh-buffer
      (kbd "f") #'elfeed)))

(setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
(require 'escape-dashboard)
(add-hook 'emacs-startup-hook #'escape t)

(provide 'init-ui)
;;; init-ui.el ends here
