local map = require 'util'.map_keys_table
local center = require 'util'.run_then_center_cursor_func

---- DAP
-- local dap_on_attach = require '_dap'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
---@type vim.lsp.client.on_attach_cb
local on_attach = function(client, bufnr)
	-- Mappings
	local opts = { noremap = true, buffer = bufnr, desc = nil }
	local o = function(desc) return vim.tbl_extend('force', opts, { desc = desc }) end

	-- if dap_on_attach then dap_on_attach(bufnr) end

	map('n', '<leader>h',  vim.diagnostic.open_float,  o('lsp_open_float'))
	map('n', 'gh',         vim.lsp.buf.hover,          o('lsp_hover'))
	map('n', 'gW',         require 'navigator.workspace'.workspace_symbol_live, o('workspace_symbol_live'))
	map('n', '<leader>gT', require 'navigator.treesitter'.bufs_ts,              o('bufs_ts'))

	map('n', 'gD',        vim.lsp.buf.declaration,                                     o('declaration'))
	map('n', '<C-]>',     function() vim.lsp.buf.definition({ reuse_win = true }) end, o('definition'))
	map('n', '<leader>D', require 'navigator.definition'.type_definition_preview,      o('definition preview'))
	map('n', '<leader>r', require 'navigator.reference'.async_ref,                     o('async_ref'))

	map({ 'n', 'v' }, { '<C-Space>', '<C-.>' }, require 'navigator.codeAction'.code_action, o('code_action'))
	map('n', { '<M-r>', '<M-e>' },              vim.lsp.buf.rename,                         o('rename'))

	map('n', '<leader>gi', vim.lsp.buf.incoming_calls, o('incoming_calls'))
	map('n', '<leader>go', vim.lsp.buf.outgoing_calls, o('outgoing_calls'))
	map('n', 'gi',         center(function() vim.lsp.buf.implementation({ reuse_win = true }) end), o('implementation'))
	map('n', 'g<C-]>',     vim.lsp.buf.type_definition,                          o('type_definition'))
	map('n', 'gL',         require 'navigator.diagnostics'.show_diagnostics,     o('show_diagnostics'))
	map('n', 'gG',         require 'navigator.diagnostics'.show_buf_diagnostics, o('show_buf_diagnostics'))
	map('n', ']d',         require 'navigator.diagnostics'.goto_next,            o('next_diagnostics'))
	map('n', '[d',         require 'navigator.diagnostics'.goto_prev,            o('prev_diagnostics'))
	map('n', ']O',         vim.diagnostic.set_loclist,                           o('diagnostics_set_loclist'))
	map('n', ']r',         require 'navigator.treesitter'.goto_next_usage,       o('goto_next_usage'))
	map('n', '[r',         require 'navigator.treesitter'.goto_previous_usage,   o('goto_previous_usage'))
	map('n', '<leader>k',  require 'navigator.dochighlight'.hi_symbol,  o('hi_symbol'))
	map('v', '<leader>gm', require 'navigator.formatting'.range_format, o('rangeformatoperatore.ggmip'))

	map('n', '<leader>ti', function()
		local ilh_state = vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }
		vim.lsp.inlay_hint.enable(not ilh_state, { bufnr = bufnr })
	end, o('toggle inlay hints'))

	if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
	end
end

return on_attach
