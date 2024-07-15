local map = require 'util'.map_keys_table

local api = vim.api
local opt = vim.opt

-- Hide default LSP popup
map('n', '<C-k>', '<NOP>')

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
		'json5',
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

---- DAP
local dap_on_attach = require 'dap-local'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = {}
on_attach.base = function(client, bufnr)
	-- Mappings
	local opts = { noremap = true, buffer = bufnr, desc = nil }
	local o = function(desc) return vim.tbl_extend('force', opts, { desc = desc }) end

	dap_on_attach(bufnr)

	map('n', '<leader>h',  vim.diagnostic.open_float,               o('lsp_open_float'))
	map('n', 'gh',         vim.lsp.buf.hover,                       o('lsp_hover'))
	map('i', '<M-K>',      vim.lsp.buf.signature_help,              o('signature_help'))
	map('n', '<C-k>',      vim.lsp.buf.signature_help,              o('signature_help'))
	map('n', 'gW',         require 'navigator.workspace'.workspace_symbol_live, o('workspace_symbol_live'))
	map('n', '<leader>gT', require 'navigator.treesitter'.bufs_ts,              o('bufs_ts'))

	map('n', 'gD',        vim.lsp.buf.declaration,                                             o('declaration'))
	map('n', '<C-]>',     require 'navigator.definition'.definition or vim.lsp.buf.definition, o('definition'))
	map('n', 'gd',        require 'navigator.definition'.definition or vim.lsp.buf.definition, o('definition'))
	map('n', '<leader>r', require 'navigator.reference'.async_ref,                             o('async_ref'))

	-- map({ 'n', 'v' }, { '<C-Space>', '<C-.>' }, vim.lsp.buf.code_action,                       o('code_action'))
	map({ 'n', 'v' }, { '<C-Space>', '<C-.>' }, require 'navigator.codeAction'.code_action, o('code_action'))
	map('n', { '<M-r>', '<M-e>' }, vim.lsp.buf.rename, o('rename'))

	map('n', '<leader>gi', vim.lsp.buf.incoming_calls,                            o('incoming_calls'))
	map('n', '<leader>go', vim.lsp.buf.outgoing_calls,                            o('outgoing_calls'))
	map('n', 'gi',         vim.lsp.buf.implementation,                            o('implementation'))
	map('n', '<leader>D',  vim.lsp.buf.type_definition,                           o('type_definition'))
	map('n', 'gL',         require 'navigator.diagnostics'.show_diagnostics,      o('show_diagnostics'))
	map('n', 'gG',         require 'navigator.diagnostics'.show_buf_diagnostics,  o('show_buf_diagnostics'))
	map('n', ']d',         require 'navigator.diagnostics'.goto_next,             o('next_diagnostics'))
	map('n', '[d',         require 'navigator.diagnostics'.goto_prev,             o('prev_diagnostics'))
	map('n', ']O',         vim.diagnostic.set_loclist,                            o('diagnostics_set_loclist'))
	map('n', ']r',         require 'navigator.treesitter'.goto_next_usage,        o('goto_next_usage'))
	map('n', '[r',         require 'navigator.treesitter'.goto_previous_usage,    o('goto_previous_usage'))
	map('n', '<leader>k',  require 'navigator.dochighlight'.hi_symbol,            o('hi_symbol'))
	map('v', '<leader>gm',  require 'navigator.formatting'.range_format,           o('rangeformatoperatore.ggmip'))
	-- map('n', '<leader>wa',  require 'navigator.workspace'.add_workspace_folder,    o('add_workspace_folder'))
	-- map('n', '<leader>wr',  require 'navigator.workspace'.remove_workspace_folder, o('remove_workspace_folder'))
	-- map('n', '<leader>wl',  require 'navigator.workspace'.list_workspace_folders,  o('list_workspace_folders'))

	map('n', '<leader>ti', function()
		local ilh_state = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
		vim.lsp.inlay_hint.enable(not ilh_state, { bufnr = bufnr })
	end, o('toggle inlay hints'))

	if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	require 'navigator.lspclient.mapping'.setup({ bufnr = bufnr, client = client })

	require("better-diagnostic-virtual-text.api").setup_buf(bufnr, {
		inline = true,
		ui = {
			wrap_line_after = true, -- Wrap the line after this length to avoid the virtual text is too long
			above = false,
		}
	})

	require 'lsp_signature'.on_attach({
		hint_enable = false,
		hi_parameter = 'CursorLine',
	}, bufnr)
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

