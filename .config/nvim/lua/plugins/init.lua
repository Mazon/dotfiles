    --  ╭──────────────────────────────────────────────────────────╮
    --  │                       COLORSCHEME                        │
    --  ╰──────────────────────────────────────────────────────────╯
    -- === Catppuccin ===
    --    {
    --        'catppuccin/nvim',
    --        lazy = false,
    --        name = 'catppuccin',
    --        priority = 1000,
    --        config = function()
    --            require('plugins.theme.catppuccin')
    --            vim.cmd('colorscheme catppuccin')
    --        end,
    --    },
    -- === Rose-Pine ===
    return {
    --{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, config = function()
    --}, 
    { 'rose-pine/neovim', lazy = false, name = 'rose-pine', priority = 1000, config = function() require('plugins.theme.rose-pine') vim.cmd('colorscheme rose-pine')
        end,
    },

    --  ╭──────────────────────────────────────────────────────────╮
    --  │                           LSP                            │
    --  ╰──────────────────────────────────────────────────────────╯
    {
        'neovim/nvim-lspconfig',
        event = { 'BufReadPre', 'BufReadPost', 'BufNewFile' },
        dependencies = {
            { 'folke/neodev.nvim', opts = {} },
        },
        config = function()
            require('plugins.lspconf.lsp-config')
        end,
    },
    {
        'williamboman/mason.nvim',
        build = ':MasonUpdate',
        cmd = 'Mason',
        dependencies = {
            'williamboman/mason-lspconfig.nvim',
        },
    },
    --{
    --    'SmiteshP/nvim-navic',
    --    enabled = false,
    --    event = 'BufReadPre',
    --    dependencies = {
    --        'neovim/nvim-lspconfig',
    --    },
    --    opts = {
    --        highlight = true,
    --    },
    --},
    {
        'folke/trouble.nvim',
        keys = {
            { '<leader>xx', '<cmd>TroubleToggle<cr>', desc = 'Trouble Toggle' },
            { 'gr', '<cmd>TroubleToggle lsp_references<cr>' },
        },
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require('trouble').setup()
        end,
    },
    {
        'dnlhc/glance.nvim',
        keys = {
            { '<leader>br', '<cmd>Glance references<cr>', desc = 'Glance references' },
            { '<leader>bd', '<cmd>Glance definitions<cr>', desc = 'Glance definitions' },
            { '<leader>by', '<cmd>Glance type_definitions<cr>', desc = 'Glance type_definitions' },
            { '<leader>bm', '<cmd>Glance implementations<cr>', desc = 'Glance implementations' },
        },
        config = function()
            require('glance').setup()
        end,
    },
    {
        'simrat39/symbols-outline.nvim',
        enabled = true,
        cmd = 'SymbolsOutline',
        config = true,
        opts = {
            width = 40,
            symbols = {
                File = { icon = '󰈔', hl = '@text.uri' }, -- change
                Module = { icon = '󰆧', hl = '@namespace' }, -- change
                Namespace = { icon = '󰅪', hl = '@namespace' }, -- change
                Field = { icon = '󰆨', hl = '@field' }, -- change
                Interface = { icon = '󰜰', hl = '@type' }, -- change
                Array = { icon = '󰅪', hl = '@constant' }, -- change
                Event = { icon = '', hl = '@type' }, -- change
                Component = { icon = '󰅴', hl = '@function' }, -- change
            },
        },
        -- config = function()
        --     require('symbols-outline').setup()
        -- end,
    },
    --{
    --    'stevearc/aerial.nvim',
    --    enabled = true,
    --    cmd = 'AerialToggle',
    --    dependencies = {
    --        'nvim-treesitter/nvim-treesitter',
    --        'nvim-tree/nvim-web-devicons',
    --    },
    --    opts = {
    --        layout = {
    --            width = 60,
    --        },
    --    },
    --},

    --  ╭──────────────────────────────────────────────────────────╮
    --  │                           CMP                            │
    --  ╰──────────────────────────────────────────────────────────╯
    {
        'hrsh7th/nvim-cmp',
        event = 'InsertEnter',
        dependencies = {
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'saadparwaiz1/cmp_luasnip',
            'ray-x/cmp-treesitter',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-nvim-lua',
            'f3fora/cmp-spell',
            'hrsh7th/cmp-path',
            'fazibear/cmp-nerdfonts',
            'octaltree/cmp-look',
        },
        config = function()
            require('plugins.lspconf.cmp')
        end,
    },

    --  ╭──────────────────────────────────────────────────────────╮
    --  │                  FORMATING AND LINTING                   │
    --  ╰──────────────────────────────────────────────────────────╯
    -- {
    --     'jose-elias-alvarez/null-ls.nvim',
    --     config = function()
    --         require('plugins.lspconf.null-ls')
    --     end,
    -- },
    {
        'stevearc/conform.nvim',
        event = { 'BufReadPre', 'BufNewFile' },
        opts = {
            formatters_by_ft = {
                css = { 'prettier' },
                html = { 'prettier' },
                markdown = { 'prettier' },
                rust = { 'rustfmt' },
       --         scss = { 'prettier' },
       --         yaml = { 'yamlfmt' },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 500,
            },
            -- formatters = {
            --     latexindent = {
            --         prepend_args = { '-l', '/Users/ilias/.indentconfig.yaml' },
            --     },
            -- },
        },
    },


    --  ╭──────────────────────────────────────────────────────────╮
    --  │                          UTILS                           │
    --  ╰──────────────────────────────────────────────────────────╯
    --{
    --    'smjonas/live-command.nvim',
    --    event = 'CmdlineEnter',
    --    config = function()
    --        require('live-command').setup({
    --            commands = {
    --                Norm = { cmd = 'norm' },
    --            },
    --        })
    --    end,
    --},
    --{
    --    'nguyenvukhang/nvim-toggler',
    --    keys = {
    --        { '<leader>w', desc = 'Toggle Word' },
    --    },
    --    config = function()
    --        require('nvim-toggler').setup({
    --            remove_default_keybinds = true,
    --        })
    --        vim.keymap.set({ 'n', 'v' }, '<leader>w', require('nvim-toggler').toggle, { desc = 'Toggle a Word' })
    --    end,
    --},
--    {
 --       'famiu/bufdelete.nvim',
  --      enabled = false,
   --     cmd = 'Bdelete',
   --     keys = {
   --         { '<space>bd', '<cmd>Bdelete<cr>', desc = 'Delete Buffer' },
   --     },
  --  },
  --  {
  --      'utilyre/sentiment.nvim',
  --      enabled = false,
  --      event = 'BufReadPre',
  --      version = '*',
  --      opts = {
  --          included_modes = {
  --              i = false,
  --          },
  --      },
  --      init = function()
  --          vim.g.loaded_matchparen = 1
  --      end,
  --  },
    --{
    --    'chrisgrieser/nvim-spider',
    --    event = 'BufReadPost',
    --    config = function()
    --        -- Keymaps
    --        vim.keymap.set({ 'n', 'o', 'x' }, 'w', function()
    --            require('spider').motion('w')
    --        end, { desc = 'Spider-w' })
    --        vim.keymap.set({ 'n', 'o', 'x' }, 'e', function()
    --            require('spider').motion('e')
    --        end, { desc = 'Spider-e' })
    --        vim.keymap.set({ 'n', 'o', 'x' }, 'b', function()
    --            require('spider').motion('b')
    --        end, { desc = 'Spider-b' })
    --        vim.keymap.set({ 'n', 'o', 'x' }, 'ge', function()
    --            require('spider').motion('ge')
    --        end, { desc = 'Spider-ge' })
    --    end,
    --},
    {
        'brenoprata10/nvim-highlight-colors',
        enabled = true,
        event = 'BufReadPre',
        config = true,
    },
   -- {
   --     'chrisgrieser/nvim-alt-substitute',
   --     enabled = false,
   --     opts = true,
   --     -- lazy-loading with `cmd =` does not work well with incremental preview
   --     event = 'CmdlineEnter',
   -- },
    --{
     --   'jokajak/keyseer.nvim',
     --   enabled = true,
     --   version = false,
     --   cmd = 'KeySeer',
     --   opts = {
     --       ui = {
     --           winblend = 100,
     --           border = 'rounded',
     --       },
     --       keyboard = {
     --           layout = 'qwertz',
     --       },
     --   },
    --},
    --{
    --    'luckasRanarison/nvim-devdocs',
    --    cmd = { 'DevdocsOpen', 'DevdocsOpenFloat' },
    --    dependencies = {
    --        'nvim-lua/plenary.nvim',
    --        'nvim-telescope/telescope.nvim',
    --        'nvim-treesitter/nvim-treesitter',
    --    },
    --    opts = {
    --        float_win = {
    --            relative = 'editor',
    ----            height = math.floor(vim.o.lines * 0.7),
     --           width = math.floor(vim.o.columns * 0.8),
    --            border = 'rounded',
    --        },
    --        wrap = true,
    --        after_open = function()
    --            vim.keymap.set('n', 'q', ':close<CR>', { silent = true })
    --        end,
    --    },
    --},
    {
        'ellisonleao/glow.nvim',
        cmd = 'Glow',
        config = true,
        opts = {
            border = 'single',
            style = 'dracula',
            width = 120,
            width_ratio = 0.8,
        },
    },
    --{
    --    'yaocccc/nvim-hl-mdcodeblock.lua',
    --    enabled = false,
    --    ft = 'markdown',
    --    dependencies = { 'nvim-treesitter' },
    --    config = true,
    --    opts = {
    --        hl_group = 'CursorLine',
    --        minumum_len = 80,
            -- minumum_len = function()
            --     return math.max(math.floor(vim.api.nvim_win_get_width(0) * 0.8), 100)
            -- end,
    --    },
    --},

    --  ╭──────────────────────────────────────────────────────────╮
    --  │                          MOTION                          │
    --  ╰──────────────────────────────────────────────────────────╯
--    {
--        'smoka7/hop.nvim',
--        version = '*',
--        keys = {
--            { '<space><space>', '<cmd>HopWord<cr>', desc = 'Hop Word' },
--            { '<leader>hh', '<cmd>HopAnywhere<cr>', desc = 'Hop Anywhere' },
--        },
--        config = true,
--    },
    {
        'rlane/pounce.nvim',
        enabled = false,
        keys = {
            { 'S', '<cmd>Pounce<CR>', mode = { 'n', 'v' } },
        },
    },
    {
        'declancm/cinnamon.nvim',
        keys = {
            { '<C-f>' },
            { '<C-b>' },
            { '<C-d>' },
            { '<C-u>' },
            { 'zz' },
            { 'zt' },
            { 'zb' },
        },
        config = function()
            -- vim.keymap.set({ 'n', 'x' }, '0', "<Cmd>lua Scroll('0')<CR>")
            -- vim.keymap.set({ 'n', 'x' }, '^', "<Cmd>lua Scroll('^')<CR>")
            -- vim.keymap.set({ 'n', 'x' }, '$', "<Cmd>lua Scroll('$', 0, 1)<CR>")
            vim.keymap.set('n', 'zz', "<Cmd>lua Scroll('zz', 0, 1)<CR>")
            vim.keymap.set('n', 'zt', "<Cmd>lua Scroll('zt', 0, 1)<CR>")
            vim.keymap.set('n', 'zb', "<Cmd>lua Scroll('zb', 0, 1)<CR>")
            require('cinnamon').setup({
                always_scroll = true,
                scroll_limit = 200,
            })
        end,
    },

    --  ╭──────────────────────────────────────────────────────────╮
    --  │                          DEBUG                           │
    --  ╰──────────────────────────────────────────────────────────╯
    {
        'mfussenegger/nvim-dap',
        cmd = { 'DapToggleBreakpoint' },
        keys = {
            { '<leader>db', '<cmd>DapToggleBreakpoint<cr>', desc = 'Add Breakpoint' },
        },
        dependencies = {
            {
                'rcarriga/nvim-dap-ui',
                keys = {
                    { '<leader>du', '<cmd>lua require("dapui").toggle()<CR>', desc = 'DAP UI Toggle' },
                },
                config = true,
            },
            {
                'theHamsta/nvim-dap-virtual-text',
                opts = {
                    commented = true,
                    virt_text_pos = 'eol',
                },
            },
        },
        config = function()
            require('plugins.dap.debug_adapter')
        end,
    },

    --  ╭──────────────────────────────────────────────────────────╮
    --  │                        REST-HTML                         │
    --  ╰──────────────────────────────────────────────────────────╯
   --- {
   --     'diepm/vim-rest-console',
   --     enabled = false,
   --     ft = 'rest',
   -- },
}