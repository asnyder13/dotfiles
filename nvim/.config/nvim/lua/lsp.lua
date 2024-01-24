local map = require 'util'.map_keys_table

local api = vim.api
local opt = vim.opt

-- Treesitter
require 'nvim-treesitter.configs'.setup {
	ensure_installed = {
		'angular',
		'bash',
		'c_sharp',
		'css',
		'html',
		'javascript',
		'json',
		'lua',
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
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	}
}
require 'ts_context_commentstring'.setup {}
vim.g.skip_ts_context_commentstring_module = true

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
	map('n', 'gD', ':lua vim.lsp.buf.declaration()<CR>', opts)
	map('n', 'gd', ':lua vim.lsp.buf.definition()<CR>', opts)
	map('n', 'K', ':lua vim.lsp.buf.hover()<CR>', opts)
	map('n', 'gh', ':lua vim.lsp.buf.hover()<CR>', opts)
	map('n', 'gi', ':lua vim.lsp.buf.implementation()<CR>', opts)
	map('n', '<C-k>', ':lua vim.lsp.buf.signature_help()<CR>', opts)
	map('i', '<C-s>', ':lua vim.lsp.buf.signature_help()<CR>', opts)
	map('n', '<leader>D', ':lua vim.lsp.buf.type_definition()<CR>', opts)
	map('n', '<M-r>', ':lua vim.lsp.buf.rename()<CR>', opts)
	map('n', '<M-e>', ':lua vim.lsp.buf.rename()<CR>', opts)
	map({ 'n', 'v' }, '<C-Space>', ':lua vim.lsp.buf.code_action()<CR>', opts)
	map('n', { '<C-F12>', '<M-F12>' }, ':lua vim.lsp.buf.references()<CR>', opts)
	map('n', '<leader>r', ':lua vim.lsp.buf.references()<CR>', opts)
	map('n', '<leader>e', ':lua vim.diagnostic.open_float()<CR>', opts)
	map('n', '[d', ':lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	map('n', ']d', ':lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	map('n', '<leader>q', ':lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
	map('n', '=l', ':lua vim.lsp.buf.format { async = true }<CR>', opts)
	map('n', '==', ':Format<CR>', opts)
	map('n', '<C-]>', ':lua vim.lsp.buf.definition()<CR>', opts)

	-- cmd [[command! Format execute 'lua vim.lsp.buf.formatting()']]
end

local _timers = {}
local function on_attach_ruby_ls(client, buffer)
	if require("vim.lsp.diagnostic")._enable then
		return
	end

	local diagnostic_handler = function()
		local params = vim.lsp.util.make_text_document_params(buffer)
		client.request("textDocument/diagnostic", { textDocument = params }, function(err, result)
			if err then
				local err_msg = string.format("diagnostics error - %s", vim.inspect(err))
				vim.lsp.log.error(err_msg)
			end
			local diagnostic_items = {}
			if result then
				diagnostic_items = result.items
			end
			vim.lsp.diagnostic.on_publish_diagnostics(
				nil,
				vim.tbl_extend("keep", params, { diagnostics = diagnostic_items }),
				{ client_id = client.id },
				{ virtual_text = true }
			)
		end)
	end

	diagnostic_handler() -- to request diagnostics on buffer when first attaching

	vim.api.nvim_buf_attach(buffer, false, {
		on_lines = function()
			if _timers[buffer] then
				vim.fn.timer_stop(_timers[buffer])
			end
			_timers[buffer] = vim.fn.timer_start(200, diagnostic_handler)
		end,
		on_detach = function()
			if _timers[buffer] then
				vim.fn.timer_stop(_timers[buffer])
			end
		end,
	})

	on_attach(client, buffer)
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
		local target_path = require 'util'.create_expand_path '~/.cache/sorbet'
		lspconfig.sorbet.setup {
			on_attach = on_attach,
			cmd = { 'srb', 'tc', '--lsp', target_path },
			capabilities = capabilities,
		}
	end,
	['ruby_ls'] = function()
		lspconfig.ruby_ls.setup {
			on_attach = on_attach_ruby_ls,
		}
	end,
}

