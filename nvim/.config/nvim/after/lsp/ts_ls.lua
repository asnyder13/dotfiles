---@type vim.lsp.Config
return {
	handlers = {
		['textDocument/publishDiagnostics'] = function(err, result, ctx)
			require 'ts-error-translator'.translate_diagnostics(err, result, ctx)
			vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx)
		end
	},
	settings = {
		typescript = {
			inlayHints = {
				includeInlayParameterNameHints = 'literals', -- 'none' | 'literals' | 'all'
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayVariableTypeHints = false,
				includeInlayFunctionParameterTypeHints = false,
				includeInlayVariableTypeHintsWhenTypeMatchesName = false,
				includeInlayPropertyDeclarationTypeHints = false,
				includeInlayFunctionLikeReturnTypeHints = false,
				includeInlayEnumMemberValueHints = true,
			},
		},
		javascript = {
			inlayHints = {
				includeInlayParameterNameHints = 'literals', -- 'none' | 'literals' | 'all'
				includeInlayParameterNameHintsWhenArgumentMatchesName = false,
				includeInlayVariableTypeHints = false,

				includeInlayFunctionParameterTypeHints = false,
				includeInlayVariableTypeHintsWhenTypeMatchesName = false,
				includeInlayPropertyDeclarationTypeHints = false,
				includeInlayFunctionLikeReturnTypeHints = false,
				includeInlayEnumMemberValueHints = true,
			},
		},
	},
}
