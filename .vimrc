" -----------------------------------------------------------------------------
" Vimrc focused on optimized functionality while
" still being understandble and contained in a single file.
" -----------------------------------------------------------------------------

" -----------------------------------------------------------------------------
" Plugins
" -----------------------------------------------------------------------------
call plug#begin('~/.vim/plugged')
Plug 'fatih/vim-go'
Plug 'neoclide/coc.nvim'
Plug 'junegunn/fzf.vim'
Plug 'terryma/vim-smooth-scroll'
Plug '907th/vim-auto-save'
Plug 'itchyny/lightline.vim'
"initialize plugin system.
call plug#end()

" -----------------------------------------------------------------------------
" Plugins Settings
" -----------------------------------------------------------------------------
let g:auto_save = 1 "make sure we autosave always. - vim-auto-save
let g:go_def_mapping_enabled = 0 " this is handled by LanguageClient [LC] - vim-go
let g:lightline = { 'colorscheme': 'darcula' } "statusline configuraton - lightline

" -----------------------------------------------------------------------------
" System
" -----------------------------------------------------------------------------
set nocompatible "don't be compatible with old vi.
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
colorscheme palenight "https://github.com/drewtempelmeyer/palenight.vim.git
let g:palenight_terminal_italics=1 "italics for my favorite color scheme
syntax on "syntax on for showing colors from scheme.
filetype on "detect file type.
filetype plugin indent on
set showcmd "show us the command we're typing
set noshowmode "hide default message when entering modes.
set cursorline "make clear what line we are on.
let &t_SI = "\<esc>[5 q" "I beam cursor for insert mode
let &t_EI = "\<esc>[2 q" "block cursor for normal mode
let &t_SR = "\<esc>[3 q" "underline cursor for replace mode
set formatoptions-=ro
set visualbell t_vb= "no bell
set noerrorbells
set guicursor+=a:blinkon0 "no blinking cursor.
set hidden "allow edit buffers to be hidden
set winminheight=1 "1 height windows
set relativenumber "use relativenumber.
set number "absolute number on current line.
set nomodeline "disable modelines, use securemodelines.vim instead

" -----------------------------------------------------------------------------
" Search
" -----------------------------------------------------------------------------
set incsearch "incremental search
set ignorecase "ignore case
set infercase  "infers case in insert mode and autocomplete.
set hlsearch "highlights search results.
hi Search cterm=NONE ctermfg=8787AF ctermbg=87AF87
"set nohlsearch
set showmatch "highlight matching parentes
"hi Search cterm=NONE ctermfg=grey ctermbg=blue
set showfulltag "show full tags when doing search completion

" -----------------------------------------------------------------------------
" Text Settings
" -----------------------------------------------------------------------------
set scrolloff=8 "make page start scroll before reach bottom.
set signcolumn=no "column to left for signs etc.
set expandtab "make tab always spaces.
set tabstop=4 "number of spaces a tab counts for.
set softtabstop=4 "number of spaces when inserting a tab.
set backspace=indent,eol,start "make backspace delete lots of things
set autoindent "do clever indent things. Don't make a # force column zero.
set smartindent
set whichwrap+=<,>,[,] "wrap on these
set path+=Documents/ "better include path handling
let &inc.=' ["<]'

" -----------------------------------------------------------------------------
" Keymappings
" -----------------------------------------------------------------------------
let mapleader = " " "set leader key

"general
:nnoremap Y yg_
:nnoremap <CR> :nohlsearch<cr>
"sudo save
cmap w!! w !sudo tee % >/dev/null
"keeping it centered.
:nnoremap n nzzzv
:nnoremap N Nzzzv
:nnoremap J mzJ`z
"movement
:nnoremap <silent> <c-k> :call smooth_scroll#up(&scroll, 3, 2)<CR>
:nnoremap <silent> <c-j> :call smooth_scroll#down(&scroll, 3, 2)<CR>
"search
:nnoremap <leader>g :Rg<cr>
:nnoremap <leader>f :GFiles<cr>
:nnoremap <leader>F :Files<cr>
:nnoremap <leader>b :Buffers<cr>
:nnoremap <Leader>l :BLines<CR>
:nnoremap <Leader>L :Lines<CR>
"golang
:nnoremap <Leader><CR> :GoBuild<CR>
:nnoremap <Leader>r :GoRun<CR>
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

