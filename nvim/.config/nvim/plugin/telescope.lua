local map = require 'util'.map_keys_table

-- Telescope
require 'telescope'.setup {
	defaults = {
		file_ignore_patterns = { 'node_modules', '.git', },
		layout_strategy = 'vertical',
		mappings = {
			i = {
				['<C-Down>'] = require('telescope.actions').cycle_history_next,
				['<C-Up>']   = require('telescope.actions').cycle_history_prev,
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
if not pcall(function() require 'telescope'.load_extension('fzf') end) then
	vim.notify('telescope-fzf-native is not built')
end

require 'telescope'.load_extension('luasnip')
require 'telescope'.load_extension('scope')

local builtin = require 'telescope.builtin'
map('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<C-M-p>', function() builtin.find_files({ hidden = true }) end, { desc = 'Telescope find files (hidden)' })
map('n', '<M-g>', builtin.git_files, { desc = 'Telescope git files' })
map('n', '<M-;>', builtin.treesitter, { desc = 'Telescope treesitter' })

map('n', '<leader>s:', builtin.command_history, { desc = '[S]earch [:] command history' })
map('n', '<leader>sb', builtin.current_buffer_fuzzy_find, { desc = '[S]earch [B]uffer' })
map('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
map('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
map('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
map({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
map('n', '<leader>sg', function() builtin.live_grep({ glob_pattern = { '!package-lock.json' } }) end,
	{ desc = '[S]earch by [G]rep' })
map('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
map('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
map('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
map('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
map('n', '<leader><leader>', function() builtin.buffers({ sort_mru = true }) end, { desc = 'Find existing buffers' })
