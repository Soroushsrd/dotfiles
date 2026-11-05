-- local ocamllsp = require 'lspconfig.configs.ocamllsp'
local M = {}

function M.setup()
  -- diagnostic config
  vim.diagnostic.config {
    virtual_text = false,
  }

  -- diagnostic signs
  if vim.g.have_nerd_font then
    local signs = { ERROR = '', WARN = '', INFO = '', HINT = '' }
    local diagnostic_signs = {}
    for type, icon in pairs(signs) do
      diagnostic_signs[vim.diagnostic.severity[type]] = icon
    end
    vim.diagnostic.config { signs = { text = diagnostic_signs } }
  end

  -- LSP handler configs
  vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#3b4261' }) -- Adjust color as needed

  --LSP keymaps
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      map('gd', Snacks.picker.lsp_definitions, '[G]oto [D]efinition')

      map('gr', Snacks.picker.lsp_references, '[G]oto [R]eferences')

      map('gI', Snacks.picker.lsp_implementations, '[G]oto [I]mplementation')

      map('<leader>D', Snacks.picker.lsp_type_definitions, 'Type [D]efinition')

      map('<leader>ds', Snacks.picker.lsp_symbols, '[D]ocument [S]ymbols')

      map('<leader>ws', Snacks.picker.lsp_workspace_symbols, '[W]orkspace [S]ymbols')

      map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

      map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- Document highlighting
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- inlay hints
      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- capabilities setup
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  -- capabilities.offsetEncoding = { 'utf-16' }
  local util = require 'lspconfig/util'

  local servers = {
    clangd = {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--completion-style=detailed',
        '--header-insertion=iwyu',
        '--header-insertion-decorators',
        '--enable-config',
        '--pch-storage=memory', -- Faster PCH storage
        '--all-scopes-completion', -- Complete symbols from all scopes
        '--function-arg-placeholders=true', -- Show function argument placeholders
        '--fallback-style=LLVM', -- Fallback formatting style
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
        fallbackFlags = { '-std=c++17' }, -- Default C++ standard
      },
      filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
      root_markers = {
        '.clangd',
        'compile_commands.json',
        'compile_flags.txt',
        'CMakeLists.txt',
        '.git',
      },
      settings = {
        clangd = {
          semanticHighlighting = true,
          inlayHints = {
            parameterNames = {
              enabled = true,
              suppressWhenArgumentMatchesName = false,
            },
            deducedTypes = {
              enabled = true,
            },
            designatedInitializers = true,
            blockEnd = true,
          },
          completion = {
            allScopes = true,
          },
          hover = {
            showAKA = true,
          },
        },
      },
      commands = {
        ClangdSwitchSourceHeader = {
          function()
            local client = vim.lsp.get_clients({ bufnr = 0, name = 'clangd' })[1]
            if not client then
              return
            end
            ---@diagnostic disable-next-line: param-type-mismatch
            client:request('textDocument/switchSourceHeader', vim.lsp.util.make_text_document_params(0), function(err, result)
              if err or not result then
                return
              end
              vim.cmd.edit(vim.uri_to_fname(result))
            end, 0)
          end,
          description = 'Switch between source and header file',
        },
      },
    },

    neocmake = {}, -- Upstream CMake language server; uses generated compile/build files.
    biome = {
      cmd = { 'biome', 'lsp-proxy' },
      filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'json', 'html' },
      root_markers = { 'biome.json', 'biome.jsonc', '.git' },
      single_file_support = true,
    },
    ts_ls = {
      cmd = { 'typescript-language-server', '--stdio' },
      filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
      root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(bufnr, { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' }) or vim.fn.getcwd())
      end,
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          },
        },
      },
      init_options = {
        preferences = {
          disableSuggestions = false,
        },
      },
    },
    ocamllsp = {
      cmd = { 'opam', 'exec', '--', 'ocamllsp' },
      filetypes = { 'ocaml', 'menhir', 'ocamlinterface', 'ocamllex', 'reason', 'dune' },
      root_markers = { '*.opam', 'esy.json', 'package.json', '.git', 'dune-project', 'dune-workspace' },
      settings = {
        extendedHover = { enable = true },
        codelens = { enable = true },
        inlayHints = {
          enable = true,
          hintPatternVariables = true,
          hintLetBindings = true,
          hintFunctionParams = true,
        },
        syntaxDocumentation = { enable = true },
        merlinJumpCodeActions = { enable = true },
        duneDiagnostics = { enable = true },
      },
    },
    gopls = {},
    svelte = {
      root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(bufnr, { 'svelte.config.js', 'svelte.config.ts', 'package.json', '.git' }) or vim.fn.getcwd())
      end,
    },
    rust_analyzer = {
      settings = {
        ['rust-analyzer'] = {
          -- no extraArgs: cargo.allFeatures already makes rust-analyzer pass
          -- --all-features, and cargo rejects the flag given twice.
          check = { command = 'clippy' },
          cargo = { allFeatures = true, buildScripts = { enable = true } },
          procMacro = { enable = true },
        },
      },
    },
    html = {
      filetypes = { 'html', 'blade', 'php', 'htmldjango' },
      capabilities = capabilities,
      init_options = {
        configurationSection = { 'html', 'css' },
        embeddedLanguages = {
          css = true,
          -- javascript = true,
          -- typescript = true,
        },
        provideFormatter = true,
      },
    },
    emmet_ls = {
      capabilities = capabilities,
      filetypes = { 'html', 'css', 'javascriptreact', 'typescriptreact' },
    },
    lua_ls = {
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
        },
      },
    },
    zls = {
      cmd = { 'zls' },
      filetypes = { 'zig', 'zir' },
      root_dir = util.root_pattern('zls.json', 'build.zig', '.git'),
      settings = {
        zls = {
          enable_snippets = true,
          enable_ast_check_diagnostics = true,
          enable_autofix = true,
          enable_import_embedfile_argument_completions = true,
          warn_style = true,
          enable_semantic_tokens = true,
          enable_inlay_hints = true,
          inlay_hints_show_builtin = true,
          inlay_hints_exclude_single_argument = true,
          inlay_hints_hide_redundant_param_names = false,
          inlay_hints_hide_redundant_param_names_last_token = false,
        },
      },
    },
  }

  require('mason').setup { PATH = 'append' } -- Prefer official Arch binaries.

  -- Mason supplies only tools without an installed system equivalent.
  local tools = {
    ['neocmakelsp'] = 'neocmakelsp',
    ['cmakelang'] = 'cmake-format',
    ['emmet-ls'] = 'emmet-ls',
  }
  local missing = {}
  for package, executable in pairs(tools) do
    if vim.fn.executable(executable) == 0 then table.insert(missing, package) end
  end
  require('mason-tool-installer').setup { ensure_installed = missing }
  require('mason-lspconfig').setup { automatic_enable = false }

  -- Register every server's config (works uniformly whether Mason
  -- installs the binary or it comes from elsewhere, like opam).
  for server_name, server_opts in pairs(servers) do
    server_opts.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server_opts.capabilities or {})
    vim.lsp.config(server_name, server_opts)
  end

  local enabled = vim.tbl_keys(servers)
  enabled = vim.tbl_filter(function(name)
    if name == 'ocamllsp' then return vim.fn.executable('opam') == 1 end
    if name == 'zls' then return vim.fn.executable('zls') == 1 end
    return true
  end, enabled)
  vim.lsp.enable(enabled)
end

return M
