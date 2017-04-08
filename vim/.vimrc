let skip_defaults_vim=1

" ---- Plug {{{
runtime vim-plug/plug.vim

call plug#begin('~/.vim/plugged')


" themes
Plug 'sjl/badwolf'
Plug 'tomasr/molokai'

" interface
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive'
Plug 'alexdavid/vim-min-git-status'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-gitgutter'

" lang
Plug 'vim-syntastic/syntastic'
Plug 'sheerun/vim-polyglot'


call plug#end()

"}}}
" ---- Autocmd {{{

" Install missing plugins
autocmd VimEnter *
    \   if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \ |     PlugInstall --sync | q
    \ | endif

"}}}
" ---- Colors {{{
colorscheme badwolf
filetype plugin on
syntax on

highlight CtrlPNoEntries ctermfg=39
highlight CtrlPLinePre ctermfg=12
highlight CtrlPPrtBase ctermfg=12

"}}}
" ---- Indentation {{{
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4

"}}}
" ---- Interface {{{
filetype indent on

set number " line numbers
set cursorline " highlight line under cursor
set lazyredraw " redraw only when necessary
set laststatus=2 " open statusline

set showmatch " highlight matching bracket
set incsearch " search while typing
set hlsearch " highlight search

set splitbelow " open below instead of above

set mouse=a " mouse movement

"}}}
" ---- Keybinds {{{
nnoremap gV `[v`]
map ; :

" <Space>
let mapleader="\<Space>"
map <Leader>w <C-w>
map <Leader>o :CtrlP<CR>

" <Space>g
let mapleader="\<Space>g"
map <Leader>sb :Gministatus<CR>
map <Leader>bl :Gblame<CR>

"}}}
" ---- Plugin Configuration {{{
" ctrlp
let g:ctrlp_show_hidden = 1

" easygit
let g:easygit_enable_command = 1

" syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" vim-airline
let g:airline_theme='badwolf'
let g:airline_powerline_fonts = 1

"}}}
" ---- Misc {{{
set modeline
set modelines=1

"}}}

" vim:foldmethod=marker:foldlevel=0
