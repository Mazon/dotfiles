vim.g.have_nerd_font = true

vim.env.PATH = vim.fn.expand '~/.cargo/bin' .. ':' .. (vim.env.PATH or '')

vim.opt.number = true
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

-- Save undo history
vim.opt.undofile = true
vim.opt.swapfile = false

-- Tabs
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

vim.opt.spelllang = { 'en' }
vim.opt.ignorecase = true
vim.opt.smartcase = true
-- NOTE: gdefault inverts the 'g' flag in :substitute.
-- :s/foo/bar/ replaces ALL, :s/foo/bar/g replaces FIRST only.
vim.opt.gdefault = true

vim.opt.signcolumn = 'yes'
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
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

vim.opt.virtualedit = 'block'
vim.opt.wrap = false
vim.opt.shiftround = true
vim.opt.jumpoptions = 'view'
vim.opt.autoread = true
vim.opt.mousescroll = 'ver:1,hor:6'
vim.opt.splitkeep = 'screen'

-- Treesitter-based folding
vim.opt.foldlevel = 99
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldtext = ''
vim.opt.foldcolumn = '0'