local default_cfg = {
	on_attach = on_attach.base,
	capabilities = vim.lsp.protocol.make_client_capabilities(),
	inlay_hints = { enabled = true },
}
local custom_cfg = {
	sorbet = function()
		local target_path = require 'util'.create_expand_path '~/.cache/sorbet'
		return { cmd = { 'srb', 'tc', '--lsp', '--disable-watchman', target_path }, }
	end,
	ruby_lsp = function() return { on_attach = on_attach.ruby_lsp } end,
	jsonls = function()
		return {
			settings = {
				schemas = require 'schemastore'.json.schemas(),
				validate = { enable = true }
			},
		}
	end,
	yamlls = function()
		return {
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
	tsserver = function()
		return {
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayVariableTypeHints = true,
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
				javascript = {
					inlayHints = {
						includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
						includeInlayParameterNameHintsWhenArgumentMatchesName = true,
						includeInlayVariableTypeHints = true,

						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHintsWhenTypeMatchesName = true,
						includeInlayPropertyDeclarationTypeHints = true,
						includeInlayFunctionLikeReturnTypeHints = true,
						includeInlayEnumMemberValueHints = true,
					},
				},
			},
		}
	end,
}

-- Setup installed servers.
require 'mason-lspconfig'.setup_handlers {
	function(server_name)
		local cfg = custom_cfg[server_name] and vim.tbl_deep_extend('force', default_cfg, custom_cfg[server_name]()) or
				default_cfg
		require 'lspconfig'[server_name].setup(cfg)
	end,
	-- Ignore RuboCop for LSP stuff, but we want it installed for formatting
	rubocop = function() end,
}

require 'guihua.maps'.setup { maps = { close_view = '<C-c>', }, }
require 'navigator'.setup {
	on_attach = function(...) on_attach.base(...) end,
	default_mapping = false,
	icons = { icons = false },
	mason = true,
	lsp = {
		enable = false,
		disable_lsp = 'all',
		code_action = { sign = false, virtual_text = false, },
		code_lens_action = { sign = false, virtual_text = false, },
		format_on_save = false,
		document_highlight = false,
		diagnostic_scrollbar_sign = false,
		diagnostic = {
			underline = false,
			virtual_text = true,
			update_in_insert = true,
		},
	},
}

-- cmp
opt.completeopt = { 'menu', 'noselect', 'noinsert' }
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
	mapping = {
		['<Tab>']     = function(fallback)
			if cmp.visible() then
				cmp.mapping.select_next_item()()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end,
		['<S-Tab>']   = function(fallback)
			if cmp.visible() then
				cmp.mapping.select_prev_item()()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end,
		['<C-p>']     = cmp.mapping.select_prev_item(),
		['<C-n>']     = cmp.mapping.select_next_item(),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>']     = cmp.mapping.close(),
		['<C-c>']     = cmp.mapping.close(),
		['<CR>']      = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true, },
		-- nvim_lsp_signature_help fixes, still doesn't work great.
		-- ['<CR>']      = function(fallback)
		-- 	-- Don't replace with the signature help param name when <CR> is hit.
		-- 	local entries = cmp.get_entries()
		-- 	if entries and entries[1] and entries[1].source and entries[1].source.source and entries[1].source.source['signature_help'] == nil then
		-- 		cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true, } ()
		-- 	else
		-- 		fallback()
		-- 	end
		-- end,
		['<C-d>']     = cmp.mapping.scroll_docs(4),
		['<C-u>']     = cmp.mapping.scroll_docs(-4),
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp',   group_index = 1 },
		{ name = 'treesitter', group_index = 2 },
		{ name = 'luasnip',    group_index = 3 },
		{ name = 'buffer',     group_index = 4,
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
		{ name = 'path', group_index = 5 },
		-- { name = 'nvim_lsp_signature_help' },
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	completion = { completeopt = 'menu,noinsert,noselect' },
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
}

-- If you want insert `(` after select function or method item
local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
)

-- luasnip
require 'luasnip.loaders.from_vscode'.lazy_load()
require 'luasnip.loaders.from_snipmate'.lazy_load()

map({ 'n', 'x', 'o' }, '<leader>v', function()
	if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil then
		require 'treemonkey'.select({
			ignore_injections = false,
			highlight = { backdrop = 'FloatTitle', label = 'HopNextKey1' },
		})
	else
		vim.print('TS not active for this ft (' .. vim.cmd 'set ft?' .. ')')
	end
end, { desc = 'Treemonkey' })
