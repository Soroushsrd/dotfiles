return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    -- Setup orgmode
    require('orgmode').setup {
      org_agenda_files = { '~/org/**/*', '~/notes/**/*' },
      org_default_notes_file = '~/notes/refile.org',
      org_todo_keywords = { 'TODO', 'INPROGRESS', '|', 'DONE' },
      win_split_mode = { 'float', 0.7 },
      org_hide_leading_stars = true,
      -- Colors for the state keyword itself (used by ~/org/jobs.org)
      org_todo_keyword_faces = {
        NEW = ':foreground #61afef :weight bold',
        APPLIED = ':foreground #e5c07b :weight bold',
        CALLBACK = ':foreground #56b6c2 :weight bold',
        INTERVIEW = ':foreground #c678dd :weight bold',
        OFFER = ':foreground #98c379 :weight bold',
        REJECTED = ':foreground #e06c75',
        SKIP = ':foreground #7f848e',
      },
    }

    -- Grey out the whole heading line for skipped entries
    vim.api.nvim_set_hl(0, 'OrgSkippedHeading', { fg = '#7f848e' })
    vim.api.nvim_create_autocmd({ 'BufWinEnter', 'FileType' }, {
      group = vim.api.nvim_create_augroup('OrgSkippedHeading', { clear = true }),
      pattern = { '*.org', 'org' },
      callback = function()
        if vim.bo.filetype ~= 'org' or vim.w.org_skip_match then
          return
        end
        vim.w.org_skip_match = vim.fn.matchadd('OrgSkippedHeading', [[\v^\*+ SKIP>.*]])
      end,
    })

    -- Experimental LSP support
    vim.lsp.enable 'org'
  end,
}
