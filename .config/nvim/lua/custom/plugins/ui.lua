---@type LazySpec
return {
  -- {
  --   "nvim-tree/nvim-web-devicons",
  --   lazy = true
  -- },
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
      filetype = {
        -- dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
  },
  -- NOTE: not 100% sure I like this plugin
  -- {
  --   enabled = false,
  --   "folke/noice.nvim",
  --   event = "VeryLazy",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --   },
  --   ---@type NoiceConfig
  --   opts = {
  --     cmdline = {
  --       view = "cmdline"
  --     },
  --     lsp = {
  --       override = {
  --         ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
  --         ["vim.lsp.util.stylize_markdown"] = true,
  --         ["cmp.entry.get_documentation"] = true,
  --       },
  --       progress = {
  --         enabled = true,
  --       },
  --     },
  --     routes = {
  --       {
  --         filter = {
  --           event = "msg_show",
  --           kind = "",
  --           find = "written",
  --         },
  --         opts = { skip = true },
  --       },
  --     },
  --     presets = {
  --       bottom_search = true, -- use a classic bottom cmdline for search
  --       command_palette = true, -- position the cmdline and popupmenu together
  --       long_message_to_split = true, -- long messages will be sent to a split
  --       inc_rename = false, -- enables an input dialog for inc-rename.nvim
  --       lsp_doc_border = false, -- add a border to hover docs and signature help
  --     },
  --   },
  -- },
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

      local colorscheme = require('utils.colorscheme').colorscheme

      local custom = require('colorschemes.' .. colorscheme).lualine()
      local theme = custom.theme
      local components = custom.components

      -- For the tabs
      vim.cmd.highlight('custom_tab_active guifg=' .. custom.extensions.active)

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
            { 'branch', icon = { '' }, padding = { right = 1, left = 1 } },
            --{ 'filetype', icon_only = true, separator = '', padding = { left = 1, right = 0 } },
            { 'filename', path = 0, symbols = { modified = '', readonly = '' }, padding = { left = 0 } },
          },
          lualine_b = {},
          lualine_c = {

            --{ 'filename' },
            --'%=',
            --{
            --  require('tmux-status').tmux_windows,
            --  cond = require('tmux-status').show,
            --  padding = { left = 2 },
            --},
          },
          lualine_x = {
            -- {
            --   ---@diagnostic disable-next-line: undefined-field
            --   require("noice").api.status.command.get,
            --   ---@diagnostic disable-next-line: undefined-field
            --   cond = require("noice").api.status.command.has,
            --   color = { fg = "#ff9e64" },
            -- },
            {
              function()
                return '󱑍 ' .. os.date '%X'
              end,
              cond = function()
                return os.getenv 'TMUX' == nil
              end,
            },
          },
          lualine_y = {
            { 'selectioncount' },
            { 'diagnostics' },
            --{ 'progress', padding = { left = 2, right = 1 } },
            -- TODO: do not show when no tmux
            { 'location', padding = { right = 1 } },
          },
          lualine_z = {
            -- TODO: show when no tmux available
            -- { "location" },
            --{
            --  require('tmux-status').tmux_datetime,
            --  cond = require('tmux-status').show,
            --  padding = { left = 1, right = 1 },
            --},
            -- {
            --require('tmux-status').tmux_session,
            --cond = require('tmux-status').show,
            --padding = { left = 1, right = 1 },
            --},
          },
        },
        tabline = {
          lualine_a = {
            {
              'tabs',
              mode = 1,
              path = 0,
              show_modified_status = true,
              max_length = vim.o.columns,
              symbols = {
                modified = '',
              },
              tabs_color = {
                active = 'custom_tab_active',
              },
            },
          },
        },
        extensions = {
          'quickfix',
          'neo-tree',
          'lazy',
          --          'oil',
          'trouble',
        },
      }

      return opts
    end,
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    dependencies = {
      -- { 'nvim-tree/nvim-web-devicons' },
      { 'echasnovski/mini.icons' },
    },
    opts = function()
      local art = require('utils.art').vizion_shadow

      -- Add some margin
      local logo = string.rep('\n', art.margin_top) .. art.text .. string.rep('\n', art.margin_bottom)

      local opts = {
        theme = 'doom',
        hide = {
          statusline = false, -- taken from LazyVim, some sort of conflict happens otherwise
        },
        config = {
          header = vim.split(logo, '\n'),
          -- stylua: ignore
          center = {
            { action = function () require('utils.sessions').load({ mode = "auto" }) end, desc = " Restore session", icon = "󰦛 ", key = "s", },
            { action = require('utils.sessions').load, desc = " Restore session (user)", icon = "󱄍 ", key = "S", },
            { action = "Telescope oldfiles", desc = " Recent files", icon = " ", key = "r", },
            { action = "Telescope git_files", desc = " Find file", icon = " ", key = "f" },
            { action = "Telescope find_files", desc = " Search file", icon = "󰥨 ", key = "F" },
            -- { action = "ene | startinsert", desc = " New file", icon = " ", key = "n" },
            { action = "Telescope live_grep", desc = " Search text", icon = " ", key = "g" },
            { action = "Telescope find_files cwd=~/.config/nvim", desc = " Config files", icon = "󰒓 ", key = "c" },
            { action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l" },
            { action = "e ~/.config/tmux/tmux.conf", desc = " Tmux config", icon = " ", key = "t" },
            { action = "Telescope find_files cwd=~/.config/tmux", desc = " Tmux config (Dir)", icon = " ", key = "T" },
            { action = "qa", desc = " Quit", icon = " ", key = "q" },
          },
          footer = function()
            local stats = require('lazy').stats()
            local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
            return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
          end,
        },
      }

      for _, button in ipairs(opts.config.center) do
        button.desc = button.desc .. string.rep(' ', 43 - #button.desc)
        button.key_format = '  %s'
      end

      if vim.o.filetype == 'lazy' then
        vim.cmd.close()
        vim.api.nvim_create_autocmd('User', {
          pattern = 'DashboardLoaded',
          callback = function()
            require('lazy').show()
          end,
        })
      end

      return opts
    end,
  },
}
