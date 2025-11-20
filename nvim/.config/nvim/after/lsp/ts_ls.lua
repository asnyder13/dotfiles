---@type vim.lsp.Config
return {
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
