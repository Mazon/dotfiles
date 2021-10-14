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
Plug '908th/vim-auto-save'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"initialize plugin system. Run :PlugInstall to install.
call plug#end()

" -----------------------------------------------------------------------------
" System
" -----------------------------------------------------------------------------
let g:auto_save = 1 "make sure we autosave always.
set nocompatible "don't be compatible with old vi.
set t_Co=256 "256 colors
set noswapfile "dont want any .swp laying around.
set nobackup " dont create any backup files.
set undodir=~/.vim/undodir "persistent undo
set undofile
set viminfo='1000,f1,:1000,/1000 "enable a nice big viminfo file
set history=500
let g:go_def_mapping_enabled = 0 " this is handled by LanguageClient [LC]

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
"autocmd InsertLeave * highlight CursorLine guibg=#004000 guifg=fg

" -----------------------------------------------------------------------------
" Search
" -----------------------------------------------------------------------------
set incsearch "incremental search
set ignorecase "ignore case
set infercase  "infers case in insert mode and autocomplete.
set hlsearch "hightligths search, <CR> after search to remove.
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
" Statusline
" -----------------------------------------------------------------------------
let g:airline#extensions#tabline#enabled = 0
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline_powerline_fonts=1
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_theme = "onedark"

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
"buffers
:nnoremap <Tab> :bnext<cr>
:nnoremap <S-Tab> :bprevious<cr>
"golang
:nnoremap <Leader><CR> :GoBuild<CR>
:nnoremap <Leader>r :GoRun<CR>

"coc
"use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
"use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)
"remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
"use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>
"remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
"remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
"show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
"manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
"show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
"find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
"search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
"do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
"do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
"resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
"use tab for trigger completion with characters ahead and navigate.
"use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"



" -----------------------------------------------------------------------------
" Functions
" -----------------------------------------------------------------------------
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

