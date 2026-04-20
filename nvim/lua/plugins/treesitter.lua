return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'lua', 'vim', 'vimdoc', 'query',
        'zig', 'rust', 'c', 'cpp',
        'python', 'javascript', 'typescript',
        'go', 'json', 'yaml', 'toml',
        'markdown', 'markdown_inline',
        'html', 'css', 'bash',
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    event = 'VeryLazy',
    config = function()
      require('nvim-treesitter-textobjects').setup {
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            [']f'] = '@function.outer',
            [']c'] = '@class.outer',
          },
          goto_next_end = {
            [']F'] = '@function.outer',
            [']C'] = '@class.outer',
          },
          goto_previous_start = {
            ['[f'] = '@function.outer',
            ['[c'] = '@class.outer',
          },
          goto_previous_end = {
            ['[F'] = '@function.outer',
            ['[C'] = '@class.outer',
          },
        },
      }
    end,
  },
}
