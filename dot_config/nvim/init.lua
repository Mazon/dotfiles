-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Make line numbers default
vim.opt.number = true
-- Relative Numbers
vim.opt.relativenumber = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false
vim.opt.cmdheight = 0

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Colorscheme
vim.opt.termguicolors = true
vim.o.background = 'dark'
vim.cmd 'colorscheme default'
-- vim.g.hardy_floatboarder = true
-- vim.g.hardy_dim_comments = true
-- Save undo history
vim.opt.undofile = true
vim.opt.swapfile = false

-- Tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.gdefault = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Keymaps ]]
vim.keymap.set('n', 'U', '<C-r>')               -- undo / redo
vim.keymap.set('n', '<C-a>', '<cmd>w<cr><esc>') -- save
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>dt', function()
  if vim.diagnostic.is_enabled() then
    vim.diagnostic.enable(false)
  else
    vim.diagnostic.enable()
  end
end)

-- Go to next diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap('n', '[n', ':lua vim.diagnostic.goto_next()<CR>', { noremap = true, silent = true })
-- Go to prev diagnostic (if there are multiple on the same line, only shows
-- one at a time in the floating window)
vim.api.nvim_set_keymap('n', '[p', ':lua vim.diagnostic.goto_prev()<CR>', { noremap = true, silent = true })

--  Use CTRL+<hjkl> to switch between windows
--  See `:help wincmd` for a list of all window commands
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>w', '<cmd>WorkspacesOpen<CR>')
-- Programming Keymaps
--vim.keymap.set('n', '<leader>R', '<cmd>!zig build<CR>')
--vim.keymap.set('n', '<leader>aa', '<cmd>CodeCompanionChat Toggle<CR>')
--vim.keymap.set('v', '<leader>at', ":<C-u>'<,'>CodeCompanion ", { noremap = true, silent = true })
-- [[ Autocommands ]]

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.o.winborder = 'rounded'
-- by default lsp config sets K in normal mode to hover with no border
-- https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#configuration
-- manually overriding the mapping passing in the border style
vim.keymap.set({ "n" }, "K", function()
  vim.lsp.buf.hover { border = "rounded" }
end, { desc = "LSP show details", silent = true })

-- sets border for diagnostics and opens them on jump in a floating window
vim.diagnostic.config {
  jump = {
    float = true,
  },
  float = {
    border = "rounded",
  },
}
-- LSP
-- checkhealth lsp to see any issues
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'zls'
vim.lsp.enable 'rust'
vim.cmd("set completeopt+=noselect") -- Add noselect otherwise annoying.
vim.o.winborder = 'rounded'
vim.diagnostic.config({
  virtual_text = { current_line = true }
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

local _border = 'rounded'

local function bordered_hover(_opts)
  _opts = _opts or {}
  return vim.lsp.buf.hover(vim.tbl_deep_extend('force', _opts, {
    border = _border,
  }))
end

local function bordered_signature_help(_opts)
  _opts = _opts or {}
  return vim.lsp.buf.signature_help(vim.tbl_deep_extend('force', _opts, {
    border = _border,
  }))
end

-- [[ Configure and install plugins ]]
--    :Lazy
require('lazy').setup({
  { import = 'plugins' },
}, {
  ui = {},
  change_detection = {
    enabled = false,
  },
})
