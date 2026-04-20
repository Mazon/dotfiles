return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  ---@type Flash.Config
  opts = {
    modes = {
      search = {
        enabled = false,
      },
      char = {
        enabled = false,
      },
    },
  },
  keys = {
    {
      's',
      mode = { 'n', 'x', 'o' },
      function()
        require('flash').jump()
      end,
      desc = 'Flash jump',
    },
    {
      '<leader>F',
      mode = { 'n', 'o', 'x' },
      function()
        require('flash').treesitter()
      end,
      desc = 'Flash treesitter select',
    },
    {
      '<leader>f',
      mode = { 'n', 'o', 'x' },
      function()
        require('flash').treesitter_search()
      end,
      desc = 'Flash treesitter search',
    },
  },
}
