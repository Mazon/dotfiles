-- General keymaps

vim.keymap.set('n', 'U', '<C-r>', { desc = 'Redo' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })

-- Toggle folds
vim.keymap.set('n', '<leader>tz', function()
  vim.opt.foldenable = not vim.opt.foldenable:get()
end, { desc = 'Toggle folds' })

-- Diagnostic toggle
vim.keymap.set('n', '<leader>td', function()
  if vim.diagnostic.is_enabled() then
    vim.diagnostic.enable(false)
  else
    vim.diagnostic.enable()
  end
end, { desc = 'Toggle diagnostics' })

vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })

vim.keymap.set('n', ']q', '<cmd>cnext<CR>zz', { desc = 'Next quickfix item' })
vim.keymap.set('n', '[q', '<cmd>cprev<CR>zz', { desc = 'Previous quickfix item' })
vim.keymap.set('n', ']Q', '<cmd>clast<CR>zz', { desc = 'Last quickfix item' })
vim.keymap.set('n', '[Q', '<cmd>cfirst<CR>zz', { desc = 'First quickfix item' })

vim.keymap.set('n', ']l', '<cmd>lnext<CR>zz', { desc = 'Next location list item' })
vim.keymap.set('n', '[l', '<cmd>lprev<CR>zz', { desc = 'Previous location list item' })
vim.keymap.set('n', ']L', '<cmd>llast<CR>zz', { desc = 'Last location list item' })
vim.keymap.set('n', '[L', '<cmd>lfirst<CR>zz', { desc = 'First location list item' })

vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Buffer navigation
vim.keymap.set('n', '<leader>bd', function()
  require('mini.bufremove').delete(0, false)
end, { desc = 'Delete buffer (keep window)' })
vim.keymap.set('n', '<leader>bD', function()
  require('mini.bufremove').delete(0, true)
end, { desc = 'Force delete buffer (keep window)' })
vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })

-- Window management
vim.keymap.set('n', '<leader>-', '<C-W>s', { desc = 'Split below' })
vim.keymap.set('n', '<leader>|', '<C-W>v', { desc = 'Split right' })
vim.keymap.set('n', '<leader>wd', '<C-W>c', { desc = 'Delete window' })
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<CR>', { desc = 'Increase window width' })

-- Terminal mode navigation
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-h>', '<C-\\><C-n><C-w>h', { desc = 'Terminal: move to left window' })
vim.keymap.set('t', '<C-j>', '<C-\\><C-n><C-w>j', { desc = 'Terminal: move to below window' })
vim.keymap.set('t', '<C-k>', '<C-\\><C-n><C-w>k', { desc = 'Terminal: move to above window' })
vim.keymap.set('t', '<C-l>', '<C-\\><C-n><C-w>l', { desc = 'Terminal: move to right window' })
