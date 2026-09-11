;; init-treesit.el -*- lexical-binding: t; -*-

;;;; Code:
;;;; Tree-sitter
(setq treesit-language-source-alist
      '((cpp  "https://github.com/tree-sitter/tree-sitter-cpp")
        (c    "https://github.com/tree-sitter/tree-sitter-c")
        (tlaplus "https://github.com/tlaplus-community/tree-sitter-tlaplus")
        (qmljs "https://github.com/yuja/tree-sitter-qmljs" "master")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")))

(setopt treesit-auto-install-grammar 'ask)
(setopt treesit-enabled-modes t)
(setq treesit-font-lock-level 4)
(setq rustic-treesitter-derive t)  ; rustic uses rust-ts-mode as base
(setopt c-ts-mode-enable-doxygen t)              ; new in 31
(setopt rust-ts-mode-fontify-number-suffix-as-type t)

(provide 'init-treesit)
;;; init-treesit.el ends here
