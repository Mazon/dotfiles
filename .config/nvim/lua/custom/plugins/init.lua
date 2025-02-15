return {
  --  {
  -- 'Exafunction/codeium.nvim',
  -- dependencies = {
  -- 'nvim-lua/plenary.nvim',
  --      'hrsh7th/nvim-cmp',
  --    },
  --    config = function()
  --      require('codeium').setup {}
  --    end,
  --  },
  { 'christoomey/vim-tmux-navigator' },
  {
    'yetone/avante.nvim',
    event = 'VeryLazy',
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      provider = 'codegemma',
      auto_suggestions_provider = 'ollama',
      behaviour = {
        auto_suggestions = true,
        auto_set_keymaps = true,
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = 'co',
          theirs = 'ct',
          all_theirs = 'ca',
          both = 'cb',
          cursor = 'cc',
          next = ']x',
          prev = '[x',
        },
        suggestion = {
          accept = '<M-l>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
        jump = {
          next = ']]',
          prev = '[[',
        },
        submit = {
          normal = '<CR>',
          insert = '<C-s>',
        },
        sidebar = {
          apply_all = 'B',
          apply_cursor = 'a',
          switch_windows = '<Tab>',
          reverse_switch_windows = '<S-Tab>',
        },
      },
      vendors = {
        ---@type AvanteProvider
        ollama = {
          __inherited_from = 'openai',
          endpoint = 'http://127.0.0.1:11434/v1',
          api_key_name = '',
          --          model = 'codegemma',
          model = 'qwen2.5-coder:1.5b',
        },
        ---@type AvanteProvider
        deepseek = {
          __inherited_from = 'openai',
          endpoint = 'http://127.0.0.1:11434/v1',
          api_key_name = '',
          --          model = 'codegemma',
          model = 'deepseek-r1:latest',
        },
        ---@type AvanteProvider
        codegemma = {
          __inherited_from = 'openai',
          endpoint = 'http://127.0.0.1:11434/v1',
          api_key_name = '',
          --          model = 'codegemma',
          model = 'codegemma:latest',
        },
        --  parse_curl_args = function(opts, code_opts)
        --    return {
        --      url = opts.endpoint .. '/chat/completions',
        --      headers = {
        --        ['Accept'] = 'application/json',
        --        ['Content-Type'] = 'application/json',
        --      },
        --      body = {
        --        model = opts.model,
        --        messages = require('avante.providers').copilot.parse_message(code_opts), -- you can make your own message, but this is very advanced
        --        max_tokens = 2048,
        --        stream = true,
        --      },
        --    }
        --  end,
        --  parse_response_data = function(data_stream, event_state, opts)
        --    require('avante.providers').openai.parse_response(data_stream, event_state, opts)
        --  end,
        --},
      }, --
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = 'make',
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      --- The below dependencies are optional,
      'echasnovski/mini.pick', -- for file_selector provider mini.pick
      'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
      'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
      'ibhagwan/fzf-lua', -- for file_selector provider fzf
      'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
      'zbirenbaum/copilot.lua', -- for providers='copilot'
      {
        -- support for image pasting
        'HakonHarnes/img-clip.nvim',
        event = 'VeryLazy',
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { 'markdown', 'Avante' },
        },
        ft = { 'markdown', 'Avante' },
      },
    },
  },
  --{
  --  'olimorris/codecompanion.nvim',
  --  dependencies = {
  --    'nvim-lua/plenary.nvim',
  --    'nvim-treesitter/nvim-treesitter',
  --  },
  --  adapters = {
  --    fast = function()
  --      return require('codecompanion.adapters').extend('ollama', {
  --        parameters = {
  --          sync = true,
  --        },
  --        --  schema = {
  --        --    model = {
  --        --      default = 'qwen2.5-coder:1.5b',
  --        --    },
  --        --  },
  --      })
  --    end,
  --  },
  --  opts = {
  --    strategies = {
  --      -- Change the default chat adapter
  --      chat = {
  --        adapter = 'fast',
  --      },
  --      inline = {
  --        adapter = 'fast',
  --      },
  --    },
  --    opts = {
  --      -- Set debug logging
  --      log_level = 'DEBUG',
  --    },
  --  },
  --},
}
