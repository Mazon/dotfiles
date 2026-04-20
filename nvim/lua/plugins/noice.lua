return {
  'folke/noice.nvim',
  event = 'VeryLazy',
  dependencies = {
    'MunifTanjim/nui.nvim',
  },
  opts = {
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
      progress = {
        view = 'mini', -- Use the mini view for progress updates
      },
    },
    presets = {
      long_message_to_split = true,
    },
    routes = {
      -- Hide the "written" message when saving a file
      {
        filter = {
          event = 'msg_show',
          kind = '',
          find = 'written',
        },
        opts = { skip = true },
      },
      -- Hide "No information available" messages from LSP
      {
        filter = {
          event = 'notify',
          find = 'No information available',
        },
        opts = { skip = true },
      },
      -- Suppress "press enter to continue" messages
      {
        filter = {
          event = 'msg_show',
          kind = 'confirm',
        },
        opts = { skip = true },
      },
    },
    views = {
      -- Style the floating command line
      cmdline_popup = {
        position = {
          row = '20%',
          col = '50%',
        },
        size = {
          width = 60,
          height = 'auto',
        },
        border = {
          style = 'rounded',
          padding = { 0, 1 },
        },
      },
    },
    cmdline = {
      format = {
        cmdline = { pattern = '^:', icon = '', lang = 'vim' },
        search_down = { kind = 'search', pattern = '^/', icon = ' ', lang = 'regex' },
        search_up = { kind = 'search', pattern = '^%?', icon = ' ', lang = 'regex' },
        filter = { pattern = '^:%s*!', icon = '$', lang = 'bash' },
        lua = { pattern = { '^:%s*lua%s+', '^:%s*lua%s*=%s*' }, icon = '', lang = 'lua' },
        help = { pattern = '^:%s*he?l?p?%s+', icon = '' },
        input = {},
      },
    },
  },
  keys = {
    {
      '<leader>nd',
      function()
        require('noice').cmd('dismiss')
      end,
      desc = 'Dismiss All Notifications',
    },
  },
}
