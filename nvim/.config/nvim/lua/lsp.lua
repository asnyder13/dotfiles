local map = require 'util'.map_keys_table

local api = vim.api
local opt = vim.opt

-- Treesitter
require 'nvim-treesitter.configs'.setup {
	ensure_installed = {
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
local on_attach = {}
on_attach.base = function(_, bufnr)
	-- Mappings.
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	map('n', 'gD',        function() vim.lsp.buf.declaration() end, opts)
	map('n', 'gd',        function() vim.lsp.buf.definition() end, opts)
	map('n', 'K',         function() vim.lsp.buf.hover() end, opts)
	map('n', 'gh',        function() vim.lsp.buf.hover() end, opts)
	map('n', 'gi',        function() vim.lsp.buf.implementation() end, opts)
	map('n', '<C-k>',     function() vim.lsp.buf.signature_help() end, opts)
	map('i', '<C-s>',     function() vim.lsp.buf.signature_help() end, opts)
	map('n', '<leader>D', function() vim.lsp.buf.type_definition() end, opts)
	map('n', '<M-r>',     function() vim.lsp.buf.rename() end, opts)
	map('n', '<M-e>',     function() vim.lsp.buf.rename() end, opts)
	map({ 'n', 'v' }, '<C-Space>', function() vim.lsp.buf.code_action() end, opts)
	map('n', { '<C-F12>', '<M-F12>' }, function() vim.lsp.buf.references() end, opts)
	map('n', '<leader>r', function() vim.lsp.buf.references() end, opts)
	map('n', '<leader>e', function() vim.diagnostic.open_float() end, opts)
	map('n', '[d',        function() vim.lsp.diagnostic.goto_prev() end, opts)
	map('n', ']d',        function() vim.lsp.diagnostic.goto_next() end, opts)
	map('n', '<leader>q', function() vim.lsp.diagnostic.set_loclist() end, opts)
	map('n', '<C-]>', function() vim.lsp.buf.definition() end, opts)
end

local _timers = {}
on_attach.ruby_lsp = function(client, buffer)
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

	on_attach.base(client, buffer)
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
				checkThirdParty = false
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
			on_attach = on_attach.base,
			capabilities = capabilities,
		}
	end,
	['lua_ls'] = function()
		lspconfig.lua_ls.setup {
			on_attach = on_attach.base,
			settings = custom_settings.lua,
			capabilities = capabilities,
		}
	end,
	['sorbet'] = function()
		local target_path = require 'util'.create_expand_path '~/.cache/sorbet'
		lspconfig.sorbet.setup {
			on_attach = on_attach.base,
			cmd = { 'srb', 'tc', '--lsp', target_path },
			capabilities = capabilities,
		}
	end,
	['ruby_lsp'] = function()
		lspconfig.ruby_lsp.setup {
			on_attach = on_attach.ruby_lsp,
		}
	end,
}

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})

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
require 'dap-local'

local prettierd = require 'formatter.defaults.prettierd'
local formatter_fts = {
	['*'] = {
		-- 'formatter.filetypes.any' defines default configurations for any filetype
		require('formatter.filetypes.any').remove_trailing_whitespace,
	},
	ruby = { require 'formatter.filetypes.ruby'.rubocop },

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
}
require 'formatter'.setup {
	logging = true,
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = formatter_fts,
}

local ft_extensions = vim.tbl_keys(formatter_fts)
local map_formatting_group = vim.api.nvim_create_augroup('FormattingMaps', { clear = true })
vim.api.nvim_create_autocmd({ 'FileType', }, {
	group = map_formatting_group,
	pattern = '*',
	callback = function(event)
		local bufnr = event.buf
		if vim.tbl_contains(ft_extensions, event.match) then
			map('n', '==', ':Format<CR>', { silent = true, buffer = bufnr })
		else
			map('n', '==', function() vim.lsp.buf.format { async = true } end, { silent = true, buffer = bufnr })
		end
	end
})

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

vim.diagnostic.config {
	virtual_text = false,
}
local trouble = require 'trouble'
map('n', '<leader>t', function() trouble.toggle() end)
map('n', ']t', function() vim.diagnostic.goto_next() end)
map('n', '[t', function() vim.diagnostic.goto_prev() end)

require 'corn'.setup {
	border_style = 'rounded',
	scope = 'line',
}

map({ 'n', 'x', 'o' }, '<leader>v', function()
	if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil then
		require 'treemonkey'.select({
			ignore_injections = false,
			highlight = { backdrop = 'FloatTitle', label = 'HopNextKey1' },
		})
	else
		vim.print('TS not active for this ft (' .. vim.cmd('set ft?') .. ')')
	end
end)
