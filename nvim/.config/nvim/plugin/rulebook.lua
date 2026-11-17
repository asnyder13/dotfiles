-- snippets to create keymaps, for your convenience
vim.keymap.set('n', '<leader>ri', function() require('rulebook').ignoreRule() end)
vim.keymap.set('n', '<leader>rl', function() require('rulebook').lookupRule() end)
vim.keymap.set('n', '<leader>ry', function() require('rulebook').yankDiagnosticCode() end)
vim.keymap.set(
	{ 'n', 'x' },
	'<leader>rf',
	function() require('rulebook').suppressFormatter() end
)

vim.api.nvim_create_autocmd('FileType', {
	pattern = { 'typescript', 'javascript' },
	group = vim.api.nvim_create_augroup('rulebook.prettify-ts-error', { clear = true }),
	callback = function(ctx)
		vim.keymap.set(
			'n',
			'<leader>rp',
			function() require('rulebook').prettifyError() end,
			{ buffer = ctx.buf }
		)
	end,
})

vim.diagnostic.config {
	virtual_text = {
		suffix = function(diag) return require('rulebook').hasDocs(diag) and '  ' or '' end,
	},
}
