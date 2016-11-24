"
" LEADER KEYS
"
let mapleader = " "
let maplocalleader = " "

"
" PLUGINS
"
call plug#begin('~/.config/nvim/plugged')

Plug 'morhetz/gruvbox'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

"
" VISUAL SETTINGS
"
set background=dark

" gruvbox
let g:gruvbox_contrast_dark='medium'
colorscheme gruvbox

" airline
let g:airline_theme='gruvbox'
let g:airline_powerline_fonts=1


"
" GENERAL SETTINGS
"

set laststatus=2
