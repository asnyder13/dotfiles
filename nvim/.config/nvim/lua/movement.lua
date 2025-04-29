local Util     = require 'util'
local map      = Util.map_keys_table

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
local sneak_keys = 'hklyuiopnm,qwertzxcvbasdgjf;'
require 'hop'.setup { keys = sneak_keys }
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
-- leap.opts.labels = sneak_keys:gsub('[;,]', '')

-- Only use ;/, mappings while currently leaping.
-- https://github.com/ggandor/leap.nvim/issues/170#issuecomment-1922010218
local set_phase2_traversal_keys
do
	-- Set a counter in this closure and generate a unique autogroup
	-- each time, so that multiple key pairs can be defined (e.g. ;/,
	-- and s/S).
	local n = 0
	set_phase2_traversal_keys = function(next_key, prev_key)
		local group = ('LeapSetPhase2TraversalKeys_' .. n)
		n = n + 1
		vim.api.nvim_create_augroup(group, {})
		vim.api.nvim_create_autocmd('User', {
			pattern = 'LeapPatternPost',
			group = group,
			callback = function()
				local args = leap.state.args -- argument table passed to `leap()`
				if args['repeat'] or args.target_windows then
					return
				end
				-- Note: `require('leap').opts` would dispatch to
				-- `opts.default` (see `init.fnl`).
				local leap_opts = require('leap.opts')
				local opts = leap_opts.default
				local opts_cc = leap_opts.current_call
				if not opts_cc.special_keys then
					-- Copy the defaults - we need to keep the group switch
					-- keys - the `__index` method of `opts` will not fall
					-- back to `opts.default` for `special_keys` anymore if
					-- there is such a table in `current_call`. (And obviously
					-- deep-copy, don't overwrite the original.)
					opts_cc.special_keys = vim.deepcopy(opts.special_keys)
				end
				local cc_next = opts_cc.special_keys.next_target or {}
				local cc_prev = opts_cc.special_keys.prev_target or {}
				if (type(cc_next) == 'string') then cc_next = { cc_next } end
				if (type(cc_prev) == 'string') then cc_prev = { cc_prev } end
				table.insert(cc_next, next_key)
				table.insert(cc_prev, prev_key)
				opts_cc.special_keys.next_target = cc_next
				opts_cc.special_keys.prev_target = cc_prev
			end
		})
	end
end
set_phase2_traversal_keys(';', ',')
-- set_phase2_traversal_keys('s', 'S')
