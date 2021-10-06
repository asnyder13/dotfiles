require 'util'
local map = Util.map

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api
local opt = vim.opt

cmd 'packadd paq-nvim'
local paq = require'paq-nvim'.paq
paq { 'savq/paq-nvim', opt=true }

-- Regular vim
paq 'ntpeters/vim-better-whitespace'
paq 'tpope/vim-commentary'
paq 'justinmk/vim-dirvish'
paq 'airblade/vim-gitgutter'
paq 'tpope/vim-fugitive'
paq 'vim-scripts/ReplaceWithRegister'
paq 'ngmy/vim-rubocop'
paq 'vim-ruby/vim-ruby'
paq 'justinmk/vim-sneak'
paq 'kshenoy/vim-signature'
paq 'tpope/vim-surround'
paq 'crusoexia/vim-monokai'

-- Neovim specific
paq 'norcalli/nvim-colorizer.lua'
paq 'ojroques/nvim-hardline'
paq 'phaazon/hop.nvim'
paq 'nvim-lua/plenary.nvim'
paq 'nvim-lua/popup.nvim'
paq 'nvim-telescope/telescope.nvim'
paq 'lukas-reineke/indent-blankline.nvim'

if vim.env.VIM_USE_LSP then
	paq { 'nvim-treesitter/nvim-treesitter', run=':TSUpdate' }
	paq 'neovim/nvim-lspconfig'
	paq 'kabouzeid/nvim-lspinstall'
	paq 'hrsh7th/nvim-compe'
end
---- General Settings ----

-- Auto commands
cmd([[
	" Sytaxes
	autocmd BufNewFile,BufRead *.npmrc   set syntax=dosini
	autocmd BufNewFile,BufRead *bash-fc* set syntax=sh

	" https://github.com/jeffkreeftmeijer/vim-numbertoggle
	augroup NumberToggle
		autocmd!
		autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
		autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
		autocmd OptionSet                                 * if !&nu                 | set nornu | endif
		autocmd OptionSet                                 * if &nu                  | set rnu   | endif
	augroup END
]])

-- General
cmd 'au TextYankPost * silent! lua vim.highlight.on_yank { timeout=350 }'
-- Don't auto-comment on a new line
opt.formatoptions:remove { 'c', 'r', 'o' }
opt.clipboard = 'unnamed'
opt.number = true
opt.cursorline = true
local indent_size = 2
opt.tabstop = indent_size
opt.shiftwidth = indent_size
opt.expandtab = false
opt.autoindent = true
opt.showmatch = true
opt.visualbell = true
opt.showmode = true
opt.wildmode = { 'full' }
opt.scrolloff = 0
opt.wildignore:append { '*/node_modules/*', '*/.git/*', '*/tmp/*', '*.swp' }
opt.splitright = true
opt.splitbelow = true

opt.confirm = true
opt.backup = false
opt.hidden = true
opt.history = 1000
opt.termguicolors = true

-- Searching
opt.hlsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.foldmethod = 'indent'
opt.foldlevelstart = 99

-- Syntax hl/colors
opt.syntax = 'on'
cmd 'colorscheme monokai'
g.monokai_term_italic = true
g.monokai_gui_italic = true

-- Persistent Undo/Redo
if fn.has('persistent_undo') == 1 then
	local target_path = Util.create_expand_path('~/.local/share/nvim/nvim-persisted-undo/')
	opt.undodir = target_path
	opt.undofile = true
end

---- General Mappings ----
-- Collapse all levels under current fold
map('n', 'zs', 'zCzozo', { noremap = true })
-- Quick buffer switch (for tabline)
map('n', 'gbn', ':bn<CR>', { noremap = true })
map('n', 'gbN', ':bN<CR>', { noremap = true })
map('n', 'gbd', ':bd<CR>', { noremap = true })
map('n', '<BS>', '<C-^>')

cmd([[
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
]])

---- Plugin Settings ----
-- Vim plugins
-- netrw
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_browse_split = 4
g.netrw_altv = 1
g.netrw_winsize = 25
-- Sneak
cmd([[
	let g:sneak#use_ic_scs = 1
	let g:sneak#map_netrw = 1
]])
-- Highlighted yank
g.highlightedyank_highlight_duration = 500
-- Polyglot
g.ruby_recommended_style = 0
-- Signature
g.SignatureMarkTextHLDynamic = 1
-- Rubocop
map('n', '<LEADER>r', ':RuboCop <CR>')
-- Dirvish
g.loaded_netrwPlugin = 1

-- Neovim plugins
require'colorizer'.setup()
require'hardline'.setup({
	bufferline = true,
	bufferline_settings = { show_index = true },
	theme = 'default'
})
-- Telescope
require'telescope'.setup{ defaults = { file_ignore_patterns = {'node_modules'} } }
map('', '<C-p>', '<cmd>lua require("telescope.builtin").find_files({ hidden = false })<cr>')
map('', '<C-M-p>', '<cmd>lua require("telescope.builtin").find_files({ hidden = true })<cr>')
map('', '<M-p>', '<cmd>lua require("telescope.builtin").file_browser()<cr>')
map('', '<C-g>', '<cmd>lua require("telescope.builtin").git_files()<cr>')
map('', '<leader>b', '<cmd>lua require("telescope.builtin").buffers()<cr>')
-- Hop
require'hop'.setup { keys = ',;abcdefgimnorstuvwxz' }
map('n', '<leader>f', '<cmd>lua require("hop").hint_char1()<CR>')
map('n', '<leader>w', '<cmd>lua require("hop").hint_words()<CR>')
-- Indent Blankline
require'indent_blankline'.setup {
	char='│',
	buftype_exclude = { 'terminal', },
	filetype_exclude = { 'man', 'help', 'tutor' },
	show_first_indent_level = true,
}

---- LSP Plugins ----
-- VIM_USE_LSP needs to have a value, not just existing.
if vim.env.VIM_USE_LSP then
	require 'lsp'
end