-- cmpe
-- opt.completeopt = { 'menuone', 'noinsert', 'noselect' }
opt.completeopt = { 'menu', 'noselect', 'noinsert' }
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
		{ name = 'luasnip',    group_index = 3 },
		{ name = 'buffer', group_index = 4,
			option = {
				-- get_bufnrs = function() vim.api.nvim_list_bufs() end
				get_bufnrs = function()
					local bufs = {}
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						bufs[vim.api.nvim_win_get_buf(win)] = true
					end
					return vim.tbl_keys(bufs)
				end
			}
		},
		{ name = 'path', group_index = 4 },
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	completion = { completeopt = 'menu,noinsert,noselect' },
	snippet = {
		expand = function(args)
			require 'luasnip'.lsp_expand(args.body)
		end,
	},
}
require 'lsp_signature'.setup {
	hint_enable = false,
	hi_parameter = 'Error',
}

-- If you want insert `(` after select function or method item
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
)

-- luasnip
require 'luasnip.loaders.from_vscode'.lazy_load()
require 'luasnip.loaders.from_snipmate'.lazy_load()


---- DAP
require 'nvim-dap-virtual-text'.setup {}
local dap = require 'dap'

-- dap mappings
local dap_opts = {
	silent = true,
	buffer = true,
}
map('n', '<F5>',          function() return dap.continue() end, dap_opts)
map('n', '<Leader><F5>',  function() return dap.terminate() end, dap_opts)
map('n', '<F10>',         function() return dap.step_over() end, dap_opts)
map('n', '<Leader><F11>', function() return dap.step_into() end, dap_opts)
map('n', '<F11>',         function() return dap.step_into() end, dap_opts)
map('n', '<F12>',         function() return dap.step_out() end, dap_opts)
map('n', { '<Leader>db', '<F9>' }, function() return dap.toggle_breakpoint() end, dap_opts)
map('n', '<Leader>dB',    function() return dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, dap_opts)
map('n', '<Leader>lp',    function() return dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, dap_opts)
map('n', '<Leader>dr',    function() return dap.repl.open() end, dap_opts)
map('n', '<Leader>dl',    function() return dap.run_last() end, dap_opts)
map({ 'n', 'v' }, '<Leader>dh', function() require('dap.ui.widgets').hover() end)
map({ 'n', 'v' }, '<Leader>dp', function() require('dap.ui.widgets').preview() end)
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

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
local formatter_util = require 'formatter.util'
local prettierd = require 'formatter.defaults.prettierd'
require 'formatter'.setup {
	-- Enable or disable logging
	logging = true,
	-- Set the log level
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = {
		cs = { require('formatter.filetypes.cs').dotnetformat },
		css = { prettierd },
		graphql = { prettierd },
		html = { prettierd },
		javascript = { prettierd },
		javascriptreact = { prettierd },
		['javascript.jsx'] = { prettierd },
		json = { prettierd },
		jsonc = { prettierd },
		less = { prettierd },
		markdown = { prettierd },
		scss = { prettierd },
		typescript = { prettierd },
		typescriptreact = { prettierd },
		['typescript.tsx'] = { prettierd },
		vue = { prettierd },
		yaml = { prettierd },
		-- Use the special '*' filetype for defining formatter configurations on any filetype
		['*'] = {
			-- 'formatter.filetypes.any' defines default configurations for any filetype
			require('formatter.filetypes.any').remove_trailing_whitespace,
		},
	},
}

vim.g.rainbow_delimiters = {
	highlight = {
		'RainbowDelimiterYellow',
		'RainbowDelimiterViolet',
		'RainbowDelimiterGreen',
	},
	blacklist = {
		'c_sharp',
	}
}
-- Colors from VSCode's rainbow highlight which work well w/ monokai.
local delimColors = {
	RainbowDelimiterYellow = '#FFFF40',
	RainbowDelimiterViolet = '#FF7FFF',
	RainbowDelimiterGreen  = '#7FFF7F',
	RainbowDelimiterCyan   = '#4FECEC',
}
for k, v in pairs(delimColors) do
	api.nvim_set_hl(0, k, { fg = v })
end
