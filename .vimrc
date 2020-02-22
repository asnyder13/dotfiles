au BufReadPost *.npmrc set syntax=dosini
au BufReadPost *bash-fc* set syntax=sh

" General config
set clipboard=unnamed
set number
set cursorline
set tabstop=2
set shiftwidth=2
set noexpandtab
set ai
set showmatch
set vb
set showmode
set wildmode=list:longest,longest:full

" Searching
set hlsearch
set ignorecase
set smartcase

" Folding
set foldmethod=syntax
set foldlevelstart=3

" Syntax hl/colors
syntax on
colorscheme monokai

" Remaps
"  Quick Easymotion
map <Leader> <Plug>(easymotion-prefix)
"  Collapse all levels under current fold
nnoremap zs zCzozo
"  Quick buffer switch (for tabline)
nnoremap gbn :bn<CR>
nnoremap gbN :bN<CR>
nnoremap gbd :bd<CR>
"  Quick buffer list
nnoremap <leader>b :ls<CR>:b<Space>

" netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

" Plugin settings
let g:bufferline_echo = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
set wildignore+=*\\node_modules\\* " Windows
set wildignore+=*/node_modules/*   " Unix
let g:EasyMotion_smartcase = 1
let gsneak#use_ic_scs = 1
let gsneak#map_netrw = 1

