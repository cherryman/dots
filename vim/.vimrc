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
Plug 'vim-airline/vim-airline-themes'

" interface
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'easymotion/vim-easymotion'
Plug 'bimlas/vim-high'
Plug 'edkolev/tmuxline.vim'

" util
Plug 'junegunn/fzf', {'dir': '~/.local/src/fzf', 'do': './install --bin'}
Plug 'scrooloose/nerdtree'
Plug 'embear/vim-localvimrc'
Plug 'thaerkh/vim-workspace'

" edit
Plug 'Raimondi/delimitMate'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
Plug 'terryma/vim-expand-region'
Plug 'tpope/vim-speeddating'

" prog
Plug 'w0rp/ale'
Plug 'tpope/vim-dispatch'

" lang
Plug 'sheerun/vim-polyglot'
Plug 'lervag/vimtex'
Plug 'jceb/vim-orgmode'
Plug 'vim-scripts/SyntaxRange'

call plug#end()

" install missing plugins
autocmd VimEnter *
    \   if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \ |     PlugInstall --sync | q
    \ | endif

"}}}
" ---- Functions {{{

" set the colorscheme highlight values
function! SetHighlight()
    highlight SignColumn ctermbg=none

    highlight GitGutterAdd ctermfg=2 ctermbg=none
    highlight GitGutterChange ctermfg=3 ctermbg=none
    highlight GitGutterDelete ctermfg=1 ctermbg=none
    highlight GitGutterChangeDelete ctermfg=3 ctermbg=none
endfunction

" commands
command! ToggleSyntax
\   if exists("g:syntax_on")
\ |     syntax off
\ | else
\ |     syntax enable
\ | endif

command! -nargs=1 -complete=dir Files
\   call fzf#run(fzf#wrap('files', {
\                         'source': g:fzf_files_source,
\                         'dir': <q-args>}, 0))

command! Buffers
\   call fzf#run(fzf#wrap('buffers', {
\                         'source': map(range(1, bufnr('$')),
\                         'bufname(v:val)')}))

"}}}
" ---- Colours {{{
filetype plugin on
syntax enable

let g:seoul256_background = 233
let g:base16colorspace = 256
"set background=dark

" highlight options are under 'SetHighlight()'
autocmd ColorScheme * call SetHighlight()

let g:airline_theme='base16_spacemacs'
colorscheme base16-spacemacs

"}}}
" ---- Indentation {{{
set tabstop=4     " ts
set softtabstop=4 " sts
set expandtab     " et
set shiftwidth=4  " sw

augroup indent
    au!
    au FileType asm setl noet ts=6 sw=6 sts=0
    au FileType make setl noet ts=8 sw=8 sts=0
    au FileType go setl noet
    au FileType *tex setl tw=79
    au FileType markdown setl tw=79
augroup END

"}}}
" ---- Interface {{{
filetype indent on

set number " line numbers
set cursorline " highlight line under cursor
set lazyredraw " redraw only when necessary
set laststatus=2 " open statusline

set noshowmatch " highlight matching bracket
set incsearch " search while typing
set hlsearch " highlight search

set splitbelow " open below instead of above

set mouse=a " mouse movement

"}}}
" ---- Keybinds {{{

let mapleader = "\<Space>"

map Y y$
imap jk <esc>
xmap <Leader>+ <Plug>(expand_region_expand)
xmap <Leader>- <Plug>(expand_region_shrink)
map <C-w>- <C-w>s
map <C-w>\ <C-w>v

cmap <C-a> <Home>
cmap <C-e> <End>
cmap <C-f> <Right>
cmap <C-b> <Left>
cmap <A-f> <S-Right>
cmap <A-b> <S-Left>

nmap <Leader>a <Plug>(EasyAlign)
xmap <Leader>a <Plug>(EasyAlign)

map <Leader>fo :Files .<CR>
map <Leader>ft :NERDTreeToggle<CR>
map <Leader>fs :write<CR>
map <Leader>fS :wall<CR>

map <Leader>qq :qall<CR>
map <Leader>qs :wqall<CR>
map <Leader>qQ :qall!<CR>

map <Leader>j <Plug>(easymotion-prefix)

map <Leader>tn :set number!<CR>
map <Leader>tr :set relativenumber!<CR>
map <Leader>th :ToggleSyntax<CR>
map <Leader>tl <Plug>(ale_toggle)
map <Leader>ts :ToggleWorkspace<CR>

nmap <Leader>w <C-w>

nmap <Leader>bb :Buffers<CR>
nmap <Leader>b[ :1bprevious<CR>
nmap <Leader>b] :1bNext<CR>

nmap <Leader>ll <Plug>(ale_lint)
nmap <Leader>li <Plug>(ale_detail)
nmap <Leader>l[ <Plug>(ale_previous_wrap)
nmap <Leader>l] <Plug>(ale_next_wrap)

"}}}
" ---- Plugin Configuration {{{
" ale
let g:ale_sign_column_always = 1
let g:ale_sign_info = '-'
let g:ale_sign_warning = '*'
let g:ale_sign_style_warning = '>'
let g:ale_sign_error = '>'
let g:ale_sign_style_error = '>'
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_open_list = 0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_save = 0
let g:ale_link_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 0
let g:ale_enabled = 0
let g:ale_linters = {
\   'rust': ['cargo'],
\   'bash': ['shellcheck'],
\   'sh':   ['shellcheck']
\}

" delimitMate
let g:delimitMate_expand_cr = 1

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

" local-vimrc
let g:localvimrc_name = ['.lvimrc', '_vimrc_local.vim']
let g:localvimrc_whitelist = $HOME.'/projects'

" polyglot
let g:polyglot_disabled = [
\   'latex',
\ ]

" vim-airline
" colour set under "Colours"
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

" vim-workspace
let g:workspace_session_name = 'Session.vim'
let g:workspace_autosave = 0
let g:workspace_autosave_always = 0
let g:workspace_autosave_untrailspaces = 0
let g:workspace_autosave_ignore = [
\   'gitcommit',
\ ]

"}}}
" ---- Misc {{{
set modeline
set modelines=1

set hidden

set scrolloff=3

"}}}

" vim:foldmethod=marker:foldlevel=0
