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
" Initialize plugin system. Run :PlugInstall to install.
call plug#end()

" -----------------------------------------------------------------------------
" System
" -----------------------------------------------------------------------------
let g:auto_save = 1 "Make sure we autosave always.
set nocompatible "Don't be compatible with old vi.
set t_Co=256 "256 colors
set noswapfile "Dont want any .swp laying around.
set nobackup " Dont create any backup files.
set undodir=~/.vim/undodir "persistent undo
set undofile
set viminfo='1000,f1,:1000,/1000 "Enable a nice big viminfo file
set history=500
" this is handled by LanguageClient [LC]
let g:go_def_mapping_enabled = 0


" -----------------------------------------------------------------------------
" Look & Feel
" -----------------------------------------------------------------------------
colorscheme palenight "https://github.com/drewtempelmeyer/palenight.vim.git
let g:palenight_terminal_italics=1 "Italics for my favorite color scheme
syntax on "Syntax on for showing colors from scheme.
filetype on "Detect file type.
filetype plugin indent on
set showcmd "Show us the command we're typing
set noshowmode "Hide default message when entering modes.
set cursorline "Make clear what line we are on.
let &t_SI = "\<esc>[5 q" " I beam cursor for insert mode
let &t_EI = "\<esc>[2 q" " block cursor for normal mode
let &t_SR = "\<esc>[3 q" " underline cursor for replace mode
set formatoptions-=ro
set visualbell t_vb= "No bell
set noerrorbells
set hidden "Allow edit buffers to be hidden
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
set infercase  " infers case in insert mode and autocomplete.
set hlsearch " hightligths search, <CR> after search to remove.
set showmatch "Highlight matching parentes
hi Search cterm=NONE ctermfg=grey ctermbg=blue
set showfulltag "Show full tags when doing search completion

" -----------------------------------------------------------------------------
" Text Objects
" -----------------------------------------------------------------------------
set guicursor+=a:blinkon0
set expandtab "Make tab always spaces.
set scrolloff=8
set signcolumn=no " Column to left for signs etc.
set tabstop=4
set softtabstop=4
set backspace=indent,eol,start "Make backspace delete lots of things
set autoindent "Do clever indent things. Don't make a # force column zero.
set smartindent
set whichwrap+=<,>,[,] "Wrap on these
set path+=Documents/ "Better include path handling
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
let mapleader = " " "Set leader key

" General
:nnoremap Y yg_
:nnoremap <CR> :nohlsearch<cr>

" Sudo Save
cmap w!! w !sudo tee % >/dev/null

" Keeping it centered.
:nnoremap n nzzzv
:nnoremap N Nzzzv
:nnoremap J mzJ`z

" Movement
:nnoremap <silent> <c-k> :call smooth_scroll#up(&scroll, 3, 2)<CR>
:nnoremap <silent> <c-j> :call smooth_scroll#down(&scroll, 3, 2)<CR>

" FZF
:nnoremap <leader>g :Rg<cr>
:nnoremap <leader>f :GFiles<cr>
:nnoremap <leader>F :Files<cr>
:nnoremap <leader>b :Buffers<cr>
:nnoremap <Leader>l :BLines<CR>
:nnoremap <Leader>L :Lines<CR>

" Buffers
:nnoremap <Tab> :bnext<cr>
:nnoremap <S-Tab> :bprevious<cr>

" Golang
:nnoremap <Leader><CR> :GoBuild<CR>
:nnoremap <Leader>r :GoRun<CR>

" Coc
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)
" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Use U to show documentation in preview window
nnoremap <silent> U :call <SID>show_documentation()<CR>
" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
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

