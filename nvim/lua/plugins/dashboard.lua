return {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    opts = {
        theme = 'doom',
        config = {
            header = {
                '',
                '',
            },
            -- header = {
            --     '',
            --     '',
            --     '',
            --     ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
            --     ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
            --     ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
            --     ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
            --     ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
            --     ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
            --     '',
            -- },
            center = {
                { action = 'Telescope find_files', desc = ' Find file', icon = ' ', key = 'f' },
                { action = 'enew | startinsert', desc = ' New file', icon = ' ', key = 'n' },
--                { action = 'Telescope file_browser', desc = ' File explorer', icon = ' ', key = 'e' },
                { action = 'Telescope oldfiles', desc = ' Recent files', icon = ' ', key = 'r' },
                { action = 'Telescope live_grep', desc = ' Find text', icon = ' ', key = 'g' },
                -- { action = 'e lua/plugins/init.lua', desc = ' Config', icon = ' ', key = 'c' },
                { action = 'Lazy', desc = ' Lazy', icon = '💤', key = 'l' },
                { action = 'qa', desc = ' Quit', icon = ' ', key = 'q' },
            },
            footer = function()
                local stats = require('lazy').stats()
                local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
                return { '⚡ Neovim loaded ' .. stats.loaded .. '/' .. stats.count .. ' plugins in ' .. ms .. 'ms' }
            end,
        },
        hide = {
            tabline = false,
        },
    },
}
