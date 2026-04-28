local map = require 'util'.map_keys_table

map('n', 'gbd', function() require 'mini.bufremove'.wipeout() end, { desc = 'Buffer delete, keep window' })

require 'mini.align'.setup {}
require 'mini.ai'.setup { n_lines = 10000, }
require 'mini.diff'.setup { view = { style = 'number' }, }
require 'mini.operators'.setup { sort = { prefix = '<leader>gs', }, }
require 'mini.cmdline'.setup {
	autocomplete = { enable = false, },
	autocorrect = { enable = false, },
	autopeek = { enable = true, },
}
vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
	callback = function()
		local curword = vim.fn.expand('<cword>')
		local filetype = vim.bo.filetype

		local block_fts = {
			'dirbuf',
			'dirvish',
			'fugitive',
			'neo-tree',
			'man',
			'guihua',
			'html',
			'pager',
		}
		if (vim.tbl_contains(block_fts, filetype)) then
			vim.b.minicursorword_disable = true
			return
		end

		local js_words = {
			'import',
			'let',
			'const',
		}
		local block_hash = {
			lua = { 'local', 'require' },
			javascript = js_words,
			typescript = js_words,
		}

		vim.b.minicursorword_disable = vim.tbl_contains(block_hash[filetype] or {}, curword)
	end
})
require 'mini.cursorword'.setup { delay = 250, }
