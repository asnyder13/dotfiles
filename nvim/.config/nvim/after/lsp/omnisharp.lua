-- local omnisharp_extended = require 'omnisharp_extended'
local on_attach = require 'lspconfig-local'

---@type vim.lsp.Config
return {
	-- on_attach = function(client, bufnr)
	-- 	on_attach(client, bufnr)
	--
	-- 	local o = function(desc)
	-- 		return vim.tbl_extend('force', { noremap = true, buffer = bufnr, desc = nil }, { desc = desc })
	-- 	end
	-- 	vim.keymap.set('n', '<C-]>', omnisharp_extended.lsp_definitions, o('omnisharp_extended definition'))
	-- 	vim.keymap.set('n', 'gi', omnisharp_extended.lsp_implementation, o('omnisharp_extended implementation'))
	-- 	vim.keymap.set('n', '<leader>D', omnisharp_extended.lsp_type_definition, o('omnisharp_extended type definition'))
	-- 	-- map('n', '<leader>r', omnisharp_extended.lsp_references,      o('omnisharp_extended references'))
	-- end,
	-- handlers = { ['textDocument/definition'] = omnisharp_extended.handler },
	settings = {
		csharp = {
			inlayHints = {
				enableInlayHintsForImplicitObjectCreation = true,
				enableInlayHintsForImplicitVariableTypes = true,
				enableInlayHintsForLambdaParameterTypes = true,
				enableInlayHintsForTypes = true,
			}
		}
	},
}
