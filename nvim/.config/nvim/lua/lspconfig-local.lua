local map = require 'util'.map_keys_table
local center = require 'util'.run_then_center_cursor_func

---- DAP
-- local dap_on_attach = require 'dap-local'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
---@type vim.lsp.client.on_attach_cb
local on_attach = function(client, bufnr)
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
	map('n', '<C-]>',     center(function() vim.lsp.buf.definition({ reuse_win = true }) end), o('definition'))
	map('n', 'gd',        function ()
		local definition = require 'navigator.definition'.definition or vim.lsp.buf.definition
		definition({ reuse_win = true })
	end, o('definition'))
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
	map('n', ']d',         require 'navigator.diagnostics'.goto_next,                  o('next_diagnostics'))
	map('n', '[d',         require 'navigator.diagnostics'.goto_prev,                  o('prev_diagnostics'))
	map('n', ']O',         vim.diagnostic.set_loclist,                                 o('diagnostics_set_loclist'))
	map('n', ']r',         require 'navigator.treesitter'.goto_next_usage,             o('goto_next_usage'))
	map('n', '[r',         require 'navigator.treesitter'.goto_previous_usage,         o('goto_previous_usage'))
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
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end

	map('i', '<C-l>', vim.lsp.buf.signature_help, o('Show signature help'))

	-- require 'navigator.lspclient.mapping'.setup({ bufnr = bufnr, client = client })

	-- require 'lsp_signature'.on_attach({
	-- 	hint_enable = false,
	-- 	hi_parameter = 'CursorLine',
	-- 	ignore_error = function(err, ctx, config)
	-- 		if ctx and ctx.client_id then
	-- 			local client = vim.lsp.get_client_by_id(ctx.client_id)
	-- 			if client and vim.tbl_contains({ 'rust_analyer', 'clangd', 'omnisharp' }, client.name) then
	-- 				return true
	-- 			end
	-- 		end
	-- 	end
	-- }, bufnr)
end

return on_attach
