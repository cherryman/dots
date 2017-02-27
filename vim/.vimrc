execute pathogen#infect() 

let skip_defaults_vim=1


" ---- Misc
colorscheme molokai
filetype plugin on
syntax on


" ---- Indentation
set tabstop=4
set softtabstop=4
set expandtab


" ---- Interface
set number
set cursorline " highlight line under cursor
filetype indent on
set lazyredraw " redraw only when necessary

set showmatch " highlight matching bracket
set incsearch " search while typing
set hlsearch " highlight search


" ---- Movement
set mouse=a


" ---- Keybinds
let mapleader="\"

nnoremap gV `[v`]
