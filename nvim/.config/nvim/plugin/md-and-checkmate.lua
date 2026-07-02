require 'render-markdown'.setup {
	completions = { lsp = { enabled = true }, },
	checkbox = {
		enabled = false,
		custom = {
			[' in_progress'] = { raw = '[.]', rendered = '◐', },
			[' cancelled'] = { raw = '[c]', rendered = '✗', },
			[' on_hold'] = { raw = '[/]', rendered = '⏸', },
		},
	},
}

-- local default_config = require 'checkmate.config.defaults'
-- local default_keys = default_config.keys
-- vim.print(default_keys)
require 'checkmate'.setup {
	todo_states = {
		-- Built-in states (cannot change markdown or type)
		unchecked = { marker = '□' },
		checked = { marker = '✔' },

		-- Custom states
		in_progress = {
			marker = '◐',
			markdown = '.',   -- Saved as `- [.]`
			type = 'incomplete', -- Counts as 'not done'
			order = 50,
		},
		cancelled = {
			marker = '✗',
			markdown = 'c', -- Saved as `- [c]`
			type = 'complete', -- Counts as 'done'
			order = 2,
		},
		on_hold = {
			marker = '⏸',
			markdown = '/', -- Saved as `- [/]`
			type = 'inactive', -- Ignored in counts
			order = 100,
		},
	},
	ui = { picker = 'telescope', },
	keys = {
		["<leader>tt"] = {
			rhs = "<cmd>Checkmate toggle<CR>",
			desc = "Toggle todo item",
			modes = { "n", "v" },
		},
		["<leader>tc"] = {
			rhs = "<cmd>Checkmate check<CR>",
			desc = "Set todo item as checked (done)",
			modes = { "n", "v" },
		},
		["<leader>tu"] = {
			rhs = "<cmd>Checkmate uncheck<CR>",
			desc = "Set todo item as unchecked (not done)",
			modes = { "n", "v" },
		},
		["<leader>t="] = {
			rhs = "<cmd>Checkmate cycle_next<CR>",
			desc = "Cycle todo item(s) to the next state",
			modes = { "n", "v" },
		},
		["<leader>t-"] = {
			rhs = "<cmd>Checkmate cycle_previous<CR>",
			desc = "Cycle todo item(s) to the previous state",
			modes = { "n", "v" },
		},
		["<leader>tn"] = {
			rhs = "<cmd>Checkmate create<CR>",
			desc = "Create todo item",
			modes = { "n", "v" },
		},
		["<leader>tr"] = {
			rhs = "<cmd>Checkmate remove<CR>",
			desc = "Remove todo marker (convert to text)",
			modes = { "n", "v" },
		},
		["<leader>tR"] = {
			rhs = "<cmd>Checkmate remove_all_metadata<CR>",
			desc = "Remove all metadata from a todo item",
			modes = { "n", "v" },
		},
		["<leader>ta"] = {
			rhs = "<cmd>Checkmate archive<CR>",
			desc = "Archive checked/completed todo items (move to bottom section)",
			modes = { "n" },
		},
		["<leader>tF"] = {
			rhs = "<cmd>Checkmate select_todo<CR>",
			desc = "Open a picker to select a todo from the current buffer",
			modes = { "n" },
		},
		["<leader>tv"] = {
			rhs = "<cmd>Checkmate metadata select_value<CR>",
			desc = "Update the value of a metadata tag under the cursor",
			modes = { "n" },
		},
		["<leader>t]"] = {
			rhs = "<cmd>Checkmate metadata jump_next<CR>",
			desc = "Move cursor to next metadata tag",
			modes = { "n" },
		},
		["<leader>t["] = {
			rhs = "<cmd>Checkmate metadata jump_previous<CR>",
			desc = "Move cursor to previous metadata tag",
			modes = { "n" },
		},
	}
}
