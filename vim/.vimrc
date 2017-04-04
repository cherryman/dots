runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

let skip_defaults_vim=1


" ---- Colors
colorscheme badwolf
filetype plugin on
syntax on

highlight Normal ctermbg=none
highlight NonText ctermbg=none
highlight LineNr ctermbg=none
highlight Directory ctermfg=004


" ---- Indentation
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4


" ---- Interface
set number
set cursorline " highlight line under cursor
filetype indent on
set lazyredraw " redraw only when necessary
set laststatus=2

set showmatch " highlight matching bracket
set incsearch " search while typing
set hlsearch " highlight search


" ---- Movement
set mouse=a


" ---- Keybinds
let mapleader="\\"

map <Leader>o :NERDTreeToggle<CR>
nnoremap gV `[v`]


" ---- Plugins

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
