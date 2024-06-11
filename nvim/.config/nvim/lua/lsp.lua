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
	indent = { enable = true, disable = { 'ruby' } },
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	endwise = { enable = true, },
}
require 'ts_context_commentstring'.setup {}
vim.g.skip_ts_context_commentstring_module = true

---- Language Servers
require 'mason'.setup {}
require 'mason-lspconfig'.setup {}

-- lsp_installer/lspconfig

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = {}
on_attach.base = function(client, bufnr)
	-- Mappings.
	local opts = { noremap = true, silent = true, buffer = bufnr, desc = 'LSP mapping' }

	require 'navigator.lspclient.mapping'.setup({ bufnr = bufnr, client = client })

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
local lspconfig = require 'lspconfig';
require 'mason-lspconfig'.setup_handlers {
	function (server_name)
		lspconfig[server_name].setup {}
	end,
	sorbet = function()
		local target_path = require 'util'.create_expand_path '~/.cache/sorbet'
		lspconfig.sorbet.setup {
			on_attach = on_attach.base,
			-- cmd = { 'srb', 'tc', '--lsp', target_path },
			-- cmd = { 'srb', 'tc', '--lsp', '--disable-watchman', target_path },
			cmd = { 'srb', 'tc', '--lsp', '--disable-watchman', '.' },
		}
	end,
	ruby_lsp = function()
		lspconfig.ruby_lsp.setup {
			on_attach = on_attach.ruby_lsp,
		}
	end,
	-- Ignore RuboCop for LSP stuff, but we want it installed for formatting
	rubocop = function() end,
	jsonls = function()
		lspconfig.jsonls.setup {
			settings = {
				schemas = require 'schemastore'.json.schemas(),
				validate = { enable = true }
			}
		}
	end,
	yamlls = function()
		lspconfig.yamlls.setup {
			settings = {
				yaml = {
					schemaStore = {
						-- You must disable built-in schemaStore support if you want to use
						-- this plugin and its advanced options like `ignore`.
						enable = false,
						-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
						url = "",
					},
					schemas = require 'schemastore'.yaml.schemas(),
				},
			},
		}
	end,
}

require 'navigator'.setup {
	mason = true,
	lsp = {
		-- disable_lsp = { 'sorbet', 'ruby_lsp', 'rubocop', 'jsonls', 'yamlls', 'omnisharp', },
		disable_lsp = 'all',
		format_on_save = false,
	},
	on_attach = function(_, bufnr)
		on_attach.base(_, bufnr)
	end,
	keymaps = {

	},
	-- default_mapping = false,
	icons = { icons = false },
}

-- Change border of documentation hover window, See https://github.com/neovim/neovim/pull/13998.
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})

-- cmpe
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

-- require 'lsp_signature'.setup {
-- 	hint_enable = false,
-- 	hi_parameter = 'Error',
-- }

-- If you want insert `(` after select function or method item
local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
)

-- luasnip
require 'luasnip.loaders.from_vscode'.lazy_load()
require 'luasnip.loaders.from_snipmate'.lazy_load()

---- DAP
require 'dap-local'

vim.diagnostic.config {
	virtual_text = false,
}

require 'corn'.setup {
	border_style = 'rounded',
	scope = 'line',
	---@param item Corn.Item
	---@return Corn.Item
	item_preprocess_func = function(item)
		local trunc_tail = "..."
		local max_width = vim.api.nvim_win_get_width(0) - 30

		if #item.message > max_width then
			item.message = string.sub(item.message, 1, max_width - #trunc_tail) .. trunc_tail
			item.source = trunc_tail
		end

		return item
	end,
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
end, { desc = 'Treemonkey' })

vim.lsp.inlay_hint.enable()
