return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha',
      integrations = {
        gitsigns = true,
        mini = true,
        noice = true,
        which_key = true,
        neogit = true,
        blink_cmp = true,
      },
    }
    vim.cmd.colorscheme 'catppuccin'
  end,
}
