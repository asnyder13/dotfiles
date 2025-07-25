local map = require 'util'.map_keys_table

local api = vim.api

local qs_map_opts = function(desc)
	return {
		buffer = true,
		desc = desc or 'Switcher mapping'
	}
end
local nvim_quick_switcher = require 'nvim-quick-switcher'

---@param file string
---@param opts table
local function q_switch(file, opts)
	vim.validate('file', file, 'string')
	vim.validate('opts', opts, 'table', true)
	return function() nvim_quick_switcher.switch(file, opts) end
end

local qs_opts    = { only_existing = true, only_existing_notify = true, }
local qs_opts_vs = vim.tbl_extend('force', qs_opts, { split = 'vertical' })
local qs_opts_hs = vim.tbl_extend('force', qs_opts, { split = 'horizontal' })
---@param label string
---@param custom_fn function|nil
local qs_maps_factory = function(label, custom_fn)
	local fn = custom_fn or q_switch
	return function(lhs1, lhs2, file)
		map('n', lhs1 .. lhs2,        fn(file, qs_opts),    qs_map_opts('switcher ' .. label .. ': ' .. file))
		map('n', lhs1 .. 'v' .. lhs2, fn(file, qs_opts_vs), qs_map_opts('switcher ' .. label .. ': ' .. file))
		map('n', lhs1 .. 'x' .. lhs2, fn(file, qs_opts_hs), qs_map_opts('switcher ' .. label .. ': ' .. file))
	end
end

-- Angular
---@param file_type string
local function angular_component_switcher_mappings(file_type)
	vim.validate('file_type', file_type, 'string')
	return function()
		local maps = qs_maps_factory('ng')
		local leader = '<leader>'

		maps(leader, 'u', file_type .. '.ts')
		maps(leader, 'o', file_type .. '.html')
		maps(leader, 'i', file_type .. '.scss')
		maps(leader, 'j', file_type .. '.spec.ts')
	end
end
local function angular_ngrx_switcher_mappings()
	-- Components
	map('n', '<leader>p', q_switch('module.ts', qs_opts), qs_map_opts('switcher: module'))

	-- NgRx
	local maps = qs_maps_factory('ngrx')
	local leader = '<leader>n'
	maps(leader, 'a',  'actions.ts')
	maps(leader, 'e',  'effects.ts')
	maps(leader, 'je', 'effects.spec.ts')
	maps(leader, 'r',  'reducer.ts')
	maps(leader, 'jr', 'reducer.spec.ts')
	maps(leader, 's',  'selector.ts')
	maps(leader, 't',  'state.ts')
	maps(leader, 'c',  'store.ts')
	maps(leader, 'jc', 'store.spec.ts')
	maps(leader, 'cm', 'store.mock.ts')

	local da_map = function(file, switcher_opts)
		return function()
			nvim_quick_switcher.find_by_fn(function(p)
				local path = p.path
				local file_name = p.prefix
				local dir = vim.fn.isdirectory(path .. '/state') == 1 and '/state' or '/data-access'

				return path .. dir .. '/' .. file_name .. '*.' .. file
			end, switcher_opts)
		end
	end
	-- data-access dir
	local maps_da = qs_maps_factory('ngrx data-access', da_map)
	local da_leader = '<leader>nd'
	maps_da(da_leader, 'a', 'actions.ts')
	maps_da(da_leader, 'e', 'effects.ts')
	maps_da(da_leader, 'r', 'reducer.ts')
	maps_da(da_leader, 's', 'selector.ts')
	maps_da(da_leader, 't', 'state.ts')
	maps_da(da_leader, 'c', 'store.ts')
end

local angular_au_group = api.nvim_create_augroup('AngularQuickSwitcher', { clear = true })
---@param prefix string
---@param callback function
local function angular_switcher_autocmd(prefix, callback)
	vim.validate('prefix', prefix, 'string')
	vim.validate('callback', callback, 'function')

	local patterns = { '.ts', '.html', '.scss', '.sass', }
	local computed_patterns = vim.iter(patterns):map(function(p) return prefix .. p end):totable()
	api.nvim_create_autocmd({ 'BufReadPost', }, {
		group = angular_au_group,
		pattern = computed_patterns,
		callback = callback,
	})
end
angular_switcher_autocmd('*', angular_ngrx_switcher_mappings)
angular_switcher_autocmd('*.component', angular_component_switcher_mappings('component'))
angular_switcher_autocmd('*.module', angular_component_switcher_mappings('component'))
angular_switcher_autocmd('*.view', angular_component_switcher_mappings('view'))

api.nvim_create_autocmd({ 'BufReadPost', }, {
	group = angular_au_group,
	pattern = { 'appsettings*.json', },
	callback = function()
		map('n', '<leader>o', function()
			nvim_quick_switcher.find_by_fn(function(p)
				local file_name = ''
				if string.find(p.file_name, '%.local') then
					file_name = p.file_name:gsub('%.local', '')
				else
					file_name = p.file_name:gsub('%.json$', '.local.json')
				end
				return p.path .. '/' .. file_name
			end, qs_opts)
		end, qs_map_opts('switcher: appsettings.json'))
	end,
})

-- C# Saga dir patterns
local function command_to_handler(path, filename)
	return path:gsub('Commands', 'Handlers') .. '/' .. filename .. 'Handler' .. '*'
end
local function handler_to_command(path, filename)
	return path:gsub('Handlers', 'Commands') .. '/' .. filename:gsub('Handler', '') .. '*'
end
local function q_find_handler_or_command()
	return function()
		nvim_quick_switcher.find_by_fn(function(p)
			local path = p.path
			local file_name = p.prefix
			local is_handler = file_name:lower():find('handler')
			local path_func = is_handler and handler_to_command or command_to_handler
			local result = path_func(path, file_name)
			return result
		end)
	end
end

local cs_au_group = api.nvim_create_augroup('CsQuickSwitcher', { clear = true })
api.nvim_create_autocmd({ 'BufReadPost', }, {
	group = cs_au_group,
	pattern = { '*.cs' },
	callback = function() map('n', '<leader>ch', q_find_handler_or_command(), qs_map_opts()) end,
})

local rb_au_group = api.nvim_create_augroup('RbQuickSwitcher', { clear = true })
api.nvim_create_autocmd({ 'BufReadPost', }, {
	group = rb_au_group,
	pattern = { '*.rb' },
	callback = function()
		map('n', '<leader>o', function()
			nvim_quick_switcher.find_by_fn(function(p)
				local replace = p.prefix == 'pt1' and '/pt2' or '/pt1'
				return p.path .. replace .. '.rb'
			end, qs_opts)
		end, qs_map_opts())
	end,
})
