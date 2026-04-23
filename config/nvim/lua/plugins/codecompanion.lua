return {
  {
  'NickvanDyke/opencode.nvim',
  dependencies = {
    -- Recommended for better prompt input, and required to use `opencode.nvim`'s embedded terminal — otherwise optional
    { 'folke/snacks.nvim', opts = { input = { enabled = true } } },
  },
  config = function()
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`
    }

    -- Required for `opts.auto_reload`
    vim.opt.autoread = true

    -- Recommended keymaps
    vim.keymap.set('n', '<leader>ot', function() require('opencode').toggle() end, { desc = 'Toggle' })
    vim.keymap.set('n', '<leader>oA', function() require('opencode').ask() end, { desc = 'Ask' })
    vim.keymap.set('n', '<leader>oa', function() require('opencode').ask('@cursor: ') end, { desc = 'Ask about this' })
    vim.keymap.set('v', '<leader>oa', function() require('opencode').ask('@selection: ') end, { desc = 'Ask about selection' })
    vim.keymap.set('n', '<leader>o+', function() require('opencode').append_prompt('@buffer') end, { desc = 'Add buffer to prompt' })
    vim.keymap.set('v', '<leader>o+', function() require('opencode').append_prompt('@selection') end, { desc = 'Add selection to prompt' })
    vim.keymap.set('n', '<leader>on', function() require('opencode').command('session_new') end, { desc = 'New session' })
    vim.keymap.set('n', '<leader>oy', function() require('opencode').command('messages_copy') end, { desc = 'Copy last response' })
    vim.keymap.set('n', '<S-C-u>',    function() require('opencode').command('messages_half_page_up') end, { desc = 'Messages half page up' })
    vim.keymap.set('n', '<S-C-d>',    function() require('opencode').command('messages_half_page_down') end, { desc = 'Messages half page down' })
    vim.keymap.set({ 'n', 'v' }, '<leader>os', function() require('opencode').select() end, { desc = 'Select prompt' })

    -- Example: keymap for custom prompt
    vim.keymap.set('n', '<leader>oe', function() require('opencode').prompt('Explain @cursor and its context') end, { desc = 'Explain this code' })
  end,
},
  -- {
  --   "supermaven-inc/supermaven-nvim",
  --   config = function()
  --     require("supermaven-nvim").setup({})
  --   end,
  -- },
  --  {
  --    'olimorris/codecompanion.nvim',
  --    dependencies = {
  --      'nvim-lua/plenary.nvim',
  --      'nvim-treesitter/nvim-treesitter',
  --    },
  --    opts = {
  --      strategies = {
  --        -- Change the default chat adapter
  --        chat = {
  --          adapter = 'gemini',
  --          inline = 'gemini',
  --        },
  --        inline = {
  --          adapter = 'gemini',
  --        },
  --      },
  --      adapters = {
  --        gemini = "gemini",
  --        qwen = function()
  --          return require('codecompanion.adapters').extend('ollama', {
  --            name = 'local', -- Give this adapter a different name to differentiate it from the default ollama adapter
  --            schema = {
  --              model = {
  --                default = 'qwen3:14b'
  --              },
  --              num_ctx = {
  --                default = 32768,
  --              },
  --            },
  --          })
  --        end,
  --      },
  --      opts = {
  --        log_level = 'INFO',
  --      },
  --      display = {
  --        diff = {
  --          enabled = true,
  --          close_chat_at = 240,    -- Close an open chat buffer if the total columns of your display are less than...
  --          layout = 'vertical',    -- vertical|horizontal split for default provider
  --          opts = { 'internal', 'filler', 'closeoff', 'algorithm:patience', 'followwrap', 'linematch:120' },
  --          provider = 'mini_diff', -- default|mini_diff
  --        },
  --        inline = {
  --          layout = 'buffer',
  --        },
  --      },
  --    },
  --  },
}
