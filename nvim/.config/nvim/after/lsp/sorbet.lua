local basepath = os.getenv('XDG_CACHE_HOME')
basepath = basepath or '~/.cache'
local fallback_target_path = require 'util'.create_expand_path(basepath .. '/sorbet')

---@type nil|string
local sorbet_loc = require 'lspconfig.util'.root_pattern('sorbet/config')(vim.fn.getcwd())

---@type vim.lsp.Config
return {
	cmd = {
		'srb',
		'tc',
		'--lsp',
		'--disable-watchman',
		sorbet_loc or fallback_target_path,
	},
}
