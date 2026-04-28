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
vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
	callback = function()
		local curword = vim.fn.expand('<cword>')
		local filetype = vim.bo.filetype

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

		vim.b.minicursorword_disable = vim.tbl_contains(block_hash[filetype] or {}, curword) or not curword:match('%w')
	end
})
require 'mini.cursorword'.setup {}

require 'mini.trailspace'.setup {}
vim.api.nvim_create_user_command('StripWhitespace', function() require 'mini.trailspace'.trim() end,
	{ desc = 'Trim trailing whitespace', })
vim.api.nvim_create_user_command('StripEmptyLastLines', function() require 'mini.trailspace'.trim_last_lines() end,
	{ desc = 'Trim trailing empty lines', })

vim.api.nvim_create_autocmd({ 'FileType' }, {
	pattern = block_fts,
	callback = function() vim.b.miniindentscope_disable = true end
})
require 'mini.indentscope'.setup {
	symbol = '│',
	n_lines = math.huge,
	draw = {
		animation = require 'mini.indentscope'.gen_animation.cubic({
			easing = 'in',
			duration = 75,
			unit = 'total'
		})
	}
}
