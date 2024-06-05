local Util = require 'util'
local map  = Util.map_keys_table

local g    = vim.g
local api  = vim.api
local opt  = vim.opt


local nonLspPackages = {
	{
		'savq/paq-nvim',
		opt = true
	},

	-- Colorscheme, Neovim specific
	'judaew/ronny.nvim',

	-- Regular vim
	'ntpeters/vim-better-whitespace',
	'tpope/vim-fugitive',
	'vim-scripts/ReplaceWithRegister',
	'kshenoy/vim-signature',
	'tpope/vim-sleuth',
	'justinmk/vim-sneak',
	'AndrewRadev/splitjoin.vim',
	'jlcrochet/vim-razor',
	'tpope/vim-abolish',
	'mattn/emmet-vim',

	-- Neovim specific
	'nvim-tree/nvim-web-devicons',
	'NvChad/nvim-colorizer.lua',
	'smoka7/hop.nvim',
	'lukas-reineke/indent-blankline.nvim',
	'nvim-lua/plenary.nvim',
	'nvim-lua/popup.nvim',
	'nvim-telescope/telescope.nvim',
	{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	'lewis6991/gitsigns.nvim',
	'romgrk/barbar.nvim',
	'RRethy/nvim-align',
	'Everduin94/nvim-quick-switcher',
	'kylechui/nvim-surround',
	'RRethy/vim-illuminate',
	'numToStr/Comment.nvim',
	'm-demare/hlargs.nvim',
	'nvim-neo-tree/neo-tree.nvim',
	'MunifTanjim/nui.nvim',
	's1n7ax/nvim-window-picker',
	'bluz71/nvim-linefly',
	'windwp/nvim-autopairs',
	'LunarVim/bigfile.nvim',
	'rasulomaroff/reactive.nvim',
	'j-hui/fidget.nvim',
	'RRethy/nvim-treesitter-endwise',
}

local lspPackages = {
	-- Treesitter
	{ 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate' },
	'atusy/treemonkey.nvim',

	-- LSP
	'neovim/nvim-lspconfig',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'mhartington/formatter.nvim',

	-- cpm for LSP
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'ray-x/lsp_signature.nvim',
	'RaafatTurki/corn.nvim',

	{ 'L3MON4D3/LuaSnip',                build = 'make install_jsregexp' },
	'rafamadriz/friendly-snippets',
	'honza/vim-snippets',

	'mfussenegger/nvim-dap',
	'jay-babu/mason-nvim-dap.nvim',
	'theHamsta/nvim-dap-virtual-text',
	'suketa/nvim-dap-ruby',

	'HiPhish/rainbow-delimiters.nvim',
	'folke/trouble.nvim',
	'JoosepAlviste/nvim-ts-context-commentstring',
}


local my_packages = nonLspPackages
if vim.env.VIM_USE_LSP then
	vim.list_extend(my_packages, lspPackages)
end

-- :h paq-bootstrapping
local function clone_paq()
	local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
	local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0
	if not is_installed then
		vim.fn.system { 'git', 'clone', '--depth=1', 'https://github.com/savq/paq-nvim.git', path }
		return true
	end
end

local function bootstrap_paq(packages)
	local first_install = clone_paq()
	vim.cmd.packadd 'paq-nvim'
	local paq = require('paq')
	if first_install then
		vim.notify('Installing plugins... If prompted, hit Enter to continue.')
	end

	-- Read and install packages
	paq(packages)
end

-- Call helper function
bootstrap_paq(my_packages)

vim.cmd.packadd 'matchit'
require 'gitsigns'.setup {}

---- General Settings ----

-- Auto commands
vim.cmd([[
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
]])

vim.filetype.add {
	extension = {
		conf = 'confini',
	},
	filename = {
		syslog = 'messages',
	},
	pattern = {
		['appsettings[%.%a]*%.json'] = function(path)
			local dir = path:match('(.+)/.+')
			local csprojs = vim.fn.glob(dir .. '/*.csproj', false, true)
			local is_dotnet = #csprojs ~= 0
			if is_dotnet then
				return 'jsonc'
			else
				return 'json'
			end
		end,
		['%.zsh_history.*'] = 'zsh',
	}
}
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
	pattern = '*syslog*',
	command = 'set ft=messages'
})

