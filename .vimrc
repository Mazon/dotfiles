" ----------------------------------------------------------------------------
"  .vimrc
" ----------------------------------------------------------------------------

" ----------------------------------------------------------------------------
" Plugins
" ----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'hoob3rt/lualine.nvim'
Plug 'lambdalisue/fern.vim'
Plug 'joshdick/onedark.vim'
Plug 'akinsho/toggleterm.nvim', {'tag' : '*'}
Plug 'neovim/nvim-lspconfig'
Plug 'simrat39/rust-tools.nvim'
Plug 'nvim-lua/popup.nvim'
" Completion framework
Plug 'hrsh7th/nvim-cmp'
" LSP completion source for nvim-cmp
Plug 'hrsh7th/cmp-nvim-lsp'
" Snippet completion source for nvim-cmp
Plug 'hrsh7th/cmp-vsnip'
" Other useful completion sources
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'
Plug 'mcchrish/nnn.vim'
Plug 'jamessan/vim-gnupg'
Plug 'terryma/vim-smooth-scroll'
Plug 'itchyny/lightline.vim'
"Plug 'davidosomething/vim-colors-meh'
" Plug 'mfussenegger/nvim-dap'
" Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'rust-lang/rust.vim'
call plug#end()

" autocmd BufNewFile,BufRead *.rs set filetype=rust

" lua <<EOF
" require'nvim-treesitter.configs'.setup {
  " highlight = {
    " enable = true,
    " disable = {},
  " },
  " indent = {
    " enable = false,
    " disable = {},
  " },
  " ensure_installed = {
     "rust"  },
"}
"local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
" EOF


" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
" Avoid showing extra messages when using completion
" set shortmess+=c
" Setup Completion
" See https://github.com/hrsh7th/nvim-cmp#basic-configuration

lua <<EOF
local cmp = require'cmp'
cmp.setup({
-- Enable LSP snippets
snippet = {
	expand = function(args)
	vim.fn["vsnip#anonymous"](args.body)
end,
},
  mapping = {
	  ['<C-p>'] = cmp.mapping.select_prev_item(),
	  ['<C-n>'] = cmp.mapping.select_next_item(),
	  -- Add tab support
	  ['<S-Tab>'] = cmp.mapping.select_prev_item(),
	  ['<Tab>'] = cmp.mapping.select_next_item(),
	  ['<C-d>'] = cmp.mapping.scroll_docs(-4),
	  ['<C-f>'] = cmp.mapping.scroll_docs(4),
	  ['<C-Space>'] = cmp.mapping.complete(),
	  ['<C-e>'] = cmp.mapping.close(),
	  ['<CR>'] = cmp.mapping.confirm({
	  behavior = cmp.ConfirmBehavior.Insert,
	  select = true,
	  })
  },

  -- Installed sources
  sources = {
	  { name = 'nvim_lsp' },
	  { name = 'nvim' },
	  { name = 'vsnip' },
	  { name = 'path' },
	  { name = 'buffer' },
	  },
  })
EOF

" Configure LSP through rust-tools.nvim plugin.
" rust-tools will configure and enable certain LSP features for us.
" See https://github.com/simrat39/rust-tools.nvim#configuration
"
lua <<EOF
local nvim_lsp = require'lspconfig'

local opts = {
	tools = { -- rust-tools options
	autoSetHints = true,
	hover_with_actions = true,
	inlay_hints = {
		only_current_line = true,
		show_parameter_hints = true,
		parameter_hints_prefix = "<-",
		other_hints_prefix = "",
		},
	},

-- all the opts to send to nvim-lspconfig
-- these override the defaults set by rust-tools.nvim
-- see https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
server = {
	-- on_attach is a callback called when the language server attachs to the buffer
	-- on_attach = on_attach,
	settings = {
		-- to enable rust-analyzer settings visit:
		-- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
		["rust-analyzer"] = {
			assist = {
				importEnforceGranularity = true,
				importPrefix = "crate"
				},
			cargo = { 
				allFeatures = true
				},
			-- enable clippy on save
			checkOnSave = {
				command = "clippy"
				},
			},
		inlayHints = {
			lifetimeElisionHents = {
				enable = true,
				useParameterNames = true
				},
			},
		}
	},
}

require('rust-tools').setup(opts)
require('rust-tools.inlay_hints').set_inlay_hints()
require'rust-tools.hover_actions'.hover_actions()
require('rust-tools.inlay_hints').toggle_inlay_hints()
EOF


" -----------------------------------------------------------------------------
" Plugin Configuration
" -----------------------------------------------------------------------------
let g:auto_save = 0 "make sure we autosave always. - vim-auto-save
let g:go_def_mapping_enabled = 0 "definition handled by languageclient - vim-go
let g:lightline = { 'colorscheme': 'deus' } "statusline configuraton - lightline

