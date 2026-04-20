return {
  {
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      local ai = require('mini.ai')
      ai.setup {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }),
          f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
          c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
        },
      }
      require('mini.surround').setup()
      require('mini.pairs').setup()
      require('mini.bufremove').setup()
      require('mini.move').setup {
        mappings = {
          left = '<M-h>',
          right = '<M-l>',
          down = '<M-j>',
          up = '<M-k>',
          line_left = '<M-h>',
          line_right = '<M-l>',
          line_down = '<M-j>',
          line_up = '<M-k>',
        },
      }
      require('mini.splitjoin').setup()
    end,
  },

  {
    'echasnovski/mini.icons',
    lazy = true,
    init = function()
      package.preload['nvim-web-devicons'] = function()
        require('mini.icons').mock_nvim_web_devicons()
        return package.loaded['nvim-web-devicons']
      end
    end,
    opts = {
      file = {
        ['.keep'] = { glyph = '󰊢', hl = 'MiniIconsGrey' },
      },
    },
  },
}
