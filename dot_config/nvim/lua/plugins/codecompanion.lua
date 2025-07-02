return {
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },
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
