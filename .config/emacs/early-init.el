;;; early-init.el -*- lexical-binding: t; -*-
;; Silence native comp warning pop ups(logged to *Warnings*)
(setq native-comp-async-report-warnings-errors 'silent)
(setq package-enable-at-startup nil)
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))
(setq inhibit-startup-message t
      inhibit-startup-screen t
      initial-scratch-message nil)

(setq frame-inhibit-implied-resize t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; Frame defaults (so they apply before the first frame draws)
(add-to-list 'default-frame-alist '(alpha-background . 0.95))
(setq native-comp-speed 2)

