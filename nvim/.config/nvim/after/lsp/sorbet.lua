-- local basepath = os.getenv('XDG_CACHE_HOME')
-- basepath = basepath or '~/.cache'
-- local fallback_target_path = require 'util'.create_expand_path(basepath .. '/sorbet')

local sorbet_root = vim.fs.root(0, { 'sorbet' })

---@type vim.lsp.Config
return {
	cmd = {
		'srb',
		'tc',
		'--lsp',
		'--disable-watchman',
		sorbet_root == nil and '.' or nil
	},
	cmd_cwd = sorbet_root,
}
