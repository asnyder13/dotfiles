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

local builtin = require 'telescope.builtin'
map('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
map('n', '<C-M-p>', function() builtin.find_files({ hidden = true }) end, { desc = 'Telescope find files (hidden)' })
map('n', '<M-g>', builtin.git_files, { desc = 'Telescope git files' })
map('n', '<M-;>', builtin.treesitter, { desc = 'Telescope treesitter' })

map('n', '<leader>sh', builtin.command_history, { desc = '[S]earch command [H]istory' })
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

-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
-- If you later switch picker plugins, this is where to update these mappings.
vim.api.nvim_create_autocmd('LspAttach', {
	group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
	callback = function(event)
		local buf = event.buf

		-- Find references for the word under your cursor.
		map('n', '<leader>grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

		-- Jump to the implementation of the word under your cursor.
		-- Useful when your language has ways of declaring types without an actual implementation.
		map('n', '<leader>gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

		-- Jump to the definition of the word under your cursor.
		-- This is where a variable was first declared, or where a function is defined, etc.
		-- To jump back, press <C-t>.
		map('n', '<leader>grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

		-- Fuzzy find all the symbols in your current document.
		-- Symbols are things like variables, functions, types, etc.
		map('n', '<leader>gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

		-- Fuzzy find all the symbols in your current workspace.
		-- Similar to document symbols, except searches over your entire project.
		map('n', '<leader>gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

		-- Jump to the type of the word under your cursor.
		-- Useful when you're not sure what type a variable is and you want to see
		-- the definition of its *type*, not where it was *defined*.
		map('n', '<leader>grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
	end,
})
