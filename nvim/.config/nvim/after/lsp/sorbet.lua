-- local basepath = os.getenv('XDG_CACHE_HOME')
-- basepath = basepath or '~/.cache'
-- local fallback_target_path = require 'util'.create_expand_path(basepath .. '/sorbet')

-- local sorbet_dir = vim.fs.root(0, { 'sorbet/config' })
local sorbet_root = vim.fs.root(0, { 'sorbet' })

---@type vim.lsp.Config
return {
	cmd = {
		'srb',
		'tc',
		'--lsp',
		'--disable-watchman',
		'--enable-experimental-lsp-document-highlight',
		'--enable-experimental-lsp-signature-help',
		'--enable-experimental-lsp-extract-to-variable',
		'--enable-all-beta-lsp-features',
	},
	cmd_cwd = sorbet_root or nil,
}
