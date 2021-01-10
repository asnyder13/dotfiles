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
set scrolloff=0

set lazyredraw
set confirm
set nobackup
set viminfo='20,\"500
set hidden
set history=1000

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
" Highlight tab indents
set list lcs=tab:\|\ 
highlight SpecialKey ctermbg=NONE guibg=NONE

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
nnoremap <leader>b :ls<CR>:b

" netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25

""""""" Plugin settings
" Airline
let g:bufferline_echo = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" Ctrlp
let g:ctrlp_show_hidden = 1
set wildignore+=*\\node_modules\\* " Windows
set wildignore+=*/node_modules/*   " Unix
set wildignore+=*/.git/*,*/tmp/*,*.swp

" Easymotion
let g:EasyMotion_smartcase = 1

" Sneak
let g:sneak#use_ic_scs = 1
let g:sneak#map_netrw = 1

" Highlighted yank
let g:highlightedyank_highlight_duration = 500

" Polyglot
let g:ruby_recommended_style = 0

" Signature
let g:SignatureMarkTextHLDynamic = 1

" Rubocop
nmap <Leader>ra :RuboCop -a<CR>
