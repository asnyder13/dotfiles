local Util = require 'util'
local map  = Util.map_keys_table


local g   = vim.g
local api = vim.api
local opt = vim.opt


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
	'Everduin94/nvim-quick-switcher',
	'kylechui/nvim-surround',
	'RRethy/vim-illuminate',
	'nvim-neo-tree/neo-tree.nvim',
	'MunifTanjim/nui.nvim',
	's1n7ax/nvim-window-picker',
	'bluz71/nvim-linefly',
	'windwp/nvim-autopairs',
	'LunarVim/bigfile.nvim',
	'rasulomaroff/reactive.nvim',
	'folke/which-key.nvim',
	'BranimirE/fix-auto-scroll.nvim',
	'chentoast/marks.nvim',
	'sindrets/diffview.nvim',
	'mei28/qfc.nvim',
	'chrisgrieser/nvim-spider',
	'mcauley-penney/visual-whitespace.nvim',
	'emmanueltouzery/decisive.nvim',
	'ggandor/leap.nvim',
	'kwkarlwang/bufresize.nvim',

	-- mini.nvim
	'echasnovski/mini.ai',
	'echasnovski/mini.align',
	'echasnovski/mini.move',
}

local lspPackages = {
	-- Treesitter
	{ 'nvim-treesitter/nvim-treesitter',                     build = ':TSUpdate' },
	'nvim-treesitter/nvim-treesitter-refactor',
	'atusy/treemonkey.nvim',
	'windwp/nvim-ts-autotag',
	'RRethy/nvim-treesitter-endwise',
	'aaronik/treewalker.nvim',
	'Wansmer/treesj',
	'Goose97/timber.nvim',

	-- LSP
	'neovim/nvim-lspconfig',
	'mason-org/mason.nvim',
	'mason-org/mason-lspconfig.nvim',
	'mhartington/formatter.nvim',
	'j-hui/fidget.nvim',
	'Hoffs/omnisharp-extended-lsp.nvim',
	'dmmulroy/ts-error-translator.nvim',

	-- cmp for LSP
	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-nvim-lua',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-cmdline',
	{ url = 'https://codeberg.org/FelipeLema/cmp-async-path' },
	'ray-x/cmp-treesitter',

	-- Snippets
	{ 'L3MON4D3/LuaSnip', build = 'make install_jsregexp' },
	'rafamadriz/friendly-snippets',
	'honza/vim-snippets',
	'saadparwaiz1/cmp_luasnip',
	'benfowler/telescope-luasnip.nvim',

	-- DAP
	'mfussenegger/nvim-dap',
	'jay-babu/mason-nvim-dap.nvim',
	'theHamsta/nvim-dap-virtual-text',
	'suketa/nvim-dap-ruby',

	-- misc
	'HiPhish/rainbow-delimiters.nvim',
	-- 'ray-x/lsp_signature.nvim',
	'b0o/schemastore.nvim',
	{ 'ray-x/guihua.lua', build = 'make -C lua/fzy' },
	'ray-x/navigator.lua',
}


local my_packages = nonLspPackages
vim.list_extend(my_packages, lspPackages)

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
	local paq = require 'paq'
	if first_install then
		vim.notify('Installing plugins... If prompted, hit Enter to continue.')
	end

	-- Read and install packages
	paq(packages)
end

-- Call helper function
bootstrap_paq(my_packages)

vim.cmd.packadd 'matchit'

