vim.api.nvim_create_autocmd('LspAttach', {
	buf = 0,
	callback = function(opts)
		vim.lsp.inlay_hint.enable(false, { bufnr = opts.buf })
	end
})