" -----------------------------------------------------------------------------
" System
" -----------------------------------------------------------------------------
set nocompatible "don't be compatible with old vi.
set completeopt=menuone,noinsert,noselect
set clipboard+=unnamedplus
set t_Co=256 "256 colors
set noswapfile "dont want any .swp laying around.
set nobackup " dont create any backup files.
set undodir=~/.vim/undodir "persistent undo
set undofile
set viminfo='1000,f1,:1000,/1000 "enable a nice big viminfo file
set history=500

" -----------------------------------------------------------------------------
" Look & Feel
" -----------------------------------------------------------------------------
colorscheme metacortex
" let g:onedark_terminal_italics=1 "italics for my favorite color scheme
" highlight clear Line
"let g:palenight_terminal_italics=1 "italics for my favorite color scheme
syntax on 
" syntax on for showing colors from scheme.
syntax enable 
" syntax on for showing colors from scheme. 
filetype on 
filetype plugin indent on
set showcmd "show us the command we're typing
set noshowmode "hide default message when entering modes.
"set cursorline "make clear what line we are on.
let &t_SI = "\<esc>[5 q" "I beam cursor for insert mode
let &t_EI = "\<esc>[2 q" "block cursor for normal mode
let &t_SR = "\<esc>[3 q" "underline cursor for replace mode
set formatoptions-=ro
set visualbell t_vb= "no visual bell
set noerrorbells "no error bells
set guicursor+=a:blinkon0 "no blinking cursor.
set hidden "allow edit buffers to be hidden
set winminheight=1 "1 height windows
set relativenumber "use relativenumber.
set number "absolute number on current line.
set nomodeline "disable modelines, use securemodelines.vim instead

" ----------------------------------------------------------------------------
" Search
" ----------------------------------------------------------------------------
set incsearch "incremental search
set ignorecase "ignore case
set infercase  "infers case in insert mode and autocomplete.
set nohlsearch "remove highlights search results.
set showmatch "highlight matching parentes
set showfulltag "show full tags when doing search completion

" ----------------------------------------------------------------------------
" Text Settings
" ----------------------------------------------------------------------------
set scrolloff=8 "make page start scroll before reach bottom.
set signcolumn=number
"column to left for signs etc.
"set expandtab "make tab always spaces.
set softtabstop=0 noexpandtab
set tabstop=4 "number of spaces a tab counts for.
set shiftwidth=4 "number of spaces a tab counts for.
set softtabstop=4 "number of spaces when inserting a tab.
set backspace=indent,eol,start "make backspace delete lots of things
set autoindent "do clever indent things. Don't make a # force column zero.
"set smartindent
set whichwrap+=<,>,[,] "wrap on this.
set path+=Documents/ "better include path handling
let &inc.=' ["<]'
set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<

