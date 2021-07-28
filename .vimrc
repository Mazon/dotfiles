"Plugins
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'fatih/vim-go'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'terryma/vim-smooth-scroll'
Plugin 'junegunn/fzf.vim'
Plugin 'lambdalisue/fern.vim'
call vundle#end()

"General
set nocompatible "Don't be compatible with old vi.
set t_Co=256 "256 colors
set background=dark
colorscheme palenight "https://github.com/drewtempelmeyer/palenight.vim.git
" Italics for my favorite color scheme
let g:palenight_terminal_italics=1

syntax on "Syntax on for showing colors from scheme.
filetype on "Detect file type.
filetype plugin indent on
set noswapfile "Dont want any .swp laying around.
set clipboard=unnamed "Clipboard sync os x
set viminfo='1000,f1,:1000,/1000 "Enable a nice big viminfo file
set history=500
set showcmd "Show us the command we're typing
set cursorline "Make clear what line we are on.
let &t_SI = "\<esc>[5 q" " I beam cursor for insert mode
let &t_EI = "\<esc>[2 q" " block cursor for normal mode
let &t_SR = "\<esc>[3 q" " underline cursor for replace mode
autocmd InsertLeave * highlight CursorLine guibg=#004000 guifg=fg
set formatoptions-=ro
set visualbell t_vb= "No bell
set hidden "Allow edit buffers to be hidden
set winminheight=1 "1 height windows
"Use both relative and absolute numbering for best of both worlds.
set relativenumber
set number

"Search
set incsearch
set ignorecase
set infercase
set hlsearch
set showmatch "Highlight matching parentes
hi Search cterm=NONE ctermfg=grey ctermbg=blue
set showfulltag "Show full tags when doing search completion
set rtp+=/sbin/fzf "Fuzzy search

"Text
set shiftwidth=2 "By default, go for an indent of 2
set expandtab "Make tab always spaces.
set tabstop=2
set softtabstop=2
set backspace=indent,eol,start "Make backspace delete lots of things
set autoindent "Do clever indent things. Don't make a # force column zero.
set smartindent
set whichwrap+=<,>,[,] "Wrap on these
set fillchars=vert:┃,diff:⎼,fold:⎼
set path+=Documents/ "Better include path handling
let &inc.=' ["<]'

"Statusline
set noshowmode "Hide default message when entering modes.
set nomodeline "Disable modelines, use securemodelines.vim instead
let g:airline_powerline_fonts=0
let g:airline_theme = "palenight"
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#hunks#non_zero_only = 1
set laststatus=2
set statusline=
set statusline+=%-3.3n\   "Buffer number
set statusline+=%f\       "File name
set statusline+=%=        "Right align
set statusline+=%2*
setlocal numberwidth=3
let g:secure_modelines_verbose = 0
let g:secure_modelines_modelines = 15

"Keymappings
let mapleader = "," "Set leader key
"Movement
:nnoremap <silent> <c-k> :call smooth_scroll#up(&scroll, 3, 2)<CR>
:nnoremap <silent> <c-j> :call smooth_scroll#down(&scroll, 3, 2)<CR>
"FZF
:nnoremap <leader>f :GFiles<cr>
:nnoremap <leader>F :Files<cr>
:nnoremap <leader>b :Buffers<cr>
:nnoremap <leader>g :Rg<cr>
:nnoremap <Leader>l :BLines<CR>
:nnoremap <Leader>L :Lines<CR>
"Fern
:nnoremap <Leader>p :Fern . -drawer -toggle<CR>
"Buffers
:nnoremap <Tab> :bnext<cr>
:nnoremap <S-Tab> :bprevious<cr>
"Misc
"Set Paste
:nnoremap <Leader>pp :set paste!<CR>
"Remove search highlight.
:nnoremap <CR> :nohlsearch<cr>
"Sudo Save
cmap w!! w !sudo tee % >/dev/null
