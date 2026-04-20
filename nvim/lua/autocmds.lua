vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  desc = 'Check for file changes (autoread)',
  group = vim.api.nvim_create_augroup('autoread-checktime', { clear = true }),
  command = 'checktime',
})

vim.api.nvim_create_autocmd('FileType', {
  desc = 'Enable spell checking for text filetypes',
  group = vim.api.nvim_create_augroup('spell-check', { clear = true }),
  pattern = { 'gitcommit', 'markdown', 'text', 'txt' },
  callback = function()
    vim.opt_local.spell = true
  end,
})
