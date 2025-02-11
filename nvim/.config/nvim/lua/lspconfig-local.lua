local map = require 'util'.map_keys_table
local center = require 'util'.run_then_center_cursor_func

---- DAP
-- local dap_on_attach = require 'dap-local'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = {}
on_attach.base = function(client, bufnr)
	-- Mappings
	local opts = { noremap = true, buffer = bufnr, desc = nil }
	local o = function(desc) return vim.tbl_extend('force', opts, { desc = desc }) end

	if dap_on_attach then dap_on_attach(bufnr) end

	map('n', '<leader>h',  vim.diagnostic.open_float,                           o('lsp_open_float'))
	map('n', 'gh',         vim.lsp.buf.hover,                                   o('lsp_hover'))
	map('i', '<M-K>',      vim.lsp.buf.signature_help,                          o('signature_help'))
	-- map('n', '<C-k>',      vim.lsp.buf.signature_help,                          o('signature_help'))
	map('n', 'gW',         require 'navigator.workspace'.workspace_symbol_live, o('workspace_symbol_live'))
	map('n', '<leader>gT', require 'navigator.treesitter'.bufs_ts,              o('bufs_ts'))

	map('n', 'gD',        center(vim.lsp.buf.definition),                                      o('declaration'))
	map('n', '<C-]>',     center(vim.lsp.buf.definition),                                      o('definition'))
	map('n', 'gd',        require 'navigator.definition'.definition or vim.lsp.buf.definition, o('definition'))
	map('n', '<leader>d', require 'navigator.definition'.definition_preview,                   o('definition preview'))
	map('n', '<leader>r', require 'navigator.reference'.async_ref,                             o('async_ref'))

	-- map({ 'n', 'v' }, { '<C-Space>', '<C-.>' }, vim.lsp.buf.code_action,                       o('code_action'))
	map({ 'n', 'v' }, { '<C-Space>', '<C-.>' }, require 'navigator.codeAction'.code_action, o('code_action'))
	map('n', { '<M-r>', '<M-e>' },              vim.lsp.buf.rename,                         o('rename'))

	map('n', '<leader>gi', vim.lsp.buf.incoming_calls,                                 o('incoming_calls'))
	map('n', '<leader>go', vim.lsp.buf.outgoing_calls,                                 o('outgoing_calls'))
	map('n', 'gi',         center(vim.lsp.buf.implementation),                         o('implementation'))
	map('n', '<leader>D',  center(vim.lsp.buf.type_definition),                        o('type_definition'))
	map('n', 'gL',         require 'navigator.diagnostics'.show_diagnostics,           o('show_diagnostics'))
	map('n', 'gG',         require 'navigator.diagnostics'.show_buf_diagnostics,       o('show_buf_diagnostics'))
	map('n', ']d',         center(require 'navigator.diagnostics'.goto_next),          o('next_diagnostics'))
	map('n', '[d',         center(require 'navigator.diagnostics'.goto_prev),          o('prev_diagnostics'))
	map('n', ']O',         vim.diagnostic.set_loclist,                                 o('diagnostics_set_loclist'))
	map('n', ']r',         center(require 'navigator.treesitter'.goto_next_usage),     o('goto_next_usage'))
	map('n', '[r',         center(require 'navigator.treesitter'.goto_previous_usage), o('goto_previous_usage'))
	map('n', '<leader>k',  require 'navigator.dochighlight'.hi_symbol,  o('hi_symbol'))
	map('v', '<leader>gm', require 'navigator.formatting'.range_format, o('rangeformatoperatore.ggmip'))
	-- map('n', '<leader>wa', require 'navigator.workspace'.add_workspace_folder,    o('add_workspace_folder'))
	-- map('n', '<leader>wr', require 'navigator.workspace'.remove_workspace_folder, o('remove_workspace_folder'))
	-- map('n', '<leader>wl', require 'navigator.workspace'.list_workspace_folders,  o('list_workspace_folders'))

	map('n', '<leader>ti', function()
		local ilh_state = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
		vim.lsp.inlay_hint.enable(not ilh_state, { bufnr = bufnr })
	end, o('toggle inlay hints'))

	if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
	end

	-- require 'navigator.lspclient.mapping'.setup({ bufnr = bufnr, client = client })

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
	omnisharp = function()
		return {
			handlers = { ['textDocument/definition'] = require 'omnisharp_extended'.handler }
		}
	end,
	lua_ls = function()
		return {
			on_init = function(client)
				client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
					runtime = { version = 'LuaJIT' },
					-- Make the server aware of Neovim runtime files
					workspace = {
						checkThirdParty = false,
						library = { vim.env.VIMRUNTIME }
					}
				})
			end,
			settings = {
				Lua = {}
			}
		}
	end,
}

return function()
	return default_cfg, custom_cfg
end
