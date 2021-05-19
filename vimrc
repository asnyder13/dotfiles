autocmd BufNewFile,BufRead *.npmrc   set syntax=dosini
autocmd BufNewFile,BufRead *bash-fc* set syntax=sh

" General config
set clipboard=unnamed
set number
set cursorline
set tabstop=2
set shiftwidth=2
set noexpandtab
set autoindent
set showmatch
set visualbell
set showmode
set wildmode=list:longest,longest:full
set scrolloff=0

set confirm
set nobackup
set viminfo='20,\"500
set hidden
set history=1000
set termguicolors

autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" https://github.com/jeffkreeftmeijer/vim-numbertoggle
augroup NumberToggle
	autocmd!
	autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
	autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Searching
set hlsearch
set ignorecase
set smartcase

" Folding
set foldmethod=syntax
set foldlevelstart=99

" Syntax hl/colors
syntax on
colorscheme monokai
" Highlight tab indents
set list lcs=tab:\|\ 
" Regular Vim does weird stuff to the highlighting of the indent markers.
if !has('nvim')
	highlight SpecialKey cterm=NONE ctermfg=darkgray ctermbg=NONE
endif

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
if !has('nvim')
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
	" Matchit
	let loaded_matchit = 1
endif

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
nmap <Leader>r :RuboCop <CR>

