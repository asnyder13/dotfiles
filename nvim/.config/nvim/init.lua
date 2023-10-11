require 'util'
local map = Util.map

local fn  = vim.fn
local g   = vim.g
local api = vim.api
local opt = vim.opt

vim.cmd 'packadd paq-nvim'
vim.cmd 'packadd matchit'

local nonLspPackages = {
	{ 'savq/paq-nvim', opt = true },

	-- Colorscheme, Neovim specific
	'judaew/ronny.nvim',

	-- Regular vim
	'ntpeters/vim-better-whitespace',
	'tpope/vim-fugitive',
	'vim-scripts/ReplaceWithRegister',
	'vim-ruby/vim-ruby',
	'kshenoy/vim-signature',
	'tpope/vim-sleuth',
	'justinmk/vim-sneak',
	'AndrewRadev/splitjoin.vim',
	'jlcrochet/vim-razor',
	'tpope/vim-abolish',

	-- Neovim specific
	'nvim-tree/nvim-web-devicons',
	'NvChad/nvim-colorizer.lua',
	'smoka7/hop.nvim',
	'lukas-reineke/indent-blankline.nvim',
	'nvim-lua/plenary.nvim',
	'nvim-lua/popup.nvim',
	'nvim-telescope/telescope.nvim',
	'lewis6991/gitsigns.nvim',
	'romgrk/barbar.nvim',
	'RRethy/nvim-align',
	'Everduin94/nvim-quick-switcher',
	'kylechui/nvim-surround',
	'RRethy/vim-illuminate',
	'numToStr/Comment.nvim',
	'JoosepAlviste/nvim-ts-context-commentstring',
	'm-demare/hlargs.nvim',
	'nvim-tree/nvim-tree.lua',
	'nvim-neo-tree/neo-tree.nvim',
	'MunifTanjim/nui.nvim',
	's1n7ax/nvim-window-picker',
	'bluz71/nvim-linefly',
}