" -----------------------------------------------------------------------------
" Keymappings
" -----------------------------------------------------------------------------
let mapleader = " " "set leader key to space.
"make Y yank without <CR>
:nnoremap Y yg_
"sudo save
cmap w!! w !sudo tee % >/dev/null
"keeping it centered.
:nnoremap n nzzzv
:nnoremap N Nzzzv
:nnoremap J mzJ`z
"smooth scroll
:nnoremap <silent> <c-k> :call smooth_scroll#up(&scroll, 3, 2)<CR>
:nnoremap <silent> <c-j> :call smooth_scroll#down(&scroll, 3, 2)<CR>
"search
":nnoremap <leader>g :Rg<cr>
":nnoremap <leader>f :GFiles<cr>
":nnoremap <leader>F :Files<cr>
":nnoremap <leader>b :Buffers<cr>
":nnoremap <Leader>l :BLines<CR>
":nnoremap <Leader>L :Lines<CR>
"golang
:nnoremap <Leader><CR> :!AMD_VULKAN_ICD=RADV cargo run<CR>
:nnoremap <Leader>r :cargo run<CR>

"fern
:nnoremap <Leader>d :Fern . -drawer -toggle<CR>
"coc
"use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
"remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
"use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>
"show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>

" Required, explicitly enable Elixir LS
"let g:ale_linters = {
			"\  'rust': ['analyzer'],
"\}
"let g:ale_fixers = { 'rust': ['rustfmt', 'trim_whitespace', 'remove_trailing_lines'] }
" let g:rustfmt_autosave = 1

" Enable completion where available.
" This setting must be set before ALE is loaded.
"
" You should not turn this setting on if you wish to use ALE as a completion
" source for other completion plugins, like Deoplete.
"set completeopt=menu,menuone,preview,noselect,noinsert
"let g:ale_completion_enabled = 1

"nnoremap <C-LeftMouse> :ALEGoToDefinition<CR>
"set omnifunc=ale#completion#OmniFunc

" Rust Keymappings
nmap <leader>h :RustHoverActions<CR>

lua << EOF
-- Location information about the last message printed. The format is
-- `(did print, buffer number, line number)`.
local last_echo = { false, -1, -1 }

-- The timer used for displaying a diagnostic in the commandline.
local echo_timer = nil

-- The timer after which to display a diagnostic in the commandline.
local echo_timeout = 250

-- The highlight group to use for warning messages.
local warning_hlgroup = 'WarningMsg'

-- The highlight group to use for error messages.
local error_hlgroup = 'ErrorMsg'

-- If the first diagnostic line has fewer than this many characters, also add
-- the second line to it.
local short_line_limit = 20

-- Shows the current line's diagnostics in a floating window.
function show_line_diagnostics()
  vim
    .lsp
    .diagnostic
    .show_line_diagnostics({ severity_limit = 'Warning' }, vim.fn.bufnr(''))
end

-- Prints the first diagnostic for the current line.
function echo_diagnostic()
  if echo_timer then
    echo_timer:stop()
  end

  echo_timer = vim.defer_fn(
    function()
      local line = vim.fn.line('.') - 1
      local bufnr = vim.api.nvim_win_get_buf(0)

      if last_echo[1] and last_echo[2] == bufnr and last_echo[3] == line then
        return
      end

      local diags = vim
        .lsp
        .diagnostic
        .get_line_diagnostics(bufnf, line, { severity_limit = 'Warning' })

      if #diags == 0 then
        -- If we previously echo'd a message, clear it out by echoing an empty
        -- message.
        if last_echo[1] then
          last_echo = { false, -1, -1 }

          vim.api.nvim_command('echo ""')
        end

        return
      end

      last_echo = { true, bufnr, line }

      local diag = diags[1]
      local width = vim.api.nvim_get_option('columns') - 15
      local lines = vim.split(diag.message, "\n")
      local message = lines[1]
      local trimmed = false

      if #lines > 1 and #message <= short_line_limit then
        message = message .. ' ' .. lines[2]
      end

      if width > 0 and #message >= width then
        message = message:sub(1, width) .. '...'
      end

      local kind = 'warning'
      local hlgroup = warning_hlgroup

      if diag.severity == vim.lsp.protocol.DiagnosticSeverity.Error then
        kind = 'error'
        hlgroup = error_hlgroup
      end

      local chunks = {
        { kind .. ': ', hlgroup },
        { message }
      }

      vim.api.nvim_echo(chunks, false, {})
    end,
    echo_timeout
  )


end
EOF

autocmd CursorMoved * :lua echo_diagnostic()
" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300
" Show diagnostic popup on cursor hold
autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })

lua<<EOF

  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
      virtual_text = false,
      signs = true,
      update_in_insert = false,
      underline = true,
    })
EOF


" have a fixed column for the diagnostics to appear in
" this removes the jitter when warnings/errors flow in

" vim diagnostic
" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>

nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>
" Code navigation shortcuts
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
"nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
"nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>

"Saga
" nnoremap <silent> K :Lspsaga hover_doc<CR>
" inoremap <silent> <C-k> <Cmd>Lspsaga signature_help<CR>
" nnoremap <silent> gh <Cmd>Lspsaga lsp_finder<CR>

" Telescope
lua<<EOF
-- This is your opts table
require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {
        -- even more opts
      }
    }
  }
}
-- To get ui-select loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require("telescope").load_extension("ui-select")
EOF


" Find files using Telescope command-line sugar.
" nnoremap <leader>ff <cmd>Telescope find_files<cr>
" nnoremap <leader>fg <cmd>Telescope live_grep<cr>
" nnoremap <leader>fb <cmd>Telescope buffers<cr>
" nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Using Lua functions
nnoremap <leader>f <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>g <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>b <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>h <cmd>lua require('telescope.builtin').help_tags()<cr>

":inoremap <C-j> <Esc>/[)}"'\]>]<CR>:nohl<CR>a
"inoremap (; (<CR>);<C-c>O
"inoremap (, (<CR>),<C-c>O
"inoremap {; {<CR>};<C-c>O
"inoremap {, {<CR>},<C-c>O
"inoremap [; [<CR>];<C-c>O
"inoremap [, [<CR>],<C-c>O

" Expand opening-brace followed by ENTER to a block and place cursor inside
inoremap {<CR> {<CR>}<Esc>O
" Auto-insert closing parenthesis/brace
inoremap ( ()<Left>
"inoremap { {}<Left>

" Skip over closing parenthesis/brace
inoremap <expr> ) getline('.')[col('.')-1] == ")" ? "\<Right>" : ")"
inoremap <expr> } getline('.')[col('.')-1] == "}" ? "\<Right>" : "}"

lua <<EOF
require'toggleterm'.setup {
  shade_terminals = false
}
EOF

" set
autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>

" By applying the mappiset signcolumn=numberngs this way you can pass a count to your
" mapping to open a specific window.
" For example: 2<C-t> will open terminal 2
nnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>
inoremap <silent><c-t> <Esc><Cmd>exe v:count1 . "ToggleTerm"<CR>


