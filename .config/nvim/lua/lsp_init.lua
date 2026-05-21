vim.lsp.enable 'lua_ls'
vim.lsp.enable 'zls'
vim.lsp.enable 'rust'
vim.lsp.enable 'pyright'
vim.lsp.enable 'ts'
vim.lsp.enable 'gopls'
vim.lsp.enable 'clangd'

vim.o.winborder = 'rounded'
vim.diagnostic.config({
  virtual_text = { current_line = true },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-keymaps', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
    end

    map('gd', vim.lsp.buf.definition, 'Go to definition')
    map('gr', vim.lsp.buf.references, 'Go to references')
    map('gI', vim.lsp.buf.implementation, 'Go to implementation')
    map('gy', vim.lsp.buf.type_definition, 'Go to type definition')
    map('gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('K', vim.lsp.buf.hover, 'Hover')
    map('<leader>cd', vim.diagnostic.open_float, 'Line diagnostics')
    map('<leader>cD', function() Snacks.picker.diagnostics() end, 'Workspace diagnostics')
    vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help, { buffer = event.buf, desc = 'Signature help' })
    vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = event.buf, desc = 'Code action' })
    map('<leader>cr', vim.lsp.buf.rename, 'Rename')
    map('<leader>cf', function()
      require('conform').format { async = true, lsp_format = 'fallback' }
    end, 'Format')
    map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
    end, 'Toggle inlay hints')

    -- Enable inlay hints by default
    vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
  end,
})
