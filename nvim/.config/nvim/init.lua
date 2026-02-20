local Util = require 'util'
local map  = Util.map_keys_table


local g   = vim.g
local api = vim.api
local opt = vim.opt


local build_configs = {
	['telescope-fzf-native.nvim'] = { build = 'make', },
	['nvim-treesitter'] = { cmd = 'TSUpdate', },
	['LuaSnip'] = { build = 'make install_jsregexp', },
	['guihua.lua'] = { build = 'make -C lua/fzy', },
}

-- Run build commands if required
vim.api.nvim_create_autocmd('PackChanged', {
	callback = function(ev)
		local name = ev.data.spec.name
		local build_config = build_configs[name]
		if build_config == nil then return end

		local build, cmd = build_config.build, build_config.cmd
		if build ~= nil then
			local buildtbl = vim.iter(build:gmatch([[([^%s]+)]])):totable()
			local result = vim.system(buildtbl, { cwd = ev.data.path }):wait()
			if result.code ~= 0 then
				vim.notify(string.format('Build for %s failed with code %s: %s', name, result.code, result.stderr))
			end
		end

		if cmd ~= nil and cmd:len() > 0 then
			if not ev.data.active then
				vim.cmd.packadd(name)
			end
			vim.cmd(cmd)
		end
	end
})

local gh = function(path) return 'https://github.com/' .. path end
local cb = function(path) return 'https://codeberg.org/' .. path end
vim.pack.add {
	-- Colorscheme, Neovim specific
	gh 'judaew/ronny.nvim',

	-- Regular vim
	gh 'ntpeters/vim-better-whitespace',
	gh 'tpope/vim-fugitive',
	gh 'jlcrochet/vim-razor',
	gh 'tpope/vim-abolish',
	gh 'mattn/emmet-vim',

	-- Neovim specific
	gh 'nvim-tree/nvim-web-devicons',
	gh 'NvChad/nvim-colorizer.lua',
	gh 'smoka7/hop.nvim',
	gh 'lukas-reineke/indent-blankline.nvim',
	gh 'nvim-lua/plenary.nvim',
	gh 'nvim-lua/popup.nvim',
	gh 'romgrk/barbar.nvim',
	gh 'Everduin94/nvim-quick-switcher',
	gh 'kylechui/nvim-surround',
	gh 'RRethy/vim-illuminate',
	gh 'nvim-neo-tree/neo-tree.nvim',
	gh 'MunifTanjim/nui.nvim',
	gh 's1n7ax/nvim-window-picker',
	gh 'bluz71/nvim-linefly',
	gh 'windwp/nvim-autopairs',
	gh 'LunarVim/bigfile.nvim',
	gh 'rasulomaroff/reactive.nvim',
	gh 'folke/which-key.nvim',
	gh 'BranimirE/fix-auto-scroll.nvim',
	gh 'chentoast/marks.nvim',
	gh 'sindrets/diffview.nvim',
	gh 'mei28/qfc.nvim',
	gh 'chrisgrieser/nvim-spider',
	gh 'mcauley-penney/visual-whitespace.nvim',
	cb 'andyg/leap.nvim',
	gh 'kwkarlwang/bufresize.nvim',
	gh 'hat0uma/csvview.nvim',
	gh 'monaqa/dial.nvim',
	gh 'm4xshen/hardtime.nvim',
	gh 'rcarriga/nvim-notify',

	-- mini.nvim
	gh 'nvim-mini/mini.ai',
	gh 'nvim-mini/mini.align',
	gh 'nvim-mini/mini.move',
	gh 'asnyder13/mini.diff',
	gh 'nvim-mini/mini.bufremove',
	gh 'nvim-mini/mini.operators',

	-- telescope
	gh 'nvim-telescope/telescope.nvim',
	{ src = gh 'nvim-telescope/telescope-fzf-native.nvim' },
	gh 'benfowler/telescope-luasnip.nvim',

	-- Treesitter
	{ src = gh 'nvim-treesitter/nvim-treesitter',         version = 'master', },
	gh 'nvim-treesitter/nvim-treesitter-refactor',
	gh 'atusy/treemonkey.nvim',
	gh 'windwp/nvim-ts-autotag',
	gh 'RRethy/nvim-treesitter-endwise',
	gh 'aaronik/treewalker.nvim',
	gh 'Wansmer/treesj',
	gh 'Goose97/timber.nvim',
	gh 'MeanderingProgrammer/render-markdown.nvim',

	-- LSP
	gh 'neovim/nvim-lspconfig',
	gh 'mason-org/mason.nvim',
	gh 'mason-org/mason-lspconfig.nvim',
	gh 'mhartington/formatter.nvim',
	gh 'j-hui/fidget.nvim',
	gh 'dmmulroy/ts-error-translator.nvim',
	gh 'rachartier/tiny-inline-diagnostic.nvim',
	gh 'seblyng/roslyn.nvim',

	-- cmp for LSP
	gh 'hrsh7th/nvim-cmp',
	gh 'hrsh7th/cmp-nvim-lsp',
	gh 'hrsh7th/cmp-nvim-lua',
	gh 'hrsh7th/cmp-buffer',
	gh 'hrsh7th/cmp-cmdline',
	{ src = cb 'FelipeLema/cmp-async-path' },
	gh 'ray-x/cmp-treesitter',

	-- Snippets
	{ src = gh 'L3MON4D3/LuaSnip' },
	gh 'rafamadriz/friendly-snippets',
	gh 'honza/vim-snippets',
	gh 'saadparwaiz1/cmp_luasnip',

	-- DAP
	gh 'mfussenegger/nvim-dap',
	gh 'jay-babu/mason-nvim-dap.nvim',
	gh 'theHamsta/nvim-dap-virtual-text',
	gh 'suketa/nvim-dap-ruby',

	-- misc
	gh 'HiPhish/rainbow-delimiters.nvim',
	gh 'b0o/schemastore.nvim',
	{ src = gh 'ray-x/guihua.lua' },
	{ src = gh 'ray-x/navigator.lua', version = 'treesitter-main' },
}

