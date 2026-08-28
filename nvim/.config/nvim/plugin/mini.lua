local Util = require 'util'
local map = Util.map_keys_table

map('n', 'gbd', function() require 'mini.bufremove'.wipeout() end, { desc = 'Buffer delete, keep window' })

require 'mini.align'.setup {}
require 'mini.ai'.setup { n_lines = 10000, }
require 'mini.diff'.setup { view = { style = 'number' }, }
require 'mini.operators'.setup {
	sort = { prefix = '<leader>gs', },
	-- exchange = { prefix = '<leader>gx' },
}
require 'mini.cmdline'.setup {
	autocomplete = { enable = false, },
	autocorrect = { enable = false, },
	autopeek = { enable = true, },
}
require 'mini.move'.setup {
	mappings = {
		-- Move visual selection in Visual mode.
		left = '<C-S-h>',
		right = '<C-S-l>',
		down = '<C-S-j>',
		up = '<C-S-k>',

		-- Move current line in Normal mode
		line_left = '<C-S-h>',
		line_right = '<C-S-l>',
		line_down = '<C-S-j>',
		line_up = '<C-S-k>',
	},
}

local block_fts = {
	'dirbuf',
	'dirvish',
	'fugitive',
	'guihua',
	'help',
	'man',
	'mason',
	'ministarter',
	'neo-tree',
	'pager',
}
vim.api.nvim_create_autocmd({ 'CursorMoved' }, {
	callback = function()
		local filetype = vim.bo.filetype
		if (vim.tbl_contains(block_fts, filetype)) then
			vim.b.minicursorword_disable = true
			return
		end

		local js_words = { 'import', 'let', 'const', 'await', }
		local block_hash = {
			lua = { 'local', 'require' },
			javascript = js_words,
			typescript = js_words,
		}

		local curword = vim.fn.expand('<cword>')
		vim.b.minicursorword_disable = not curword:match('%w') or vim.tbl_contains(block_hash[filetype] or {}, curword)
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

require 'mini.bracketed'.setup {}
require 'mini.jump'.setup {
	delay = { idle_stop = 3000, },
}


require 'mini.sessions'.setup { directory = Util.create_expand_path(vim.fn.stdpath('state') .. '/sessions/') }
local session_new = 'vim.ui.input({ prompt = "Session name: " }, MiniSessions.write)'
map('n', '<leader>qn', '<Cmd>lua ' .. session_new .. '<CR>', { desc = 'New' })
map('n', '<leader>qr', '<Cmd>lua MiniSessions.select("read")<CR>', { desc = 'Read' })
map('n', '<leader>qd', '<Cmd>lua MiniSessions.select("delete")<CR>', { desc = 'Delete' })
map('n', '<leader>qR', '<Cmd>lua MiniSessions.restart()<CR>', { desc = 'Restart' })
map('n', '<leader>qw', '<Cmd>lua MiniSessions.write()<CR>', { desc = 'Write' })

local starter = require 'mini.starter'
starter.setup {
	items = {
		starter.sections.sessions(10, false),
		starter.sections.recent_files(5, true),
		starter.sections.recent_files(10, false),
	},
	hooks = {
		pre = { save = function() vim.cmd 'ScopeSaveState' end },
		post = { load = function() vim.cmd 'ScopeLoadState' end },
	}
}