-- Search for visual selection
-- https://vim.fandom.com/wiki/Search_for_visually_selected_text
vim.cmd([[
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

---- General
api.nvim_create_autocmd('TextYankPost', { callback = function() vim.highlight.on_yank { timeout = 350 } end, })
-- Don't auto-comment on a new line
api.nvim_create_autocmd('FileType', { callback = function() opt.formatoptions:remove { 'r', 'o' } end, })

opt.clipboard     = 'unnamedplus'
opt.number        = true
opt.cursorline    = true

local indent_size = 2
opt.tabstop       = indent_size
opt.shiftwidth    = indent_size
opt.expandtab     = false
vim.cmd 'au FileType cs setlocal shiftwidth=4 softtabstop=4 expandtab'

opt.mouse      = 'cnv'
opt.autoindent = true
opt.showmatch  = true
opt.visualbell = true
opt.showmode   = true
opt.wildmode   = { 'list:longest' }
opt.scrolloff  = 1
opt.wildignore:append { '*/node_modules/*', '*/.git/*', '*/tmp/*', '*.swp', '*/.angular/*' }
opt.sidescrolloff  = 5
opt.splitright     = true
opt.splitbelow     = true

opt.confirm        = true
opt.backup         = false
opt.hidden         = true
opt.history        = 1000
opt.termguicolors  = true
opt.signcolumn     = 'auto:2'
opt.updatetime     = 250

-- Searching
opt.hlsearch       = true
opt.ignorecase     = true
opt.smartcase      = true

opt.foldmethod     = 'indent'
opt.foldlevelstart = 99


g.loaded_python3_provider = false
g.loaded_ruby_provider    = false
g.loaded_node_provider    = false
g.loaded_perl_provider    = false

-- Syntax hl/colors
opt.syntax                = 'on'

---- Configs from dedicated files.
-- Colorscheme and highlight overwrites.
require 'highlighting-local'
require 'telescope-local'
require 'switcher'
require 'neo-tree-local'

Util.create_text_object('|')

-- Persistent Undo/Redo
if vim.fn.has('persistent_undo') == 1 then
	local target_path = Util.create_expand_path('~/.local/share/nvim/nvim-persisted-undo/')
	opt.undodir = target_path
	opt.undofile = true
end

---- General Mappings ----
map('n', 'ZZ', '')
-- Reload this config
map('n', '<leader>sv', ':source $MYVIMRC<CR>', { silent = true })
-- Collapse all levels under current fold
map('n', 'zs', 'zCzozo')
map('n', '<leader>zc', ':%foldc<CR>')
-- Quick buffer switch (for tabline)
map('n', 'gbn', ':bn<CR>')
map('n', 'gbN', ':bN<CR>')
map('n', 'gbd', ':bd<CR>')
map('n', '<BS>', '<C-^>')
vim.cmd [[
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
	command! TrimLineEnds %s/\v\s+$// | normal `'
]]
map('n', '<leader><C-i>', ':Inspect<CR>')
map('n', '<C-w><C-w>', '<C-w><C-p>')

vim.api.nvim_create_user_command('Hitest',
	'execute "ReactiveStop" | so $VIMRUNTIME/syntax/hitest.vim',
	{ desc = 'Open up the pretty hilight display, disable Reactive to prevent slowdown.' }
)

---- Plugin Settings ----
-- Vim plugins
g['sneak#use_ic_scs'] = 1
-- Highlighted yank
g.highlightedyank_highlight_duration = 500
-- Polyglot
g.ruby_recommended_style = 0
-- Signature
g.SignatureMarkTextHLDynamic = 1
-- Dirvish
g.loaded_netrwPlugin = 1

-- Neovim plugins
require 'colorizer'.setup {}
-- require 'lualine'.setup {}

require 'barbar'.setup {
	exclude_ft = { 'neo-tree' },
	focus_on_close = 'previous',
	icons = {
		buffer_number = true,
	}
}
map('n', '<M-b>', ':BufferPick<CR>')

-- Hop
require 'hop'.setup { keys = 'hklyuiopnm,qwertzxcvbasdgjf;' }
map('n', '<leader>f', '<Esc> :lua require("hop").hint_char1()<CR>')
map('n', '<leader>w', '<Esc> :lua require("hop").hint_words()<CR>')

-- Indent Blankline
require 'ibl'.setup {
	scope = {
		include = {
			-- node_type = { ["*"] = { "*" } },
		},
	},
	whitespace = {
		remove_blankline_trail = false,
	},
}
Util.map_keys_table('n', { '<leader>i', '<leader>I' }, ':IBLToggle<CR>:set number!<CR>')

require 'Comment'.setup {
	pre_hook = require 'ts_context_commentstring.integrations.comment_nvim'.create_pre_hook(),
}

require 'nvim-surround'.setup { move_cursor = false }

require 'nvim-autopairs'.setup {}

require 'bigfile'.setup {
	filesize = 1,
}

require 'reactive'.setup { builtin = {
	cursorline = true,
	cursor = true,
	modemsg = true
} }

require 'fidget'.setup {}

-- https://old.reddit.com/r/neovim/comments/1abd2cq/what_are_your_favorite_tricks_using_neovim/
-- Jump to last edit position on opening file
vim.cmd [[
	au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]]

vim.g.lasttab = 1
vim.api.nvim_create_autocmd('TabLeave', { callback = function() vim.g.lasttab = vim.api.nvim_get_current_tabpage() end })
map('n', '<C-BS>', function() vim.api.nvim_set_current_tabpage(vim.g.lasttab) end)

---- LSP Plugins ----
-- VIM_USE_LSP needs to have a value, not just existing.
if vim.env.VIM_USE_LSP then
	require 'lsp'
end

-- Gets overwritten if something in lsp.lua is run after it.
local gitsigns = require 'gitsigns'
gitsigns.setup {}
map('n', ']c', function() gitsigns.next_hunk() end)
map('n', '[c', function() gitsigns.prev_hunk() end)
