local Util = require 'util'
local map  = Util.map_keys_table

vim.cmd [[
	nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
	nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
]]
map('n', 'gj', 'j')
map('n', 'gk', 'k')

vim.g.lasttab = 1
vim.api.nvim_create_autocmd('TabLeave', { callback = function() vim.g.lasttab = vim.api.nvim_get_current_tabpage() end })
map('n', '<C-BS>', function() vim.api.nvim_set_current_tabpage(vim.g.lasttab) end, { desc = 'Last tab' })

-- https://old.reddit.com/r/neovim/comments/1abd2cq/what_are_your_favorite_tricks_using_neovim/
-- Jump to last edit position on opening file
vim.cmd [[
	au BufReadPost * if expand('%:p') !~# '\m/\.git/' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
]]

local spider_map = function(key)
	map(
		{ 'n', 'o', 'x' },
		key,
		function() require('spider').motion(key) end,
		{ desc = 'Spider-' .. key }
	)
end
spider_map('w')
spider_map('e')
spider_map('b')

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

require 'fix-auto-scroll'.setup()

-- Hop & Leap
local hop_keys = 'hklyuiopnm,qwertzxcvbasdgj;'

require 'hop'.setup { keys = hop_keys }
map('n', '<leader>f', '<Esc> :lua require("hop").hint_char1()<CR>', { desc = 'Hop 1 char' })
map('n', '<leader>w', '<Esc> :lua require("hop").hint_words()<CR>', { desc = 'Hop words' })

local leap = require 'leap'
leap.set_default_mappings()
map({ 'n', 'o', }, 's', '<Plug>(leap-forward)')
map({ 'x', }, 's', '<Plug>(leap)')
map({ 'n', 'o', }, 'S', '<Plug>(leap-backward)')
map({ 'n', 'o', }, 'gs', '<Plug>(leap-from-window)')
leap.opts.preview_filter =
		function(ch0, ch1, ch2)
			return not (
				ch1:match('%s') or
				ch0:match('%a') and ch1:match('%a') and ch2:match('%a')
			)
		end
leap.opts.safe_labels = 'uopnm,qwertzvbs;HKLYUIOPNMQWERTZXCVBASDGJ'
leap.opts.labels = hop_keys .. hop_keys:upper()

