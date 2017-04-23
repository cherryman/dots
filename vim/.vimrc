let skip_defaults_vim=1

" ---- Plug {{{
runtime vim-plug/plug.vim

call plug#begin('~/.vim/plugged')


" themes
Plug 'sjl/badwolf'
Plug 'tomasr/molokai'
Plug 'junegunn/seoul256.vim'
Plug 'chriskempson/base16-vim'

" interface
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/limelight.vim'
Plug 'bimlas/vim-high'

" util
Plug 'tpope/vim-fugitive'
Plug 'alexdavid/vim-min-git-status'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'junegunn/fzf', {'dir': '~/.local/opt/fzf', 'do': './install --bin'}
Plug 'LucHermitte/lh-vim-lib'
Plug 'LucHermitte/local_vimrc' " dep lh-vim-lib

" edit
Plug 'Raimondi/delimitMate'
Plug 'junegunn/vim-easy-align'
Plug 'terryma/vim-expand-region'

" prog
Plug 'vim-syntastic/syntastic'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-dispatch'


call plug#end()

"}}}
" ---- Autocmd {{{

" install missing plugins
autocmd VimEnter *
    \   if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \ |     PlugInstall --sync | q
    \ | endif


" set highlight options
autocmd ColorScheme * call SetHighlight()

"}}}
" ---- Functions {{{

" set the colorscheme highlight values
function SetHighlight()
    highlight SignColumn ctermbg=none

    highlight CtrlPNoEntries ctermfg=39
    highlight CtrlPLinePre ctermfg=12
    highlight CtrlPPrtBase ctermfg=12

    highlight GitGutterAdd ctermfg=2 ctermbg=none
    highlight GitGutterChange ctermfg=3 ctermbg=none
    highlight GitGutterDelete ctermfg=1 ctermbg=none
    highlight GitGutterChangeDelete ctermfg=3 ctermbg=none
endfunction


" commands
command ToggleRelativeNum let &relativenumber = ! &relativenumber

command -nargs=1 -complete=dir Files
\      call fzf#run(fzf#wrap('files', {
\                            'source': g:fzf_files_source,
\                            'dir': <q-args>}, 0))

command Buffers
\     call fzf#run(fzf#wrap('buffers', {
\                           'source': map(range(1, bufnr('$')),
\                           'bufname(v:val)')}))

"}}}
" ---- Colors {{{
filetype plugin on
syntax on

let g:seoul256_background = 233
let g:base16colorspace = 256

colorscheme badwolf

" highlight options are under 'SetHighlight()'
" set using an autocmd

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

xmap + <Plug>(expand_region_expand)
xmap - <Plug>(expand_region_shrink)


" <Space> :: main
let mapleader = "\<Space>"
map <Leader>w <C-w>
map <Leader>o :Files .<CR>
map <Leader>n :ToggleRelativeNum<CR>

" !! toggles, other is for visual selection
nmap <Leader>l :Limelight!!<CR>
xmap <Leader>l :Limelight<CR>

map <Leader>j <Plug>(easymotion-prefix)


" <Space>b :: buffer
let mapleader = "\<Space>b"
nmap <Leader>b :Buffers<CR>


" <Space>s :: git
let mapleader = "\<Space>s"
nmap <Leader>s :Gministatus<CR>
nmap <Leader>b :Gblame<CR>


" <Space>e :: edit
let mapleader = "\<Space>e"
nmap <Leader>a <Plug>(EasyAlign)
xmap <Leader>a <Plug>(EasyAlign)


" reset mapleader
let mapleader = "\<Space>"

"}}}
" ---- Plugin Configuration {{{
" easygit
let g:easygit_enable_command = 1


" fzf
let g:fzf_layout = { 'down': '~20%'}
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'
\ }
if executable('ag')
    let g:fzf_files_source = 'ag . -g "" --hidden --nocolor
                            \ --ignore ".git"'
elseif executable('find')
    let g:fzf_files_source = 'find .'
endif


" limelight
let g:limelight_default_coefficient = 0.8
let g:limelight_paragraph_span = 1

" local-vimrc
let g:local_vimrc = ['_vimrc_local.vim']
call lh#local_vimrc#munge('whitelist', $HOME.'/git')
call lh#local_vimrc#munge('whitelist', $HOME.'/projects')

" syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height = 5
let g:syntastic_mode_map = {
    \ "mode": "passive"
\ }

" vim-airline
let g:airline_theme='badwolf'
let g:airline_powerline_fonts = 1

" vim-gitgutter
let g:gitgutter_override_sign_column_highlight = 0


" vim-high
let g:high_lighters = {
\   'long_line': {},
\}

"}}}
" ---- Misc {{{
set modeline
set modelines=1

set hidden

set scrolloff=3

"}}}

" vim:foldmethod=marker:foldlevel=0
