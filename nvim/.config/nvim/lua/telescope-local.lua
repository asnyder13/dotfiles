local map = vim.keymap.set

-- Telescope
require 'telescope'.setup {
	defaults = {
		file_ignore_patterns = { 'node_modules', '.git', },
		layout_strategy = 'vertical',
	},
	extensions = {
		fzf = {
			fuzzy = true,                -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = 'smart_case',    -- or "ignore_case" or "respect_case" the default case_mode is "smart_case"
		}
	}
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require 'telescope'.load_extension('fzf')

map('n', '<C-p>', ':lua require("telescope.builtin").find_files({ hidden = false })<CR>', { silent = true })
map('n', '<C-M-p>', ':lua require("telescope.builtin").find_files({ hidden = true })<CR>', { silent = true })
map('n', '<C-g>', ':lua require("telescope.builtin").git_files()<CR>', { silent = true })
map('n', '<leader>b', ':lua require("telescope.builtin").buffers({ sort_mru = true, })<CR>', { silent = true })
map('n', '<M-;>', ':lua require("telescope.builtin").treesitter()<CR>', { silent = true })
map('n', '<M-g>', ':lua require("telescope.builtin").live_grep()<CR>', { silent = true })
