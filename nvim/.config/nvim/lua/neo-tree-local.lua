local map = require 'util'.map_keys_table

---- Neo tree
-- Window picker, used for neo-tree and some own hotkeys.
require 'window-picker'.setup {
	filter_rules = {
		include_current_win = true,
		autoselect_one = true,
		-- filter using buffer options
		bo = {
			-- if the file type is one of following, the window will be ignored
			filetype = { 'neo-tree', 'neo-tree-popup', 'notify' },
			-- if the buffer type is one of following, the window will be ignored
			buftype = { 'terminal', 'quickfix' },
		},
	}
}
local openWindowPicker = function()
	local picked_window_id = require 'window-picker'.pick_window()
	if picked_window_id ~= nil then
		vim.fn.win_gotoid(picked_window_id)
	end
end
map('n', { '<C-w><C-e>', '<C-w>e' }, openWindowPicker)

require 'neo-tree'.setup {
	filesystem = {
		hijack_netrw_behavior = 'open_default',
		follow_current_file = {
			enabled = true,
			leave_dirs_open = true,
		}
	},
	add_blank_line_at_top = false,
	window = {
		mappings = {
			['s'] = 'open_split',
			['S'] = 'open_vsplit',
			['x'] = 'split_with_window_picker',
			['v'] = 'vsplit_with_window_picker',
			['<C-x>'] = 'cut_to_clipboard',
			['<C-c>'] = 'clear_filter',
			['-'] = 'navigate_up',
		},
		width = 40
	},
	event_handlers = { {
		event = 'neo_tree_buffer_enter',
		handler = function()
			vim.cmd [[
				setlocal number
				setlocal relativenumber
			]]
		end,
	} },
	nesting_rules = {
		['package.json'] = {
			pattern = '^package%.json$',
			files = { 'package-lock.json', 'yarn*' },
		},
		['tsconfig'] = {
			pattern = '^tsconfig%.json$',
			files = { 'tsconfig.*.json' },
		},
		['js-extended'] = {
			pattern = '(.+)%.js$',
			files = { '%1.js.map', '%1.min.js', '%1.d.ts' },
		},
		['jsx'] = { 'js' },
		['tsx'] = { 'ts' },
		['ts-tests'] = {
			pattern = '(.+)%.ts',
			files = { '%1.spec.ts', '%1.mock.ts' },
		},
		['appsettings'] = {
			pattern = '^appsettings%.json$',
			files = { 'appsettings.*.json' },
		},
	}
}
map('n', '-', ':Neotree<CR>', { silent = true })
map('n', '<M-->', ':Neotree toggle<CR>', { silent = true })
