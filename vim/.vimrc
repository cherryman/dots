let skip_defaults_vim=1

" ---- Plug {{{
runtime vim-plug/plug.vim

call plug#begin('~/.vim/plugged')


" themes
Plug 'sjl/badwolf'
Plug 'tomasr/molokai'
Plug 'junegunn/seoul256.vim'
Plug 'chriskempson/base16-vim'
Plug 'w0ng/vim-hybrid'

" interface
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'junegunn/limelight.vim'
Plug 'bimlas/vim-high'
Plug 'edkolev/tmuxline.vim'

" util
Plug 'tpope/vim-fugitive'
Plug 'alexdavid/vim-min-git-status'
Plug 'junegunn/fzf', {'dir': '~/.local/src/fzf', 'do': './install --bin'}
Plug 'scrooloose/nerdtree'
Plug 'embear/vim-localvimrc'

" edit
Plug 'Raimondi/delimitMate'
Plug 'junegunn/vim-easy-align'
Plug 'terryma/vim-expand-region'

" prog
Plug 'w0rp/ale'
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

set background=dark
colorscheme hybrid

" highlight options are under 'SetHighlight()'
" set using an autocmd

"}}}
" ---- Indentation {{{
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4

augroup indent
    au!
    au FileType go setl noexpandtab
    au FileType *tex setl textwidth=79
augroup END

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

"xmap + <Plug>(expand_region_expand)
"xmap - <Plug>(expand_region_shrink)

map <C-w>- <C-w>h
map <C-w>\ <C-w>v

" <Space> :: main
let mapleader = "\<Space>"
map <Leader>w <C-w>
map <Leader>fo :Files .<CR>
map <Leader>ft :NERDTreeToggle<CR>
map <Leader>n :ToggleRelativeNum<CR>

map <Leader>j <Plug>(easymotion-prefix)


" <Space>b :: buffer
let mapleader = "\<Space>b"
nmap <Leader>b :Buffers<CR>
nmap <Leader>[ :1bprevious<CR>
nmap <Leader>] :1bNext<CR>

" <Space>e :: edit
let mapleader = "\<Space>e"
nmap <Leader>a <Plug>(EasyAlign)
xmap <Leader>a <Plug>(EasyAlign)

" <Space>l :: linter
let mapleader = "\<Space>l"
nmap <Leader>l <Plug>(ale_lint)
nmap <Leader>i <Plug>(ale_detail)
nmap <Leader>[ <Plug>(ale_previous_wrap)
nmap <Leader>] <Plug>(ale_next_wrap)
nmap <Leader>o :copen<CR>

" reset mapleader
let mapleader = "\<Space>"

"}}}
" ---- Plugin Configuration {{{
" ale
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_open_list = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_save = 0
let g:ale_link_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0


" easygit
let g:easygit_enable_command = 1


" fzf
let g:fzf_layout = { 'down': '~20%'}
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit'
\ }
if executable('rg')
    let g:fzf_files_source = 'rg --files --hidden --color never
                            \ --ignore-file ".git"'
elseif executable('ag')
    let g:fzf_files_source = 'ag . -g "" --hidden --nocolor
                            \ --ignore ".git"'
elseif executable('find')
    let g:fzf_files_source = 'find .'
endif


" limelight
let g:limelight_default_coefficient = 0.8
let g:limelight_paragraph_span = 1


" local-vimrc
let g:localvimrc_name = ['.lvimrc', '_vimrc_local.vim']
let g:localvimrc_whitelist = $HOME.'/projects'


" vim-airline
let g:airline_theme='tomorrow'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1


" vim-gitgutter
let g:gitgutter_override_sign_column_highlight = 0


" vim-high
let g:high_lighters = {
\   '_': {
\       'blacklist': ['help', 'qf', 'lf', 'vim-plug'],
\   },
\   'long_line': {},
\   'mixed_indent': {'hlgroup': 'Error'},
\ }


"}}}
" ---- Misc {{{
set modeline
set modelines=1

set hidden

set scrolloff=3

"}}}

" vim:foldmethod=marker:foldlevel=0
