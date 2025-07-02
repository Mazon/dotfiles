return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    init = function()
      vim.g.lualine_laststatus = vim.o.laststatus
      if vim.fn.argc(-1) > 0 then
        -- set an empty statusline till lualine loads
        vim.o.statusline = ' '
      else
        -- hide the statusline on the starter page
        vim.o.laststatus = 0
      end
    end,
    opts = function()
      vim.o.laststatus = vim.g.lualine_laststatus

      local opts = {
        options = {
          component_separators = { left = ' ', right = ' ' },
          section_separators = { left = ' ', right = ' ' },
          theme = theme,
          globalstatus = true,
          disabled_filetypes = { statusline = { 'dashboard' } },
        },
        sections = {
          lualine_a = {
            { 'mode', icon = { '' } },
            { 'filename', path = 0, symbols = { modified = '', readonly = '' }, padding = { left = 0 } },
          },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {
            { 'branch', icon = { '' }, padding = { right = 1, left = 1 } },
            -- {
            --   function()
            --     return '󱑍 ' .. os.date '%X'
            --   end,
            --   cond = function()
            --     return os.getenv 'TMUX' == nil
            --   end,
            -- },
          },
          lualine_y = {
            { 'selectioncount' },
            { 'diagnostics' },
          },
          --lualine_z = {}
        },
        extensions = {
          'quickfix',
          'neo-tree',
          'lazy',
          --          'oil',
          'trouble',
        },
      } --

      return opts
    end,
  },
}
