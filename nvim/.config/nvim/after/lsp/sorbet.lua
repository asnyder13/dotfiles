local target_path = require 'util'.create_expand_path '~/.cache/sorbet'
---@type vim.lsp.Config
return {
	cmd = {
		'srb',
		'tc',
		'--lsp',
		'--disable-watchman',
		target_path,
	},
}