---- General Settings ----
-- Auto commands
vim.cmd([[
	" https://github.com/jeffkreeftmeijer/vim-numbertoggle
	augroup NumberToggle
		autocmd!
		autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
		autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
		" Keep 'relativenumber' synced, but only when 'number' is changed.
		autocmd OptionSet                                 * if !&nu && expand('<amatch>') == 'number' | set nornu | endif
		autocmd OptionSet                                 * if &nu  && expand('<amatch>') == 'number' | set rnu   | endif
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
			return is_dotnet and 'jsonc' or 'json'
		end,
		['%.zsh_history.*'] = 'zsh',
	}
}
-- vim.filetype.add seems to just be broken for detecting certain file types.
Util.ftset('*syslog*', 'messages')
Util.ftset('*.zsh_history*', 'zsh')

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


local mouse    = 'cnv'
opt.mouse      = mouse
opt.autoindent = true
opt.showmatch  = true
opt.visualbell = true
opt.showmode   = true
opt.wildmode   = { 'list:longest', }
opt.scrolloff  = 1
opt.wildignore:append { '*/node_modules/*', '*/.git/*', '*/tmp/*', '*.swp', '*/.angular/*', }
opt.sidescrolloff = 5
opt.splitright    = true
opt.splitbelow    = true
opt.listchars     = { tab = '»-', extends = '›', precedes = '‹', nbsp = '·', trail = '·', }
opt.winblend      = 5
opt.pumblend      = 5
opt.diffopt:append { 'iwhiteall', }
opt.linebreak      = true

opt.confirm        = true
opt.backup         = false
opt.hidden         = true
opt.history        = 1000
opt.termguicolors  = true
opt.signcolumn     = 'auto:1-3'
opt.updatetime     = 250
opt.winborder      = 'rounded'

-- Searching
opt.hlsearch       = true
opt.ignorecase     = true
opt.smartcase      = true

opt.foldmethod     = 'indent'
opt.foldlevelstart = 10
map('n', 'zM', function() opt.foldlevel = 2 end)


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
require 'movement'

local lsp_success, lsp_error = pcall(function()
	require 'lsp'
	require 'format'
end)
if not lsp_success then
	vim.print('Error setting up LSPs')
	vim.print(lsp_error)
end

g.user_emmet_install_global = 0
g.user_emmet_leader_key = '<C-t>'
api.nvim_create_autocmd('FileType', { pattern = { 'html', 'css' }, command = 'EmmetInstall' })

-- Persistent Undo/Redo
if vim.fn.has('persistent_undo') == 1 then
	local target_path = Util.create_expand_path('~/.local/share/nvim/nvim-persisted-undo/')
	opt.undodir = target_path
	opt.undofile = true
end

---- General Mappings ----
-- Unmap defaults
pcall(function()
	vim.keymap.del('n', 'grn')
	vim.keymap.del('n', 'grr')
	vim.keymap.del('n', 'gri')
	vim.keymap.del('n', 'gO')
	vim.keymap.del({ 'n', 'x', }, 'gra')
	vim.keymap.del('n', 'grt')
	vim.keymap.del('n', 'gr')
end)

map('n', 'ZZ', '<NOP>')
map('n', { '<C-t><C-c>', '<C-t>c' }, ':tabclose<CR>', { desc = 'Close tab' })
-- Reload this config
map('n', '<leader>sv', ':source $MYVIMRC<CR>', { desc = 'Source vimrc/init' })

map('n', '<leader>zc', ':%foldc!<CR>',     { desc = 'Close all folds' })
map('x', '<leader>zc', ":'<,'>foldc!<CR>", { desc = 'Close all folds' })
map('n', '<leader>zC', ':%foldo<CR>',      { desc = 'Open all folds' })
map('n', 'gbd',  ':b#|bd#<CR>', { desc = 'Buffer delete, keep window' })
vim.api.nvim_create_user_command('BufCloseOthers',
	'%bd|e#|bd#',
	{ desc = 'Close all other buffers' }
)
map('n', '<BS>', '<C-^>', { desc = 'Last buffer' })
map('n', '<leader><C-i>', ':Inspect<CR>', { desc = ':Inspect' })
map('n', '<C-w><C-w>', '<C-w><C-p>', { desc = 'Last window' })
map('n', '<C-w>,', function() vim.cmd('resize ' .. vim.fn.line('$')) end, { desc = 'Size window to content' })

-- Toggle mappings
map('n', '<leader>tw', ':set wrap!<CR>', { desc = 'Toggle wrap' })
map('n', '<leader>tm', function()
	if vim.tbl_isempty(vim.opt_local.mouse:get()) then
		vim.opt_local.mouse = mouse
	else
		vim.opt_local.mouse = ''
	end
end, { desc = 'Toggle mouse' })
map('n', '<leader>tn',
	':IBLToggle<CR>:set number!<CR>:MarksToggleSigns<CR>:Gitsigns toggle_signs<CR>:lua vim.diagnostic.enable(not vim.diagnostic.is_enabled())<CR>',
	{ desc = 'Toggle line numbers' })

vim.api.nvim_create_user_command('Hitest',
	'execute "ReactiveStop" | so $VIMRUNTIME/syntax/hitest.vim',
	{ desc = 'Open up the pretty hilight display, disable Reactive to prevent slowdown.' }
)

-- Stolen from primeagen
-- Keep cursor in same position after line join
map('n', 'J', function() return 'mz' .. vim.v.count1 .. 'J`zdmz' end, { expr = true })
-- Center window at cursor on search
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- https://old.reddit.com/r/neovim/comments/1k4efz8/share_your_proudest_config_oneliners/
map('n', 'ycc', function()
	return 'yy' .. vim.v.count1 .. "gcc']p"
end, { remap = true, expr = true, desc = 'Yank and comment', })
map('v', 'gycc', function()
	return "ygvgc`]$p"
end, { remap = true, expr = true, desc = 'Yank and comment', })



---@param value string
---@param key string|nil
local map_quick_postfix = function(value, key)
	if not key then
		key = value
	end

	map('n', '<C-' .. key .. '>', 'mz<ESC>A' .. value .. '<ESC>`z')
	map('i', '<C-' .. key .. '>', '<ESC>mz<ESC>A' .. value .. '<ESC>`za')
end
map_quick_postfix(',')
map_quick_postfix(';')

---@param value string
---@param key string|nil
local map_quick_prefix = function(value, key, mod)
	if not mod then mod = '<C-M-' end
	if not key then key = value end

	local move_str = vim.iter(vim.split(value, '')):map(function() return 'l' end):join('')
	map('n', mod .. key .. '>', 'mz<ESC>^i' .. value .. '<ESC>`z' .. move_str)
	map('i', mod .. key .. '>', '<ESC>mz<ESC>^i' .. value .. '<ESC>`za' .. move_str)
end
map_quick_prefix('await ', 'a')
map_quick_prefix('return ', 'r')
map_quick_prefix('export ', 'e')

-- Paste with prefix
map('n', '<M-p>', function()
	local char = vim.fn.input('Separator: ')
	if char:len() ~= 0 then
		vim.cmd('norm a' .. char .. ' ')
		vim.cmd('norm p')
	end
end)

---- Plugin Settings ----
-- Highlighted yank
g.highlightedyank_highlight_duration = 500

-- Neovim plugins
local extra_parsing = {
	tailwind = true,
	sass = { enable = true, parsers = { "css" }, },
}
require 'colorizer'.setup {
	user_default_options = {
		RGB = true,
		RRGGBB = true,
		names = true,
		RRGGBBAA = true,
		AARRGGBB = true,
		rgb_fn = true,
		hsl_fn = true,
		css = true,
		css_fn = true,
		mode = 'background',
	},
	filetypes = {
		'*',
		cmp_docs = { always_update = true, },
		scss = extra_parsing,
		css = extra_parsing,
		typescript = extra_parsing,
		javascript = extra_parsing,
		html = extra_parsing,
	},
}

require 'barbar'.setup {
	exclude_ft = { 'neo-tree' },
	focus_on_close = 'previous',
	icons = {
		buffer_number = true,
	}
}
map('n', '<M-b>',   ':BufferPick<CR>',       { desc = 'Buffer pick' })
map('n', '<C-M-b>', ':BufferPickDelete<CR>', { desc = 'Buffer pick delete' })

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

require 'nvim-surround'.setup { move_cursor = false }

local autopairs = require 'nvim-autopairs'
autopairs.setup {
	disable_filetype = { 'TelescopePrompt', 'guihua', 'guihua_rust', 'clap_input', },
	check_ts = true,
	enable_check_bracket_line = true,
	fast_wrap = {
		map = '<M-w>'
	},
	enable_moveright = true,
}
local Rule = require 'nvim-autopairs.rule'
local cond = require 'nvim-autopairs.conds'
autopairs.add_rules {
	Rule('<', '>')
			:with_pair(cond.not_filetypes({ 'cs', }))
			:with_pair(cond.before_regex('%a+'))
			:with_move(cond.after_text('>')),
	Rule('|', '|', 'ruby')
			:with_move(cond.after_text('|')),
}

require 'bigfile'.setup {
	pattern = { '*' },
	filesize = 1,
	features = {
		"indent_blankline",
		"illuminate",
		"lsp",
		"treesitter",
		"syntax",
		"matchparen",
		"vimopts",
		"filetype",
		{
			name = 'reactive',
			opts = { defer = false },
			disable = function() vim.cmd 'ReactiveStop' end,
		},
		{ name = 'wrap',
			opts = { defer = false },
			disable = function() vim.opt_local.wrap = false end,
		},
		{ name = 'rainbow',
			opts = { defer = false },
			disable = function(bufnr) require 'rainbow-delimiters'.disable(bufnr) end,
		},
	}
}

require 'reactive'.setup { builtin = {
	cursorline = true,
	cursor = true,
	modemsg = true
} }

require 'which-key'.setup {
	delay = function(ctx) return ctx.plugin and 0 or 400 end,
}

require 'mini.align'.setup {}
require 'mini.ai'.setup { n_lines = 10000, }

require 'marks'.setup {
	default_mappings = true,
	builtin_marks = { '.', '<', '>', '^' },
	excluded_filetypes = {
		'fugitive',
		'neo-tree',
		'neo-tree-popup',
		'man',
		'guihua',
	},
	excluded_buftypes = {
		'nofile',
		'prompt',
		'terminal',
	},
}

require 'diffview'.setup { view = { merge_tool = { layout = 'diff3_mixed', }, }, }

require 'qfc'.setup { enabled = true, timeout = 1000, }

require 'visual-whitespace'.setup {}

api.nvim_create_autocmd('FileType', {
	pattern = { 'csv', 'tsv', },
	callback = function()
		require 'decisive'.setup {}
		require 'decisive'.align_csv {}
		vim.api.nvim_create_user_command('AlignCsv',
			function() require 'decisive'.align_csv {} end,
			{ desc = 'Align CSV columns' }
		)
		map('n', '[v', function() require('decisive').align_csv_prev_col() end)
		map('n', ']v', function() require('decisive').align_csv_next_col() end)
	end
})

require 'bufresize'.setup()

local gitsigns = require 'gitsigns'
gitsigns.setup { sign_priority = 99, }
map('n', ']c', function()
	if vim.wo.diff then
		vim.cmd.normal({ ']c', bang = true })
	else
		gitsigns.nav_hunk('next')
	end
end, { desc = 'Git hunk next' })
map('n', '[c', function()
	if vim.wo.diff then
		vim.cmd.normal({ '[c', bang = true })
	else
		gitsigns.nav_hunk('prev')
	end
end, { desc = 'Git hunk prev' })
