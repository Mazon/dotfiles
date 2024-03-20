--  ╭──────────────────────────────────────────────────────────╮
--  │                    LSP Configuration                     │
--  ╰──────────────────────────────────────────────────────────╯

-- NEODEV
require('neodev').setup()

-- MASON
require('mason').setup({
    ui = {
        icons = {
            package_installed = ' ',
            package_pending = ' ',
            package_uninstalled = ' ',
        },
        border = 'rounded',
    },
})

-- MASON LSPCONFIG
require('mason-lspconfig').setup({
    ensure_installed = {
        --'cssls',
        --'html',
        --'jsonls',
        'lua_ls',
        'rust_analyzer',
        --'yamlls',
    },
})

-- LSPCONFIG
local lspconfig = require('lspconfig')

-- CMP LSP CAPABILITIES
local lsp_defaults = lspconfig.util.default_config
lsp_defaults.capabilities =
    vim.tbl_deep_extend('force', lsp_defaults.capabilities, require('cmp_nvim_lsp').default_capabilities())

require('lspconfig.ui.windows').default_options.border = 'rounded'

-- WINBAR WITH NAVIC
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
-- local navic = require('nvim-navic')

-- KEYMAPS
local opts = function(desc)
    return { noremap = true, silent = true, desc = desc }
end

-- local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>ld', vim.diagnostic.open_float, opts('Open Diagnostic Window'))
vim.keymap.set('n', '<leader>lp', vim.diagnostic.goto_prev, opts('Previous Diagnostic'))
vim.keymap.set('n', '<leader>ln', vim.diagnostic.goto_next, opts('Next Diagnostic'))
--vim.keymap.set('n', '<leader>ls', vim.diagnostic.setloclist, opts('Send Diagnostic to Locallist'))

-- LSPATTACH AUTOCOMMAND
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = function(desc)
            return { buffer = ev.buf, desc = desc }
        end
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts('Go to Declaration'))
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts('Go to Definition'))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts('Hover'))
        vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, bufopts('Go to Implementation'))
        vim.keymap.set('n', '<leader>lk', vim.lsp.buf.signature_help, bufopts('Singature Help'))
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts('Add Workspace Folder'))
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts('Remove Workspace Folder'))
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts('List Workspace Folder'))
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts('Type Definition'))
        vim.keymap.set('n', '<leader>lr', vim.lsp.buf.rename, bufopts('Rename with LSP'))
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, bufopts('Code Action'))
        vim.keymap.set('n', 'gR', vim.lsp.buf.references, bufopts('Go to Reference'))
        vim.keymap.set('n', '<leader>lf', function()
            vim.lsp.buf.format({ async = true })
        end, bufopts('Formatting with LSP'))

        -- Inlay Hints
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client.server_capabilities.inlayHintProvider then
            vim.lsp.inlay_hint.enable(ev.buf, true)
        else
            vim.lsp.inlay_hint.enable(ev.buf, false)
        end
    end,
})

-- TOGGLE INLAY HINTS
if vim.lsp.inlay_hint then
    vim.keymap.set('n', '<leader>ih', function()
        vim.lsp.inlay_hint.enable(0, not vim.lsp.inlay_hint.is_enabled())
    end, { desc = 'Toggle Inlay Hints' })
end

-- BORDERS FOR DIAGNOSTICS
-- vim.cmd([[autocmd! ColorScheme * highlight FloatBorder guifg=white guibg=#181926]])
-- vim.cmd([[autocmd! ColorScheme * highlight NormalFloat guibg=#181926]])

local border = {
    { '┌', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '┐', 'FloatBorder' },
    { '│', 'FloatBorder' },
    { '┘', 'FloatBorder' },
    { '─', 'FloatBorder' },
    { '└', 'FloatBorder' },
    { '│', 'FloatBorder' },
}

-- LSP SETTINGS (FOR OVERRIDING PER CLIENT)
local handlers = {
    ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
    ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

-- DISABLE LSP (NOT CMP) INLINE DIAGNOSTICS ERROR MESSAGES
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
})

-- DIAGNOSTICS SIGNS
local signs = { Error = ' ', Warn = ' ', Hint = '󰌶 ', Info = ' ' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
    virtual_text = {
        prefix = '', -- Could be '●', '▎', │, 'x', '■', , 
    },
    float = { border = border },
    -- virtual_text = false,
    -- signs = true,
    underline = false,
})

--  ╭──────────────────────────────────────────────────────────╮
--  │                         SERVERS                          │
--  ╰──────────────────────────────────────────────────────────╯
-- CSS SERVER
lspconfig.cssls.setup({
    handlers = handlers,
    settings = {
        css = {
            lint = {
                unknownAtRules = 'ignore',
            },
        },
    },
})

-- TAILWIND SERVER
-- lspconfig.tailwindcss.setup({
--     handlers = handlers,
-- })

-- HTML SERVER
lspconfig.html.setup({
    handlers = handlers,
    settigns = {
        css = {
            lint = {
                validProperties = {},
            },
        },
    },
})

-- RUST
lspconfig.rust_analyzer.setup({
    handlers = handlers,
})