local notify = require 'notify'
notify.setup {
	merge_duplicates = true,
	render = 'wrapped-compact',
	stages = 'static',
}
vim.notify = notify

vim.cmd.packadd 'matchit'
require 'vim._extui'.enable {}

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
api.nvim_create_autocmd('TextYankPost', { callback = function() vim.hl.on_yank { timeout = 350 } end, })
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
require 'highlighting'
require '_telescope'
require 'switcher'
require '_neo-tree'
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
api.nvim_create_autocmd('FileType', { pattern = { 'html', 'css', 'cshtml', 'razor', }, command = 'EmmetInstall' })

-- Persistent Undo/Redo
if vim.fn.has 'persistent_undo' == 1 then
	local basepath = vim.fn.expand('$XDG_DATA_HOME')
	if basepath == '$XDG_DATA_HOME' then basepath = '~/.local/share' end

	local target_path = Util.create_expand_path(basepath .. '/nvim/nvim-persisted-undo/')
	opt.undodir = target_path
	opt.undofile = true
end

---- General Mappings ----
map('n', 'ZZ', '<NOP>')
map('n', { '<C-t><C-c>', '<C-t>c' }, ':tabclose<CR>', { desc = 'Close tab' })
-- Reload this config
map('n', '<leader>sv', ':source $MYVIMRC<CR>', { desc = 'Source vimrc/init' })

map('n', '<leader>zc', ':%foldc!<CR>', { desc = 'Close all folds' })
map('x', '<leader>zc', ":'<,'>foldc!<CR>", { desc = 'Close all folds' })
map('n', '<leader>zC', ':%foldo<CR>', { desc = 'Open all folds' })
map('n', 'gbd', function() require 'mini.bufremove'.wipeout() end, { desc = 'Buffer delete, keep window' })
map('n', '<BS>', '<C-^>', { desc = 'Last buffer' })
map('n', '<C-w>,', function() vim.cmd('resize ' .. vim.fn.line('$')) end, { desc = 'Size window to content' })

-- Toggle mappings
map('n', '<leader>tw', ':set wrap!<CR>', { desc = 'Toggle wrap' })
map('n', '<leader>tm', function() vim.opt_local.mouse = vim.tbl_isempty(vim.opt_local.mouse:get()) and mouse or '' end,
	{ desc = 'Toggle mouse' })
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

map('n', '<leader>p', 'p`[', { desc = 'paste keep cursor', })
map('n', '<leader>P', 'P`[', { desc = 'Paste keep curosr', })


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
map_quick_prefix('const ', 'c')
map_quick_prefix('let ', 'l')

-- Paste with prefix
-- map('n', '<M-p>', function()
-- 	local char = vim.fn.input('Separator: ')
-- 	if char:len() ~= 0 then
-- 		vim.cmd('norm a' .. char .. ' ')
-- 		vim.cmd('norm p')
-- 	end
-- end)

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
map('n', '<M-b>', ':BufferPick<CR>', { desc = 'Buffer pick' })
map('n', '<C-M-b>', ':BufferPickDelete<CR>', { desc = 'Buffer pick delete' })

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
	Rule('#if', ' #endif', 'cs'),
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

require 'csvview'.setup()

require 'bufresize'.setup()

require 'mini.diff'.setup {
	view = {
		style = 'number'
	},
	mappings = {
		reset = '',
	},
}

require 'dial'

require 'hardtime'.setup {
	disabled_keys = {
		['<Left>'] = false,
		['<Right>'] = false,
		['<Up>'] = false,
		['<Down>'] = false,
	},
	disable_mouse = false,
}

require 'mini.operators'.setup {}
