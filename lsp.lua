require 'util'
local map = Util.map

local cmd = vim.cmd
local fn  = vim.fn
local g   = vim.g
local api = vim.api
local opt = vim.opt

local paq = require 'paq'
paq {
	{ 'nvim-treesitter/nvim-treesitter', run = function() cmd ':TSUpdate' end },
	'neovim/nvim-lspconfig',
	'mfussenegger/nvim-dap',
	'williamboman/mason.nvim',
	'williamboman/mason-lspconfig.nvim',
	'jay-babu/mason-nvim-dap.nvim',
	'theHamsta/nvim-dap-virtual-text',
	'nvim-treesitter/playground',
	'mhartington/formatter.nvim',

	'suketa/nvim-dap-ruby',

	'hrsh7th/nvim-cmp',
	'hrsh7th/cmp-nvim-lsp',
	'hrsh7th/cmp-buffer',
	'hrsh7th/cmp-path',
	'hrsh7th/cmp-nvim-lsp-signature-help',
}

-- Treesitter
require 'nvim-treesitter.configs'.setup {
	ensure_installed = {
		'bash',
		'c_sharp',
		'css',
		'html',
		'java',
		'javascript',
		'json',
		'lua',
		'python',
		'ruby',
		'scss',
		'typescript',
		'yaml',
	}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	-- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
	highlight = { enable = true },
	incremental_selection = { enable = true },
	textobjects = { enable = true },
	indent = { enable = true },
}

---- Language Servers
require 'mason'.setup {}
require 'mason-lspconfig'.setup {}
require 'mason-nvim-dap'.setup {}

-- lsp_installer/lspconfig

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
	-- Mappings.
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	map('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	map('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	map('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	map('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	map('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	map('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	map('i', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	map('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	map('n', '<M-r>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	map('n', '<M-e>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	map({ 'n', 'v' }, '<C-Space>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	-- map('v', '<C-Space>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	-- map('v', '<leader>a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	map('n', '<C-F12>', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	map('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	map('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	map('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	map('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
	map('n', '==', '<cmd>lua vim.lsp.buf.format { async = true }<CR>', opts)
	map('n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

	-- cmd [[command! Format execute 'lua vim.lsp.buf.formatting()']]
end

-- Setup installed servers.
local custom_settings = {
	lua = {
		Lua = {
			runtime = {
				-- LuaJIT in the case of Neovim
				version = 'LuaJIT',
				path = vim.split(package.path, ';'),
			},
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { 'vim' },
			},
			workspace = {
				-- Make the server aware of Neovim runtime files
				library = vim.api.nvim_get_runtime_file('', true),
			},
			telemetry = { enable = false },
		},
	},
}

local lspconfig = require 'lspconfig';
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require 'mason-lspconfig'.setup_handlers {
	function(server_name)
		lspconfig[server_name].setup {
			on_attach = on_attach,
			capabilities = capabilities,
		}
	end,
	['lua_ls'] = function()
		lspconfig.lua_ls.setup {
			on_attach = on_attach,
			settings = custom_settings.lua,
			capabilities = capabilities,
		}
	end,
	['sorbet'] = function()
		local target_path = Util.create_expand_path '~/.cache/sorbet'
		lspconfig.sorbet.setup {
			on_attach = on_attach,
			cmd = { 'srb', 'tc', '--lsp', target_path },
			capabilities = capabilities,
		}
	end,
}

-- cmpe
opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
-- opt.completeopt = { 'menu', 'noselect', 'noinsert' }
local cmp = require 'cmp'
cmp.setup {
	mapping = {
		['<S-Tab>'] = cmp.mapping.select_prev_item(),
		['<Tab>'] = cmp.mapping.select_next_item(),
		['<C-p>'] = cmp.mapping.select_prev_item(),
		['<C-n>'] = cmp.mapping.select_next_item(),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.close(),
		['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace },
		['<C-d>'] = cmp.mapping.scroll_docs(4),
		['<C-u>'] = cmp.mapping.scroll_docs(-4),
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp',   group_index = 1 },
		{ name = 'treesitter', group_index = 2 },
		{ name = 'buffer',     group_index = 3 },
		{ name = 'path',       group_index = 3 },
	}, {
		{ name = 'nvim_lsp_signature_help' },
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	completion = { completeopt = 'menuone,noinsert,noselect' }
}

-- DAP
require 'nvim-dap-virtual-text'.setup {}
local dap = require 'dap'

-- dap mappings
local dap_opts = {
	silent = true,
	buffer = true,
}
map('n', '<F5>', function() return dap.continue() end, dap_opts)
map('n', '<Leader><F5>', function() return dap.terminate() end, dap_opts)
map('n', '<F10>',        function() return dap.step_over() end, dap_opts)
map('n', '<Leader><F11>',function() return dap.step_into() end, dap_opts)
map('n', '<F11>',        function() return dap.step_into() end, dap_opts)
map('n', '<F12>',        function() return dap.step_out() end, dap_opts)
map('n', '<Leader>db',   function() return dap.toggle_breakpoint() end, dap_opts)
map('n', '<F9>',         function() return dap.toggle_breakpoint() end, dap_opts)
map('n', '<Leader>dB',   function() return dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, dap_opts)
map('n', '<Leader>lp',   function() return dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, dap_opts)
map('n', '<Leader>dr',   function() return dap.repl.open() end, dap_opts)
map('n', '<Leader>dl',   function() return dap.run_last() end, dap_opts)
map({'n', 'v'}, '<Leader>dh', function() require('dap.ui.widgets').hover() end)
map({'n', 'v'}, '<Leader>dp', function() require('dap.ui.widgets').preview() end)
map('n', '<Leader>df', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.frames)
end)
map('n', '<Leader>ds', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.scopes)
end)


require 'dap-ruby'.setup()
-- re-set configs, only want one.
dap.configurations.ruby = {
	{
		type = 'ruby',
		name = 'debug current file',
		bundle = '',
		request = 'attach',
		command = 'ruby',
		script = '${file}',
		port = 38698,
		server = '127.0.0.1',
		options = {
			source_filetype = 'ruby',
		},
		localfs = true,
		waiting = 1000,
	},
}

local formatter_util = require 'formatter.util'
-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require('formatter').setup {
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		-- Formatter configurations for filetype 'lua' go here
		-- and will be executed in order
		lua = {
			-- 'formatter.filetypes.lua' defines default configurations for the
			-- 'lua' filetype
			-- require 'formatter.filetypes.lua'.stylua,

			-- You can also define your own configuration
			function()
				-- Full specification of configurations is down below and in Vim help files
				return {
					exe = 'stylua',
					args = {
						'--config-path=$HOME/.config/stylua.toml',
						'--search-parent-directories',
						'--stdin-filepath',
						formatter_util.escape_path(formatter_util.get_current_buffer_file_path()),
						'--',
						'-',
					},
					stdin = true,
				}
			end,
		},
		cs = { require('formatter.filetypes.cs').dotnetformat },
		-- Use the special '*' filetype for defining formatter configurations on any filetype
		['*'] = {
			-- 'formatter.filetypes.any' defines default configurations for any filetype
			require('formatter.filetypes.any').remove_trailing_whitespace,
		},
	},
}
