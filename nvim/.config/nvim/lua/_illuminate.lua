-- Old RRethy/vim-illuminate config
-- Kept in case I need reference again for TS-based disabling.

local api = vim.api

local illuminateColor = { bg = '#434343' }
local illuminateUnderline = { underdotted = true }
local hls = {
	['IlluminatedWord']      = illuminateUnderline,
	['IlluminatedCurWord']   = illuminateUnderline,
	['IlluminatedWordText']  = illuminateUnderline,
	['IlluminatedWordRead']  = illuminateUnderline,
	['IlluminatedWordWrite'] = illuminateUnderline,
}

---- Illuminate
require 'illuminate'.configure {
	filetypes_denylist = {
		'dirbuf',
		'dirvish',
		'fugitive',
		'neo-tree',
		'man',
		'guihua',
		'html',
	},
	delay = 250,
}

local au_group_illuminate_hold = function(lang)
	api.nvim_create_augroup('IlluminateToggleCursor_' .. lang, { clear = false })
end
--- Create toggle for Illuminate in certain languages' nested Treesitter languages.
---@param in_sublanguage_fn fun(root: TSNode): boolean
---@param lang string
---@param query string
---@return function
local function create_illuminate_toggle(in_sublanguage_fn, lang, query)
	local function toggle_illuminate_on_cursor()
		if vim.b.ill_toggle_is_setup then
			return
		else
			vim.b.ill_toggle_is_setup = true
		end

		local cursor_node = vim.treesitter.get_node()
		if cursor_node ~= nil then
			local root = cursor_node:tree():root()

			local illuminate = require 'illuminate'
			if in_sublanguage_fn(root) then
				illuminate.pause_buf()
			else
				illuminate.resume_buf()
			end
		end
	end
	return function()
		-- Check if file has inline template
		local query_result = vim.treesitter.query.parse(lang, query)
		local bufnr = vim.api.nvim_get_current_buf()

		-- Opening an empty file will throw on `:tree():root()`
		pcall(function()
			local first_node = vim.treesitter.get_node({ bufnr, pos = { 0, 0 }, lang = lang }):tree():root()
			if query_result:iter_captures(first_node, bufnr)() ~= nil then
				-- Inline template found
				api.nvim_create_autocmd({ 'CursorHold', }, {
					group = au_group_illuminate_hold(lang),
					buffer = bufnr,
					callback = toggle_illuminate_on_cursor,
				})
			end
		end)
	end
end

-- Disable illuminate when inside certain nested TS sections
local ill_cfgs = {
	typescript = {
		pattern = '*.ts',
		in_subsection_fn = function(root)
			return root:type() == 'document' or root:type() == 'fragment' or root:type() == 'program'
		end,
		query = [[
			(pair
				value: (template_string) @template_string
			)
		]]
	},
	lua = {
		pattern = '*.lua',
		in_subsection_fn = function(root) return root:type() == 'script_file' end,
		query = [[
			(string
				content: (string_content) @script_file
			)
		]]
	},
}

---- Not working
local au_group_illuminate = function(lang) api.nvim_create_augroup('IlluminateToggle_' .. lang, { clear = true }) end
for lang, cfg in pairs(ill_cfgs) do
	api.nvim_create_autocmd({ 'CursorHold' }, {
		group = au_group_illuminate(lang),
		pattern = cfg.pattern,
		callback = create_illuminate_toggle(
			cfg.in_subsection_fn,
			lang,
			cfg.query)
	})
end
