return {
  'Senal-D-A-Gunaratna/hyprfade.nvim',
  cond = function() return vim.env.HYPRLAND_INSTANCE_SIGNATURE ~= nil end,
  lazy = false,
  priority = 1000,
  opts = {
    opacity = 1.00, -- opacity for active windows
    opacity_inactive = 1.00, -- opacity for inactive windows
    term_names = { -- process names to recognise as terminals
      'alacritty',
      'foot',
      'ghostty',
      'kitty',
      'wezterm',
    },
  },
  keys = {
    { '<leader>uo', '<cmd>HyprfadeToggle<cr>', desc = 'Toggle window opacity' },
  },
}
