Util = {}

Util.cmd = vim.cmd
Util.fn = vim.fn
Util.g = vim.g
Util.api = vim.api
Util.opt = vim.opt

-- thank you https://oroques.dev/notes/neovim-init/
Util.map = function (mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then options = vim.tbl_extend('force', options, opts) end
	Util.api.nvim_set_keymap(mode, lhs, rhs, options)
end

return Util
