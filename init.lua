require 'util'
local map = Util.map

local cmd = vim.cmd
local fn  = vim.fn
local g   = vim.g
local api = vim.api
local opt = vim.opt

cmd 'packadd paq-nvim'
local paq = require 'paq'.paq
paq { 'savq/paq-nvim', opt = true }

-- Colorscheme, Neovim specific
paq 'judaew/ronny.nvim'

-- Regular vim
paq 'ntpeters/vim-better-whitespace'
paq 'tpope/vim-commentary'
paq 'justinmk/vim-dirvish'
paq 'tpope/vim-fugitive'
paq 'vim-scripts/ReplaceWithRegister'
paq 'vim-ruby/vim-ruby'
paq 'kshenoy/vim-signature'
paq 'tpope/vim-sleuth'
paq 'justinmk/vim-sneak'
paq 'AndrewRadev/splitjoin.vim'
paq 'danchoi/ri.vim'
paq 'jlcrochet/vim-razor'
paq 'tpope/vim-abolish'

-- Neovim specific
paq 'norcalli/nvim-colorizer.lua'
paq 'phaazon/hop.nvim'
paq 'lukas-reineke/indent-blankline.nvim'
paq 'nvim-lua/plenary.nvim'
paq 'nvim-lua/popup.nvim'
paq 'nvim-telescope/telescope.nvim'
paq 'lewis6991/gitsigns.nvim'
paq 'nvim-tree/nvim-web-devicons'
paq 'romgrk/barbar.nvim'
paq 'RRethy/nvim-align'
paq 'Everduin94/nvim-quick-switcher'
paq 'kylechui/nvim-surround'
paq 'nvim-lualine/lualine.nvim'
paq 'RRethy/vim-illuminate'

if vim.env.VIM_USE_LSP then
	paq { 'nvim-treesitter/nvim-treesitter', run = function() cmd ':TSUpdate' end }
	paq 'neovim/nvim-lspconfig'
	paq 'mfussenegger/nvim-dap'
	paq 'williamboman/mason.nvim'
	paq 'williamboman/mason-lspconfig.nvim'
	paq 'jay-babu/mason-nvim-dap.nvim'
	paq 'theHamsta/nvim-dap-virtual-text'
	paq 'nvim-treesitter/playground'
	paq 'mhartington/formatter.nvim'

	paq 'suketa/nvim-dap-ruby'

	paq 'hrsh7th/nvim-cmp'
	paq 'hrsh7th/cmp-nvim-lsp'
	paq 'hrsh7th/cmp-buffer'
	paq 'hrsh7th/cmp-path'
	paq 'hrsh7th/cmp-nvim-lsp-signature-help'
end
---- General Settings ----

-- Auto commands
cmd([[
	" Sytaxes
	autocmd BufNewFile,BufRead *.npmrc   set ft=dosini
	autocmd BufNewFile,BufRead *bash-fc* set ft=sh

	" https://github.com/jeffkreeftmeijer/vim-numbertoggle
	augroup NumberToggle
		autocmd!
		autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
		autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
		autocmd OptionSet                                 * if !&nu                 | set nornu | endif
		autocmd OptionSet                                 * if &nu                  | set rnu   | endif
	augroup END

	" https://stackoverflow.com/questions/63906439/how-to-disable-line-numbers-in-neovim-terminal
	augroup neovim_terminal
		autocmd!
		" Enter Terminal-mode (insert) automatically
		autocmd TermOpen * startinsert
		" Disables number lines on terminal buffers
		autocmd TermOpen * :set nonumber norelativenumber
		" allows you to use Ctrl-c on terminal window
		autocmd TermOpen * nnoremap <buffer> <C-c> i<C-c>
	augroup END

	augroup ASCEND
		autocmd!
		au BufRead,BufNewFile *.a4c,*.a4l set syntax=ascend
	augroup END
]])

-- Search for visual selection
-- https://vim.fandom.com/wiki/Search_for_visually_selected_text
cmd([[
	" Search for selected text, forwards or backwards.
	vnoremap <silent> * :<C-U>
		\let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
		\gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
		\escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
		\gVzv:call setreg('"', old_reg, old_regtype)<CR>
	vnoremap <silent> # :<C-U>
		\let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
		\gvy?<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
		\escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
		\gVzv:call setreg('"', old_reg, old_regtype)<CR>
]])

-- General
api.nvim_create_autocmd('TextYankPost', {
	pattern = '*',
	callback = function() vim.highlight.on_yank { timeout = 350 } end,
})
-- Don't auto-comment on a new line
api.nvim_create_autocmd('FileType', {
	pattern = '*',
	callback = function() opt.formatoptions:remove { 'r', 'o' } end,
})

opt.clipboard     = 'unnamedplus'
opt.number        = true
opt.cursorline    = true

local indent_size = 2
opt.tabstop       = indent_size
opt.shiftwidth    = indent_size
opt.expandtab     = false
cmd 'au FileType cs setlocal shiftwidth=4 softtabstop=4 expandtab'

opt.mouse      = nil
opt.autoindent = true
opt.showmatch  = true
opt.visualbell = true
opt.showmode   = true
opt.wildmode   = { 'list:longest' }
opt.scrolloff  = 0
opt.wildignore:append { '*/node_modules/*', '*/.git/*', '*/tmp/*', '*.swp' }
opt.splitright = true
opt.splitbelow = true

opt.confirm       = true
opt.backup        = false
opt.hidden        = true
opt.history       = 1000
opt.termguicolors = true

-- Searching
opt.hlsearch   = true
opt.ignorecase = true
opt.smartcase  = true

