;; init-treesit.el -*- lexical-binding: t; -*-

;;;; Tree-sitter
(setq treesit-language-source-alist
      '((cpp  "https://github.com/tree-sitter/tree-sitter-cpp")
        (c    "https://github.com/tree-sitter/tree-sitter-c")
        (rust "https://github.com/tree-sitter/tree-sitter-rust")
        (zig  "https://github.com/tree-sitter-grammars/tree-sitter-zig")
        (toml "https://github.com/tree-sitter/tree-sitter-toml")))

(setq rustic-treesitter-derive t)  ; rustic uses rust-ts-mode as base
(add-to-list 'major-mode-remap-alist '(rust-mode . rust-ts-mode))
(add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode))
(add-to-list 'major-mode-remap-alist '(c++-mode . c++-ts-mode))
(setq treesit-font-lock-level 4)
