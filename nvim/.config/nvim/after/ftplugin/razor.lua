vim.opt_local.shiftwidth = 4
vim.opt_local.softtabstop = 4
vim.opt_local.expandtab = true
vim.defer_fn(function()
	vim.treesitter.stop()
end, 0)
