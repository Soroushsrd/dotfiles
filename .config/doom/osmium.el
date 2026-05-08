;;; doom-osmium-theme.el --- A dark theme with muted purple tones -*- lexical-binding: t; no-byte-compile: t; -*-
;;
;; Author: Bahraam
;; Maintainer: Bahraam
;; Source: Ported from osmium.nvim
;;
;;; Commentary:
;;
;; A dark theme featuring deep purple-blue backgrounds with carefully
;; balanced accent colors for comfortable extended coding sessions.
;;
;;; Code:

(deftheme doom-osmium
  "A dark theme with muted purple tones, ported from osmium.nvim.")

(let ((bg          "#1F1D2D")
      (bg-alt      "#14131E")
      (base0       "#14131E")
      (base2       "#242336")
      (base3       "#353553")
      (base4       "#494764")
      (base5       "#555275")
      (fg          "#DCE4FC")
      (fg-alt      "#A8AFCA")
      (grey        "#8088A8")
      (red         "#E55376")
      (red-dim     "#CA5072")
      (red-bg      "#402030")
      (red-bg-br   "#552B3F")
      (orange      "#EBB17B")
      (orange-bg   "#423531")
      (green       "#C9DE96")
      (green-dim   "#B3C48D")
      (green-bg    "#3B3F37")
      (green-bg-br "#4D5148")
      (yellow      "#F0D89C")
      (yellow-dim  "#D8C490")
      (yellow-bg   "#423C38")
      (yellow-bg-br "#564E4A")
      (blue        "#9ABFE8")
      (blue-dim    "#8CAAD1")
      (blue-bg     "#303849")
      (magenta     "#D9A1E8")
      (magenta-dim "#C091D0")
      (magenta-bright "#E0AAEF")
      (violet      "#B0A8EB")
      (cyan        "#7DCFFF")
      (cyan-dim    "#6BB8E6")
      (lavender    "#D0BFFF")
      (peach       "#D4B8A0")
      (violet-dim  "#9D97D3"))

  (custom-theme-set-variables
   'doom-osmium
   '(frame-background-mode (quote dark)))

  (custom-theme-set-faces
   'doom-osmium

   ;; Base faces
   `(default ((t (:foreground ,fg :background ,bg))))
   `(cursor ((t (:background ,fg))))
   `(hl-line ((t (:background ,base2))))
   `(line-number ((t (:foreground ,grey :background ,base2))))
   `(line-number-current-line ((t (:foreground ,fg-alt :background ,base3 :weight bold))))
   `(lazy-highlight ((t (:foreground ,orange :background ,orange-bg))))
   `(match ((t (:foreground ,orange :background ,orange-bg))))
   `(minibuffer-prompt ((t (:foreground ,blue))))
   `(region ((t (:background ,base3))))
   `(secondary-selection ((t (:background ,base3))))
   `(tooltip ((t (:background ,base3 :foreground ,fg))))
   `(vertical-border ((t (:foreground ,base0))))
   `(window-divider ((t (:foreground ,base0))))
   `(fringe ((t (:background ,bg-alt :foreground ,grey))))
   `(shadow ((t (:foreground ,grey))))
   `(link ((t (:foreground ,blue :underline t))))
   `(link-visited ((t (:foreground ,violet :underline t))))
   `(success ((t (:foreground ,green :weight bold))))
   `(warning ((t (:foreground ,yellow :weight bold))))
   `(error ((t (:foreground ,red :weight bold))))

   ;; Font-lock
   `(font-lock-builtin-face ((t (:foreground ,magenta :weight bold))))
   `(font-lock-comment-face ((t (:foreground ,grey :slant italic))))
   `(font-lock-comment-delimiter-face ((t (:inherit font-lock-comment-face))))
   `(font-lock-constant-face ((t (:foreground ,yellow :weight bold))))
   `(font-lock-doc-face ((t (:foreground ,grey :slant italic))))
   `(font-lock-function-name-face ((t (:foreground ,magenta :weight bold))))
   `(font-lock-keyword-face ((t (:foreground ,green :weight bold))))
   `(font-lock-negation-char-face ((t (:foreground ,fg-alt :weight bold))))
   `(font-lock-preprocessor-face ((t (:foreground ,magenta :slant italic))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,violet))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,violet))))
   `(font-lock-string-face ((t (:foreground ,violet))))
   `(font-lock-type-face ((t (:foreground ,yellow))))
   `(font-lock-variable-name-face ((t (:foreground ,cyan))))
   `(font-lock-property-face ((t (:foreground ,cyan-dim))))
   `(font-lock-warning-face ((t (:foreground ,yellow :weight bold))))
   `(font-lock-bracket-face ((t (:foreground ,fg-alt))))
   `(font-lock-number-face ((t (:foreground ,violet))))
   `(font-lock-operator-face ((t (:foreground ,fg-alt))))
   `(font-lock-punctuation-face ((t (:foreground ,fg-alt))))
   `(font-lock-escape-face ((t (:foreground ,magenta))))

   ;; Doom modeline
   `(doom-modeline-bar ((t (:background ,green-dim))))
   `(doom-modeline-bar-inactive ((t (:background ,base3))))
   `(doom-modeline-buffer-file ((t (:foreground ,fg :weight bold))))
   `(doom-modeline-buffer-path ((t (:foreground ,fg-alt))))
   `(doom-modeline-buffer-modified ((t (:foreground ,orange))))
   `(doom-modeline-project-dir ((t (:foreground ,blue-dim))))
   `(doom-modeline-info ((t (:foreground ,green))))
   `(doom-modeline-warning ((t (:foreground ,yellow))))
   `(doom-modeline-urgent ((t (:foreground ,red))))

   ;; Mode-line
   `(mode-line ((t (:background ,base2 :foreground ,fg-alt))))
   `(mode-line-inactive ((t (:background ,bg :foreground ,grey))))
   `(mode-line-emphasis ((t (:foreground ,fg))))

   ;; Company
   `(company-tooltip ((t (:background ,base3 :foreground ,fg-alt))))
   `(company-tooltip-selection ((t (:background ,base4 :foreground ,fg))))
   `(company-tooltip-common ((t (:foreground ,green))))
   `(company-tooltip-annotation ((t (:foreground ,grey))))
   `(company-scrollbar-bg ((t (:background ,base2))))
   `(company-scrollbar-fg ((t (:background ,green-dim))))

   ;; Corfu
   `(corfu-default ((t (:background ,base3 :foreground ,fg-alt))))
   `(corfu-current ((t (:background ,base4 :foreground ,fg))))
   `(corfu-bar ((t (:background ,green-dim))))
   `(corfu-border ((t (:background ,base5))))

   ;; CSS
   `(css-proprietary-property ((t (:foreground ,orange))))
   `(css-property ((t (:foreground ,green))))
   `(css-selector ((t (:foreground ,magenta))))

   ;; Diff / Ediff
   `(diff-added ((t (:background ,green-bg :foreground ,green))))
   `(diff-changed ((t (:background ,yellow-bg :foreground ,yellow))))
   `(diff-removed ((t (:background ,red-bg :foreground ,red))))
   `(diff-header ((t (:background ,base2 :foreground ,fg))))
   `(diff-file-header ((t (:background ,base3 :foreground ,fg :weight bold))))
   `(diff-refine-added ((t (:background ,green-bg-br :foreground ,green))))
   `(diff-refine-changed ((t (:background ,yellow-bg-br :foreground ,yellow))))
   `(diff-refine-removed ((t (:background ,red-bg-br :foreground ,red))))

   ;; Dired
   `(dired-directory ((t (:foreground ,blue-dim))))
   `(dired-ignored ((t (:foreground ,grey))))

   ;; Flycheck / Flymake
   `(flycheck-error ((t (:underline (:style wave :color ,red-dim)))))
   `(flycheck-warning ((t (:underline (:style wave :color ,yellow-dim)))))
   `(flycheck-info ((t (:underline (:style wave :color ,blue-dim)))))
   `(flymake-error ((t (:underline (:style wave :color ,red-dim)))))
   `(flymake-warning ((t (:underline (:style wave :color ,yellow-dim)))))
   `(flymake-note ((t (:underline (:style wave :color ,blue-dim)))))

   ;; Git-gutter / Diff-hl
   `(git-gutter:added ((t (:foreground ,green))))
   `(git-gutter:modified ((t (:foreground ,yellow))))
   `(git-gutter:deleted ((t (:foreground ,red))))
   `(diff-hl-insert ((t (:foreground ,green :background ,green-bg))))
   `(diff-hl-change ((t (:foreground ,yellow :background ,yellow-bg))))
   `(diff-hl-delete ((t (:foreground ,red :background ,red-bg))))

   ;; Helm
   `(helm-selection ((t (:background ,base3))))
   `(helm-match ((t (:foreground ,orange :background ,orange-bg))))
   `(helm-source-header ((t (:background ,base2 :foreground ,fg :weight bold))))

   ;; Highlight-indent-guides
   `(highlight-indent-guides-character-face ((t (:foreground ,base4))))
   `(highlight-indent-guides-stack-character-face ((t (:foreground ,grey))))

   ;; Ivy / Counsel
   `(ivy-current-match ((t (:background ,base3))))
   `(ivy-minibuffer-match-face-1 ((t (:foreground ,orange :background ,orange-bg))))
   `(ivy-minibuffer-match-face-2 ((t (:foreground ,orange :background ,orange-bg :weight bold))))
   `(ivy-minibuffer-match-face-3 ((t (:foreground ,yellow :background ,yellow-bg))))
   `(ivy-minibuffer-match-face-4 ((t (:foreground ,green :background ,green-bg))))

   ;; Magit
   `(magit-bisect-bad ((t (:foreground ,red))))
   `(magit-bisect-good ((t (:foreground ,green))))
   `(magit-bisect-skip ((t (:foreground ,yellow))))
   `(magit-blame-heading ((t (:background ,base3))))
   `(magit-branch-local ((t (:foreground ,blue))))
   `(magit-branch-remote ((t (:foreground ,green))))
   `(magit-diff-added ((t (:background ,green-bg :foreground ,green))))
   `(magit-diff-added-highlight ((t (:background ,green-bg-br :foreground ,green))))
   `(magit-diff-base ((t (:background ,yellow-bg :foreground ,yellow))))
   `(magit-diff-base-highlight ((t (:background ,yellow-bg-br :foreground ,yellow))))
   `(magit-diff-context ((t (:foreground ,grey))))
   `(magit-diff-context-highlight ((t (:background ,base2 :foreground ,grey))))
   `(magit-diff-file-heading ((t (:foreground ,fg :weight bold))))
   `(magit-diff-hunk-heading ((t (:background ,base3 :foreground ,fg-alt))))
   `(magit-diff-hunk-heading-highlight ((t (:background ,base4 :foreground ,fg))))
   `(magit-diff-removed ((t (:background ,red-bg :foreground ,red))))
   `(magit-diff-removed-highlight ((t (:background ,red-bg-br :foreground ,red))))
   `(magit-hash ((t (:foreground ,grey))))
   `(magit-log-author ((t (:foreground ,blue))))
   `(magit-log-date ((t (:foreground ,grey))))
   `(magit-section-heading ((t (:foreground ,blue :weight bold))))
   `(magit-section-highlight ((t (:background ,base2))))
   `(magit-tag ((t (:foreground ,yellow))))

   ;; Markdown
   `(markdown-bold-face ((t (:foreground ,blue-dim :weight bold))))
   `(markdown-code-face ((t (:foreground ,orange))))
   `(markdown-header-face ((t (:foreground ,green :weight bold))))
   `(markdown-header-face-1 ((t (:inherit markdown-header-face :height 1.4))))
   `(markdown-header-face-2 ((t (:inherit markdown-header-face :height 1.3))))
   `(markdown-header-face-3 ((t (:inherit markdown-header-face :height 1.2))))
   `(markdown-header-face-4 ((t (:inherit markdown-header-face :height 1.1))))
   `(markdown-italic-face ((t (:foreground ,yellow-dim :slant italic))))
   `(markdown-link-face ((t (:foreground ,blue :weight bold))))
   `(markdown-url-face ((t (:foreground ,blue :slant italic :underline t))))
   `(markdown-pre-face ((t (:foreground ,orange))))
   `(markdown-inline-code-face ((t (:foreground ,orange))))

   ;; Org-mode
   `(org-block ((t (:background ,base2))))
   `(org-block-begin-line ((t (:background ,base2 :foreground ,grey))))
   `(org-block-end-line ((t (:inherit org-block-begin-line))))
   `(org-code ((t (:foreground ,orange))))
   `(org-date ((t (:foreground ,blue :underline t))))
   `(org-document-info ((t (:foreground ,fg-alt))))
   `(org-document-title ((t (:foreground ,fg :weight bold))))
   `(org-done ((t (:foreground ,green))))
   `(org-headline-done ((t (:foreground ,grey))))
   `(org-level-1 ((t (:foreground ,green :weight bold :height 1.3))))
   `(org-level-2 ((t (:foreground ,blue :weight bold :height 1.2))))
   `(org-level-3 ((t (:foreground ,magenta :weight bold :height 1.1))))
   `(org-level-4 ((t (:foreground ,yellow :weight bold))))
   `(org-level-5 ((t (:foreground ,violet))))
   `(org-level-6 ((t (:foreground ,blue-dim))))
   `(org-level-7 ((t (:foreground ,green-dim))))
   `(org-level-8 ((t (:foreground ,grey))))
   `(org-link ((t (:foreground ,blue :underline t))))
   `(org-priority ((t (:foreground ,orange))))
   `(org-scheduled ((t (:foreground ,green))))
   `(org-scheduled-previously ((t (:foreground ,yellow))))
   `(org-scheduled-today ((t (:foreground ,green))))
   `(org-special-keyword ((t (:foreground ,grey))))
   `(org-table ((t (:foreground ,fg-alt))))
   `(org-tag ((t (:foreground ,grey :weight normal))))
   `(org-todo ((t (:foreground ,orange :weight bold))))
   `(org-upcoming-deadline ((t (:foreground ,yellow))))
   `(org-verbatim ((t (:foreground ,orange))))
   `(org-warning ((t (:foreground ,red))))

   ;; Rainbow delimiters
   `(rainbow-delimiters-depth-1-face ((t (:foreground ,magenta))))
   `(rainbow-delimiters-depth-2-face ((t (:foreground ,blue))))
   `(rainbow-delimiters-depth-3-face ((t (:foreground ,green))))
   `(rainbow-delimiters-depth-4-face ((t (:foreground ,yellow))))
   `(rainbow-delimiters-depth-5-face ((t (:foreground ,violet))))
   `(rainbow-delimiters-depth-6-face ((t (:foreground ,orange))))
   `(rainbow-delimiters-depth-7-face ((t (:foreground ,magenta-dim))))

   ;; Show-paren
   `(show-paren-match ((t (:underline t :weight bold))))
   `(show-paren-mismatch ((t (:foreground ,red :background ,red-bg :weight bold))))

   ;; Swiper
   `(swiper-line-face ((t (:background ,base3))))
   `(swiper-match-face-1 ((t (:foreground ,orange :background ,orange-bg))))
   `(swiper-match-face-2 ((t (:foreground ,orange :background ,orange-bg :weight bold))))
   `(swiper-match-face-3 ((t (:foreground ,yellow :background ,yellow-bg))))
   `(swiper-match-face-4 ((t (:foreground ,green :background ,green-bg))))

   ;; Treemacs
   `(treemacs-directory-face ((t (:foreground ,blue-dim))))
   `(treemacs-file-face ((t (:foreground ,fg))))
   `(treemacs-git-added-face ((t (:foreground ,green))))
   `(treemacs-git-modified-face ((t (:foreground ,yellow))))
   `(treemacs-git-untracked-face ((t (:foreground ,grey))))
   `(treemacs-root-face ((t (:foreground ,fg :weight bold))))

   ;; Tree-sitter
   `(tree-sitter-hl-face:attribute ((t (:foreground ,blue-dim))))
   `(tree-sitter-hl-face:comment ((t (:inherit font-lock-comment-face))))
   `(tree-sitter-hl-face:constant ((t (:foreground ,yellow))))
   `(tree-sitter-hl-face:constant.builtin ((t (:foreground ,yellow :weight bold))))
   `(tree-sitter-hl-face:function ((t (:foreground ,magenta))))
   `(tree-sitter-hl-face:function.call ((t (:foreground ,magenta-dim))))
   `(tree-sitter-hl-face:function.builtin ((t (:foreground ,magenta :slant italic))))
   `(tree-sitter-hl-face:function.macro ((t (:foreground ,magenta-bright :weight bold))))
   `(tree-sitter-hl-face:function.method ((t (:foreground ,magenta-dim))))
   `(tree-sitter-hl-face:function.special ((t (:foreground ,magenta-bright))))
   `(tree-sitter-hl-face:method ((t (:foreground ,magenta-dim))))
   `(tree-sitter-hl-face:constructor ((t (:foreground ,magenta :weight bold))))
   `(tree-sitter-hl-face:escape ((t (:foreground ,magenta))))
   `(tree-sitter-hl-face:keyword ((t (:foreground ,green :weight bold))))
   `(tree-sitter-hl-face:label ((t (:foreground ,blue))))
   `(tree-sitter-hl-face:number ((t (:foreground ,violet))))
   `(tree-sitter-hl-face:operator ((t (:foreground ,fg-alt))))
   `(tree-sitter-hl-face:punctuation ((t (:foreground ,fg-alt))))
   `(tree-sitter-hl-face:punctuation.bracket ((t (:foreground ,fg-alt))))
   `(tree-sitter-hl-face:punctuation.delimiter ((t (:foreground ,fg-alt))))
   `(tree-sitter-hl-face:punctuation.special ((t (:foreground ,magenta))))
   `(tree-sitter-hl-face:string ((t (:foreground ,violet))))
   `(tree-sitter-hl-face:string.special ((t (:foreground ,magenta))))
   `(tree-sitter-hl-face:tag ((t (:foreground ,green))))
   `(tree-sitter-hl-face:type ((t (:foreground ,yellow))))
   `(tree-sitter-hl-face:type.argument ((t (:foreground ,fg))))
   `(tree-sitter-hl-face:type.builtin ((t (:foreground ,yellow :slant italic))))
   `(tree-sitter-hl-face:type.parameter ((t (:foreground ,fg))))
   `(tree-sitter-hl-face:type.super ((t (:foreground ,yellow :weight bold))))
   `(tree-sitter-hl-face:variable ((t (:foreground ,cyan))))
   `(tree-sitter-hl-face:variable.parameter ((t (:foreground ,peach))))
   `(tree-sitter-hl-face:variable.builtin ((t (:foreground ,magenta :slant italic))))
   `(tree-sitter-hl-face:property ((t (:foreground ,cyan-dim))))
   `(tree-sitter-hl-face:variable.special ((t (:foreground ,magenta))))


   ;; Vertico
   `(vertico-current ((t (:background ,base3))))
   `(vertico-group-title ((t (:foreground ,grey))))
   `(vertico-group-separator ((t (:foreground ,grey :strike-through t))))

   ;; Web-mode
   `(web-mode-html-tag-face ((t (:foreground ,fg-alt))))
   `(web-mode-html-tag-bracket-face ((t (:foreground ,grey))))
   `(web-mode-html-attr-name-face ((t (:foreground ,blue-dim))))
   `(web-mode-html-attr-value-face ((t (:foreground ,violet))))
   `(web-mode-css-selector-face ((t (:foreground ,magenta))))
   `(web-mode-css-property-name-face ((t (:foreground ,green))))

   ;; Which-key
   `(which-key-key-face ((t (:foreground ,green))))
   `(which-key-group-description-face ((t (:foreground ,blue))))
   `(which-key-command-description-face ((t (:foreground ,fg))))
   `(which-key-separator-face ((t (:foreground ,grey))))

   ;; Whitespace
   `(whitespace-trailing ((t (:background ,red-bg :foreground ,red))))
   `(whitespace-space ((t (:foreground ,base4))))
   `(whitespace-tab ((t (:foreground ,base4))))
   `(whitespace-newline ((t (:foreground ,base4))))
   `(whitespace-indentation ((t (:foreground ,base4))))
   `(whitespace-line ((t (:background ,yellow-bg))))

   ;; LSP Semantic Tokens
   `(lsp-face-semhl-keyword ((t (:foreground ,green :weight bold))))
   `(lsp-face-semhl-type ((t (:foreground ,yellow))))
   `(lsp-face-semhl-type-parameter ((t (:foreground ,yellow))))
   `(lsp-face-semhl-struct ((t (:foreground ,yellow))))
   `(lsp-face-semhl-enum ((t (:foreground ,yellow))))
   `(lsp-face-semhl-enum-member ((t (:foreground ,yellow))))
   `(lsp-face-semhl-class ((t (:foreground ,yellow))))
   `(lsp-face-semhl-interface ((t (:foreground ,yellow))))
   `(lsp-face-semhl-namespace ((t (:foreground ,blue-dim))))
   `(lsp-face-semhl-constant ((t (:foreground ,yellow))))
   `(lsp-face-semhl-operator ((t (:foreground ,fg-alt))))
   `(lsp-face-semhl-string ((t (:foreground ,violet))))
   `(lsp-face-semhl-number ((t (:foreground ,violet))))
   `(lsp-face-semhl-boolean ((t (:foreground ,violet))))
   `(lsp-face-semhl-comment ((t (:inherit font-lock-comment-face))))
   `(lsp-face-semhl-static ((t (:foreground ,magenta :slant italic))))
   `(lsp-face-semhl-mutable ((t (:foreground ,fg :underline t))))
   `(lsp-face-semhl-variable ((t (:foreground ,cyan))))
   `(lsp-face-semhl-parameter ((t (:foreground ,peach))))
   `(lsp-face-semhl-property ((t (:foreground ,cyan-dim))))
   `(lsp-face-semhl-member ((t (:foreground ,cyan-dim))))
   `(lsp-face-semhl-function ((t (:foreground ,magenta))))
   `(lsp-face-semhl-method ((t (:foreground ,magenta-dim))))
   `(lsp-face-semhl-macro ((t (:foreground ,magenta-bright :weight bold))))
   `(lsp-face-semhl-deprecated ((t (:foreground ,grey :strike-through t))))

   ;;Tabline
   `(tab-line ((t (:inherit mode-line))))

   ;; Rust-specific
   `(rust-builtin-formatting-macro ((t (:foreground ,magenta :weight bold))))
   `(rust-question-mark ((t (:foreground ,orange :weight bold))))
   `(rust-unsafe ((t (:foreground ,red :weight bold))))
   `(rustic-compilation-message-info ((t (:foreground ,blue))))
   `(rustic-compilation-message-warning ((t (:foreground ,yellow))))
   `(rustic-compilation-message-error ((t (:foreground ,red))))

   ;; C/C++-specific
   `(c-annotation-face ((t (:foreground ,magenta))))

   ;; Python-specific
   `(python-font-lock-decorator-face ((t (:foreground ,magenta))))
   `(python-font-lock-pseudo-keyword-face ((t (:foreground ,green :slant italic))))

   ;; JavaScript/TypeScript
   `(js2-function-param ((t (:foreground ,fg))))
   `(js2-object-property ((t (:foreground ,fg))))
   `(js2-external-variable ((t (:foreground ,magenta))))
   `(typescript-jsdoc-tag ((t (:foreground ,grey))))
   `(typescript-jsdoc-type ((t (:foreground ,yellow))))
   `(typescript-jsdoc-value ((t (:foreground ,fg))))

   ;; Lisp/Scheme
   `(lisp-font-lock-constant ((t (:foreground ,yellow))))
   `(lisp-font-lock-keyword ((t (:foreground ,green :weight bold))))

   ;; Eglot inlay hints
   `(eglot-inlay-hint-face ((t (:foreground ,grey :height 0.8 :slant italic :background ,base2))))
   `(eglot-type-hint-face ((t (:inherit eglot-inlay-hint-face))))
   `(eglot-parameter-hint-face ((t (:inherit eglot-inlay-hint-face))))
   ))

;;;###autoload
(when load-file-name
  (add-to-list 'custom-theme-load-path
               (file-name-as-directory (file-name-directory load-file-name))))

(provide-theme 'doom-osmium)

;;; doom-osmium-theme.el ends here
