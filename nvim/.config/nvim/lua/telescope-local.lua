local map = require 'util'.map_keys_table

-- Telescope
require 'telescope'.setup {
	defaults = {
		file_ignore_patterns = { 'node_modules', '.git', },
		layout_strategy = 'vertical',
		mappings = {
			i = {
				["<C-Down>"] = require('telescope.actions').cycle_history_next,
				["<C-Up>"]   = require('telescope.actions').cycle_history_prev,
			},
		}
	},
	extensions = {
		fzf = {
			fuzzy = true,                -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = 'smart_case',    -- or "ignore_case" or "respect_case" the default case_mode is "smart_case"
		}
	},
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require 'telescope'.load_extension('fzf')

local builtin = require 'telescope.builtin'
map('n', '<C-p>',      function() builtin.find_files({ hidden = false }) end, { desc = 'Telescope find files' })
map('n', '<C-M-p>',    function() builtin.find_files({ hidden = true }) end,  { desc = 'Telescope find files (hidden)' })
map('n', '<C-g>',      function() builtin.git_files() end,                    { desc = 'Telescope git files' })
map('n', '<leader>b',  function() builtin.buffers({ sort_mru = true, }) end,  { desc = 'Telescope buffers' })
map('n', '<M-;>',      function() builtin.treesitter() end,                   { desc = 'Telescope treesitter' })
map('n', '<M-g>',      function() builtin.live_grep() end,                    { desc = 'Telescope live grep' })
map('n', 'q/',         function() builtin.command_history() end,              { desc = 'Telescope command history' })
map('n', '<leader>z=', function() builtin.spell_suggest() end,                { desc = 'Telescope spell suggest' })