local lspPackages = {
	-- Treesitter
	{ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' },
	'nvim-treesitter/playground',

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
	'hrsh7th/cmp-nvim-lsp-signature-help',

	{ 'L3MON4D3/LuaSnip', run = 'make install_jsregexp' },
	'rafamadriz/friendly-snippets',
	'honza/vim-snippets',

	'mfussenegger/nvim-dap',
	'jay-babu/mason-nvim-dap.nvim',
	'theHamsta/nvim-dap-virtual-text',
	'suketa/nvim-dap-ruby',

	'HiPhish/rainbow-delimiters.nvim',
}

local paq = require 'paq'
local packages = nonLspPackages
if vim.env.VIM_USE_LSP then
	packages = Util.concatTables(packages, lspPackages)
end
paq(packages)

---- General Settings ----

-- Auto commands
vim.cmd([[
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
vim.cmd 'au FileType cs setlocal shiftwidth=4 softtabstop=4 expandtab'

opt.mouse      = 'c'
opt.autoindent = true
opt.showmatch  = true
opt.visualbell = true
opt.showmode   = true
opt.wildmode   = { 'list:longest' }
opt.scrolloff  = 1
opt.wildignore:append { '*/node_modules/*', '*/.git/*', '*/tmp/*', '*.swp' }
opt.splitright     = true
opt.splitbelow     = true

opt.confirm        = true
opt.backup         = false
opt.hidden         = true
opt.history        = 1000
opt.termguicolors  = true

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
-- autocmd to overwrite other highlight groups.  Setup before :colorscheme
api.nvim_create_autocmd('ColorScheme', {
	pattern = '*',
	command = [[
			highlight Normal guibg=#282923
			highlight LineNr guibg=#282923
			highlight CursorLineNr guibg=#434343
			highlight IblScope guifg=#b2b2b2
			highlight TabLineFill guibg=#282923
		]]
})

local colors = require "ronny.colors"
-- for _, v in pairs(colors.syntax) do v.italic = false end
require 'ronny'.setup {
	colors = colors,
	display = { monokai_original = true },
}
vim.cmd 'colorscheme ronny'

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
vim.cmd [[
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
	command! TrimLineEnds %s/\v\s+$//
]]
map('n', '<leader><C-i>', ':Inspect<CR>')
map('n', '<C-w><C-w>', '<C-w><C-p>')

---- Plugin Settings ----
-- Vim plugins
vim.cmd [[
	let g:sneak#use_ic_scs = 1
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

-- Telescope
require 'telescope'.setup {
	defaults = {
		file_ignore_patterns = { 'node_modules', '.git', },
		layout_strategy = 'vertical',
	},
}
map('n', '<C-p>', '<cmd>lua require("telescope.builtin").find_files({ hidden = false })<CR>')
map('n', '<C-M-p>', '<cmd>lua require("telescope.builtin").find_files({ hidden = true })<CR>')
map('n', '<C-g>', '<cmd>lua require("telescope.builtin").git_files()<CR>')
map('n', '<leader>b', '<cmd>lua require("telescope.builtin").buffers()<CR>')
map('n', '<M-;>', '<cmd>lua require("telescope.builtin").treesitter()<CR>')
map('n', '<M-g>', '<cmd>lua require("telescope.builtin").live_grep()<CR>')

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
map('n', '<leader>i', ':IBLToggle<CR>:set number!<CR>')
map('n', '<leader>I', ':IBLToggle<CR>:set number!<CR>')

-- ng quick switcher
local qs_opts = {
	silent = true,
	buffer = true,
}
local function qs(file, opts)
	return function() require('nvim-quick-switcher').switch(file, opts) end
end
local function angularSwitcherMappings()
	map('n', '<leader>u', qs('component.ts', nil), qs_opts)
	map('n', '<leader>o', qs('component.html', nil), qs_opts)
	map('n', '<leader>i', qs('component.scss', nil), qs_opts)
	map('n', '<leader>p', qs('module.ts', nil), qs_opts)
	map('n', '<leader>t', qs('component.spec.ts', nil), qs_opts)
	map('n', '<leader>xu', qs('component.ts', { split = 'horizontal' }), qs_opts)
	map('n', '<leader>xi', qs('component.scss', { split = 'horizontal' }), qs_opts)
	map('n', '<leader>xo', qs('component.html', { split = 'horizontal' }), qs_opts)
end
local angularAuGroup = api.nvim_create_augroup('AngularQuickSwitcher', { clear = true })
api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', }, {
	group = angularAuGroup,
	pattern = { '*.ts', '*.html', '*.scss', '*.sass', },
	callback = angularSwitcherMappings,
})

require 'Comment'.setup {
	pre_hook = require 'ts_context_commentstring.integrations.comment_nvim'.create_pre_hook(),
}

require 'nvim-surround'.setup { move_cursor = false }
require 'gitsigns'.setup {}

-- Neo tree
require 'window-picker'.setup {
	filter_rules = {
		include_current_win = true,
		autoselect_one = true,
		-- filter using buffer options
		bo = {
			-- if the file type is one of following, the window will be ignored
			filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
			-- if the buffer type is one of following, the window will be ignored
			buftype = { 'terminal', 'quickfix' },
		},
	}
}
local openWindowPicker = function()
	local picked_window_id = require 'window-picker'.pick_window()
	if picked_window_id ~= nil then
		vim.fn.win_gotoid(picked_window_id)
	end
end
map('n', '<M-w>', openWindowPicker)
map('n', '<C-q>', openWindowPicker)

require 'neo-tree'.setup {
	filesystem = {
		hijack_netrw_behavior = "open_default",
		follow_current_file = {
			enabled = true,
			leave_dirs_open = true,
		}
	},
	add_blank_line_at_top = true,
	window = {
		mappings = {
			["s"] = "open_split",
			["S"] = "open_vsplit",
			["x"] = "split_with_window_picker",
			["v"] = "vsplit_with_window_picker",
			["<C-x>"] = "cut_to_clipboard",
			["<C-c>"] = "clear_filter",
		}
	},
	event_handlers = { {
		event = "neo_tree_buffer_enter",
		handler = function()
			vim.cmd [[
				setlocal number
				setlocal relativenumber
			]]
		end,
	} },
}
map('n', '-', ':Neotree<CR>')

---- Highlight changes
-- The ronny colorscheme gets colors right and has robust coverage, but with TS and LSP tokens
--   it ends up coloring literally everything and floods the brain.
local highlightReLinks = {
	-- C#
	'@punctuation.bracket.c_sharp',
	'@variable.c_sharp',
	'@type.c_sharp',
	['@lsp.type.interface.cs'] = 'DevIconLiquid',
	'@lsp.type.namespace.cs',
	'@lsp.type.property.cs',
	'@lsp.type.variable.cs',
	-- Lua
	'@field.lua',
	'@variable.lua',
	'@lsp.type.property.lua',
	'@lsp.type.variable.lua',
	-- Ruby
	'@variable.ruby',
	'@lsp.type.variable.ruby',
	-- TS
	'@property.typescript',
	'@variable.typescript',
	'@lsp.type.property.typescript',
	'@lsp.type.variable.typescript',
}
for k, v in pairs(highlightReLinks) do
	-- Lua table literals auto-key w/ incrementing index when given plain values
	if type(k) == 'number' then
		api.nvim_set_hl(0, v, { link = 'Text' })
	else
		api.nvim_set_hl(0, k, { link = v })
	end
end

local illuminateColor = { bg = '#434343' }
local highlights = { 'IlluminatedWord', 'IlluminatedCurWord', 'IlluminatedWordText', 'IlluminatedWordRead',
	'IlluminatedWordWrite' }
for _, group in ipairs(highlights) do vim.api.nvim_set_hl(0, group, illuminateColor) end
require 'illuminate'.configure {
	filetypes_denylist = {
		'dirbuf',
		'dirvish',
		'fugitive',
		'NvimTree',
		'man',
	},
}

-- require 'hlargs'.setup { color = '#57ebc8', }

---- LSP Plugins ----
-- VIM_USE_LSP needs to have a value, not just existing.
if vim.env.VIM_USE_LSP then
	require 'lsp'
end