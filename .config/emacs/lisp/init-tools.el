;; init-tools.el -*- lexical-binding: t; -*-

;;; Code:
;;;; PDF
(use-package reader
  :load-path "~/.config/emacs/elpa/emacs-reader"
  :mode ("\\.\\(epub\\|mobi\\|fb2\\|cbz\\|xps\\)\\'" . reader-mode))

(use-package saveplace-pdf-view
  :ensure t
  :after pdf-tools
  :init (save-place-mode 1))
;;;; ClaudeCode
(use-package eat
  :commands (eat eat-other-window))

(use-package claudemacs
  :vc (:url "https://github.com/cpoile/claudemacs")
  :commands (claudemacs-transient-menu)
  :config
  (with-eval-after-load 'eat
    (setq eat-term-scrollback-size 400000)))

;;;; File tree — Treemacs
(use-package treemacs
  :defer t
  :config
  (setq treemacs-width 35
        treemacs-follow-after-init t
        treemacs-is-never-other-window t
        treemacs-sorting 'alphabetic-asc
        treemacs-show-hidden-files t
        treemacs-no-png-images nil
        treemacs-indentation 2)
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-fringe-indicator-mode 'always)
  (treemacs-git-mode 'deferred))

(use-package treemacs-evil  :after (treemacs evil))
(use-package treemacs-nerd-icons
  :after treemacs
  :config (treemacs-load-theme "nerd-icons"))

(use-package treemacs-magit :after (treemacs magit))

(defun my/treemacs-here ()
  "Open treemacs rooted at the current file's directory.  Toggle if already visible."
  (interactive)
  (let* ((file (buffer-file-name))
         (dir (or (when-let ((proj (project-current)))
                    (project-root proj))
                  (if file (file-name-directory file) default-directory))))
    (require 'treemacs)
    (cond
     ((eq (treemacs-current-visibility) 'visible)
      (delete-window (treemacs-get-local-window)))
     (t
      (let* ((project-name (file-name-nondirectory (directory-file-name dir)))
             (workspace (treemacs-current-workspace)))
        (dolist (proj (treemacs-workspace->projects workspace))
          (treemacs-do-remove-project-from-workspace proj 'ignore-last-project-restriction))
        (treemacs-do-add-project-to-workspace dir project-name)
        (treemacs)
        (when (and file (file-exists-p file))
          (ignore-errors (treemacs-goto-file-node file))))))))

(defun my/project-root ()
  "Return the current projec root or 'default-directory' if none."
  (if-let ((proj (project-current)))
      (project-root proj)
    default-directory))

;;;; Git
(use-package magit
  :defer t
  :config
  (setq magit-bury-buffer-function #'magit-restore-window-configuration))


(use-package diff-hl
  :ensure t
  :hook (after-init . global-diff-hl-mode)
  :config
  (add-hook 'diff-hl-mode-on-hook
            (lambda ()
              (unless (display-graphic-p)
                (diff-hl-margin-local-mode)))))

;;;; Terminal
(use-package vterm
  :commands (vterm vterm-other-window)
  :config
  (setq vterm-max-scrollback 10000
        vterm-shell "/usr/bin/nu"
        vterm-timer-delay 0.01))

(defun my/vterm-toggle ()
  "Toggle a vterm buffer at the bottom of the frame.  Kill the window+buffer automatically when the shell process exits."
  (interactive)
  (let ((buf (get-buffer "*vterm*")))
    (cond
     ;; already visible → hide it
     ((and buf (get-buffer-window buf))
      (delete-window (get-buffer-window buf)))
     ;; exists but hidden → show it
     (buf
      (let ((win (split-window-below -15)))
        (select-window win)
        (switch-to-buffer buf)
        (evil-insert-state)))
     ;; doesn't exist → create it
     (t
      (let ((default-directory (my/project-root))
            (win (split-window-below -15)))
        (select-window win)
        (vterm))))))

(defun my/vterm-exit-cleanup (buf _event)
  "Close the window showing BUF when its shell exits."
  (when (buffer-live-p buf)
    (let ((win (get-buffer-window buf)))
      (when (and win (not (one-window-p t)))
        (delete-window win)))))

(with-eval-after-load 'vterm
  (setq vterm-kill-buffer-on-exit t)
  (add-hook 'vterm-exit-functions #'my/vterm-exit-cleanup))

(use-package elfeed
  :commands (elfeed elfeed-update)
  :config
  (setq elfeed-feeds
        '(;; --- existing emacs ---
          ("https://irreal.org/blog/?feed=rss2"                emacs blog)
          ("https://nullprogram.com/feed/"                     emacs blog)
          ("http://yummymelon.com/devnull/feeds/all.atom.xml"  emacs blog)
          ("https://karthinks.com/index.xml"                   emacs blog)
          ("https://xania.org/rss/Coding"                      compilers cpp)
          ("https://xania.org/rss/Rust"                        compilers rust)

          ;; --- compilers / LLVM / PLT ---
          ("https://blog.regehr.org/feed"                      compilers undefined-behavior)  ; John Regehr — UB, fuzzing, LLVM
          ("https://mcyoung.xyz/index.xml"                     compilers llvm)               ; you've read his SSA post
          ("https://blog.yossarian.net/feed.xml"               compilers llvm security)      ; William Woodruff — LLVM IR explainers
          ("https://eli.thegreenplace.net/feeds/all.atom.xml"  compilers low-level)          ; Eli Bendersky — deep compiler/syscall posts
          ("https://www.cs.cornell.edu/~asampson/blog/feed.xml" compilers plt)               ; Adrian Sampson — runs CS 6120 (compilers)
          ("https://www.jntrnr.com/atom.xml"                   compilers rust)               ; JT — nushell/Rust compiler internals
          ("https://www.philipzucker.com/rss.xml"              plt category-theory)          ; abstract interpretation, categorical stuff
          ("https://lambdaland.org/index.xml"                  plt scheme)                   ; Ashton Wiersdorf — Scheme/PL
          ("https://bernsteinbear.com/feed.xml"                compilers plt)                ; Max Bernstein — runtime/compiler posts
          ("https://wingolog.org/feed/atom"                    compilers plt)                ; Andy Wingo — Guile, JIT, GC, deep stuff
          ("https://lobste.rs/t/compilers.rss"                 compilers aggregator)         ; lobste.rs compiler tag

          ;; --- rust / systems ---
          ("https://fasterthanli.me/index.xml"                 rust systems)                 ; Amos — long-form Rust internals
          ("https://matklad.github.io/feed.xml"                rust ide compilers)           ; rust-analyzer's author
          ("https://without.boats/index.xml"                   rust async)                   ; withoutboats — async Rust design
          ("https://blog.cliffle.com/rss.xml"                  rust embedded systems)        ; Cliff Biffle — embedded Rust, RTOS
          ("https://blog.rust-lang.org/feed.xml"               rust official)
          ("https://this-week-in-rust.org/rss.xml"             rust news)
          ("https://www.ralfj.de/blog/feed.rss"                rust unsafe semantics)        ; Ralf Jung — MiriFlow, stacked borrows
          ("https://smallcultfollowing.com/babysteps/atom.xml" rust language-design)         ; Niko Matsakis

          ;; --- low-level / performance / HFT-adjacent ---
          ("https://lemire.me/blog/feed/"                      performance simd)             ; Daniel Lemire — SIMD, bit hacks, perf
          ("https://travisdowns.github.io/feed.xml"            performance cpu)              ; Travis Downs — CPU performance
          ("https://easyperf.net/blog/feed.xml"                performance cpu)              ; Denis Bakhvalov — perf engineering
          ("https://danluu.com/atom.xml"                       systems performance)          ; Dan Luu — performance, systems

          ;; --- c++ ---
          ("https://www.modernescpp.com/index.php?format=feed&type=rss" cpp)                 ; Rainer Grimm
          ("https://artificial-mind.net/blog/rss.xml"          cpp graphics)
          ("https://herbsutter.com/feed/"                      cpp)
          ("https://devblogs.microsoft.com/cppblog/feed/"      cpp msvc))))



(use-package wakatime-mode
  :ensure t
  :init
  (global-wakatime-mode)
  :config
  (setq wakatime-cli-path (expand-file-name "~/.wakatime/wakatime-cli")))

(add-hook 'org-mode-hook
          (lambda ()
            (setq fill-column 85)
            (auto-fill-mode 1)))
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do)))

(provide 'init-tools)
;;; init-tools.el ends here

