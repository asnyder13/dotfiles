local map = require 'util'.map_keys_table

local api = vim.api

local qs_opts = {
	silent = true,
	buffer = true,
}
local function q_switch(file, opts)
	return function() require('nvim-quick-switcher').switch(file, opts) end
end

-- Angular
local function angular_component_switcher_mappings(file_type)
	map('n', '<leader>u', q_switch(file_type .. '.ts', nil), qs_opts)
	map('n', '<leader>o', q_switch(file_type .. '.html', nil), qs_opts)
	map('n', '<leader>i', q_switch(file_type .. '.scss', nil), qs_opts)
	map('n', '<leader>j', q_switch(file_type .. '.spec.ts', nil), qs_opts)
	map('n', '<leader>vu', q_switch(file_type .. '.ts', { split = 'vertical' }), qs_opts)
	map('n', '<leader>vo', q_switch(file_type .. '.html', { split = 'vertical' }), qs_opts)
	map('n', '<leader>vi', q_switch(file_type .. '.scss', { split = 'vertical' }), qs_opts)
	map('n', '<leader>xu', q_switch(file_type .. '.ts', { split = 'horizontal' }), qs_opts)
	map('n', '<leader>xi', q_switch(file_type .. '.scss', { split = 'horizontal' }), qs_opts)
	map('n', '<leader>xo', q_switch(file_type .. '.html', { split = 'horizontal' }), qs_opts)
end
local function angular_ngrx_switcher_mappings()
	-- Components
	map('n', '<leader>p', q_switch('module.ts', nil), qs_opts)

	-- NgRx
	map('n', '<leader>na', q_switch('actions.ts', nil), qs_opts)
	map('n', '<leader>ne', q_switch('effects.ts', nil), qs_opts)
	map('n', '<leader>nje', q_switch('effects.spec.ts', nil), qs_opts)
	map('n', '<leader>nr', q_switch('reducer.ts', nil), qs_opts)
	map('n', '<leader>njr', q_switch('reducer.spec.ts', nil), qs_opts)
	map('n', '<leader>ns', q_switch('selector.ts', nil), qs_opts)
	map('n', '<leader>nt', q_switch('state.ts', nil), qs_opts)
	map('n', '<leader>nc', q_switch('store.ts', nil), qs_opts)
	map('n', '<leader>ncj', q_switch('store.spec.ts', nil), qs_opts)
	map('n', '<leader>ncm', q_switch('store.mock.ts', nil), qs_opts)
end
local angular_au_group = api.nvim_create_augroup('AngularQuickSwitcher', { clear = true })
local function angular_switcher_autocmd(prefix, callback)
	local patterns = { '.ts', '.html', '.scss', '.sass', }
	local computed_patterns = {}
	for _, v in ipairs(patterns) do
		table.insert(computed_patterns, prefix .. v)
	end
	api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', }, {
		group = angular_au_group,
		pattern = computed_patterns,
		callback = callback,
	})
end
angular_switcher_autocmd('*', angular_ngrx_switcher_mappings)
angular_switcher_autocmd('*.component', function() angular_component_switcher_mappings('component') end)
angular_switcher_autocmd('*.view', function() angular_component_switcher_mappings('view') end)

-- C# Saga dir patterns
local function command_to_handler(path, filename)
	return path:gsub('Commands', 'Handlers') .. '/' .. filename .. 'Handler' .. '*';
end
local function handler_to_command(path, filename)
	return path:gsub('Handlers', 'Commands') .. '/' .. filename:gsub('Handler', '') .. '*';
end
local function q_find_handler_or_command()
	return function()
		require('nvim-quick-switcher').find_by_fn(function(p)
			local path = p.path;
			local file_name = p.prefix;
			local is_handler = file_name:lower():find('handler');
			local path_func = is_handler and handler_to_command or command_to_handler;
			local result = path_func(path, file_name);
			return result;
		end)
	end
end

local cs_au_group = api.nvim_create_augroup('CsQuickSwitcher', { clear = true })
api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', }, {
	group = cs_au_group,
	pattern = { '*.cs' },
	callback = function() map('n', '<leader>ch', q_find_handler_or_command(), qs_opts) end,
})
