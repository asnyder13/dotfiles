local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api

cmd('packadd paq-nvim')
local paq = require'paq-nvim'.paq
paq{'savq/paq-nvim', opt=true}

-- Regular vim
paq 'ntpeters/vim-better-whitespace'
paq 'tpope/vim-commentary'
paq 'airblade/vim-gitgutter'
paq 'machakann/vim-highlightedyank'
paq 'sheerun/vim-polyglot'
paq 'vim-scripts/ReplaceWithRegister'
paq 'ngmy/vim-rubocop'
paq 'justinmk/vim-sneak'
paq 'kshenoy/vim-signature'
paq 'tpope/vim-surround'
paq 'tpope/vim-vinegar'
paq 'crusoexia/vim-monokai'

-- Neovim specific
paq 'norcalli/nvim-colorizer.lua'
paq 'ojroques/nvim-hardline'
paq 'phaazon/hop.nvim'
paq 'nvim-lua/plenary.nvim'
paq 'nvim-lua/popup.nvim'
paq 'nvim-telescope/telescope.nvim'

-- Old vimrc
cmd([[
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
	let g:monokai_term_italic = 1
	let g:monokai_gui_italic = 1
	" Highlight tab indents
	set list lcs=tab:\|\ 

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
]])

cmd([[
	" guard for distributions lacking the persistent_undo feature.
	if has('persistent_undo')
		" define a path to store persistent_undo files.
		let target_path = expand('~/.local/share/nvim/nvim-persisted-undo/')

		" create the directory and any parent directories
		" if the location does not exist.
		if !isdirectory(target_path)
			call system('mkdir -p ' . target_path)
		endif

		" point Vim to the defined undo directory.
		let &undodir = target_path

		" finally, enable undo persistence.
		set undofile
	endif
]])

require('colorizer').setup()
require('hardline').setup({
	bufferline = true,
	bufferline_settings = {
		show_index = true
	},
	theme = 'default'
})

-- Mappings
local function map(mode, lhs, rhs, opts)
	local options = {noremap = true}
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Telescope
map('', '<C-p>', '<cmd>lua require("telescope.builtin").find_files({hidden = true})<cr>')
-- Hop
map('n', '<leader>f', "<cmd>lua require('hop').hint_char1()<CR>")
map('n', '<leader>w', "<cmd>lua require('hop').hint_words()<CR>")