opt.foldmethod = 'indent'
opt.foldlevelstart = 99

-- Syntax hl/colors
opt.syntax = 'on'
-- autocmd to overwrite other highlight groups.  Setup before :colorscheme
api.nvim_create_autocmd('ColorScheme', {
	pattern = '*',
	callback = function()
		cmd [[
			highlight Normal guibg=#282923
			highlight LineNr guibg=#282923
			highlight CursorLineNr guibg=#434343
		]]
	end,
})

local colors = require "ronny.colors"
for _, v in pairs(colors.syntax) do v.italic = false end
require 'ronny'.setup {
	colors = colors,
	display = { monokai_original = true },
}
cmd 'colorscheme ronny'

Util.create_text_object('|')

-- Persistent Undo/Redo
if fn.has('persistent_undo') == 1 then
	local target_path = Util.create_expand_path('~/.local/share/nvim/nvim-persisted-undo/')
	opt.undodir = target_path
	opt.undofile = true
end

---- General Mappings ----
-- Reload this config
map('n', '<leader>sv', ':source $MYVIMRC<CR>')
-- Collapse all levels under current fold
map('n', 'zs', 'zCzozo')
-- Quick buffer switch (for tabline)
map('n', 'gbn', ':bn<CR>')
map('n', 'gbN', ':bN<CR>')
map('n', 'gbd', ':bd<CR>')
map('n', '<BS>', '<C-^>')
cmd [[
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
	command! TrimLineEnds %s/\v\s+$//
]]
map('n', '<A-b>', ':BufferPick<CR>')

---- Plugin Settings ----
-- Vim plugins
-- netrw
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_browse_split = 4
g.netrw_altv = 1
g.netrw_winsize = 25
-- Sneak
cmd [[
	let g:sneak#use_ic_scs = 1
	let g:sneak#map_netrw = 1
]]
-- Highlighted yank
g.highlightedyank_highlight_duration = 500
-- Polyglot
g.ruby_recommended_style = 0
-- Signature
g.SignatureMarkTextHLDynamic = 1
-- Dirvish
g.loaded_netrwPlugin = 1

-- Neovim plugins
require 'colorizer'.setup()
require 'lualine'.setup{}

-- Telescope
require 'telescope'.setup { defaults = { file_ignore_patterns = { 'node_modules', '.git', } } }
map('', '<C-p>', '<cmd>lua require("telescope.builtin").find_files({ hidden = false })<cr>')
map('', '<C-M-p>', '<cmd>lua require("telescope.builtin").find_files({ hidden = true })<cr>')
map('', '<C-g>', '<cmd>lua require("telescope.builtin").git_files()<cr>')
map('', '<leader>b', '<cmd>lua require("telescope.builtin").buffers()<cr>')
map('', '<C-;>', '<cmd>lua require("telescope.builtin").treesitter()<cr>')
-- Hop
require 'hop'.setup { keys = ',;abcdefgimnorstuvwxz' }
map('n', '<leader>f', '<Esc> <cmd>lua require("hop").hint_char1()<CR>')
map('n', '<leader>w', '<Esc> <cmd>lua require("hop").hint_words()<CR>')
-- Indent Blankline
require 'indent_blankline'.setup {
	char                       = '│',
	buftype_exclude            = { 'terminal', },
	filetype_exclude           = { 'man', 'help', 'tutor', 'gitcommit' },
	show_first_indent_level    = true,
	show_current_context       = true,
	show_current_context_start = true,
}
map('n', '<leader>i', '<cmd>IndentBlanklineToggle<CR><cmd>set number!<CR>')
map('n', '<leader>I', '<cmd>IndentBlanklineToggle<CR><cmd>set number!<CR>')

-- ng quick switcher
local qs_opts = {
	silent = true,
	buffer = true,
}
local function qs(file, opts)
	return function() require('nvim-quick-switcher').switch(file, opts) end
end

local function angularSwitcherMappings()
	vim.keymap.set('n', '<leader>u', qs('component.ts', nil), qs_opts)
	vim.keymap.set('n', '<leader>o', qs('component.html', nil), qs_opts)
	vim.keymap.set('n', '<leader>i', qs('component.scss', nil), qs_opts)
	vim.keymap.set('n', '<leader>p', qs('module.ts', nil), qs_opts)
	vim.keymap.set('n', '<leader>t', qs('component.spec.ts', nil), qs_opts)
	vim.keymap.set('n', '<leader>xu', qs('component.ts', { split = 'horizontal' }), qs_opts)
	vim.keymap.set('n', '<leader>xi', qs('component.scss', { split = 'horizontal' }), qs_opts)
	vim.keymap.set('n', '<leader>xo', qs('component.html', { split = 'horizontal' }), qs_opts)
end

local angularAuGroup = api.nvim_create_augroup('AngularQuickSwitcher', { clear = true })
api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', }, {
	group = angularAuGroup,
	pattern = { '*.ts', '*.html', '*.scss', '*.sass', },
	callback = angularSwitcherMappings,
})

require 'nvim-surround'.setup{}
require 'gitsigns'.setup{}

local illuminateColor = { bg = '#434343' }
local highlights = { 'IlluminatedWord', 'IlluminatedCurWord', 'IlluminatedWordText', 'IlluminatedWordRead', 'IlluminatedWordWrite' }
for _, group in ipairs(highlights) do vim.api.nvim_set_hl(0, group, illuminateColor) end

---- LSP Plugins ----
-- VIM_USE_LSP needs to have a value, not just existing.
if vim.env.VIM_USE_LSP then
	require 'lsp'
end
