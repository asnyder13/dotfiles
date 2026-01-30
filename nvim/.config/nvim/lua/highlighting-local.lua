local api = vim.api
local Util = require 'util'

local colors = require "ronny.colors"
-- autocmd to overwrite other highlight groups.  Setup before :colorscheme
api.nvim_create_autocmd('ColorScheme', {
	pattern = '*',
	command = [[
			highlight Normal guibg=#282923
			highlight LineNr guibg=#282923
			highlight CursorLineNr guibg=#434343
			highlight IblScope guifg=#b2b2b2
			highlight TabLineFill guibg=#282923
		]]
})

require 'ronny'.setup {
	colors = colors,
	display = { monokai_original = true },
}
vim.cmd.colorscheme 'ronny'

---- Highlight changes
-- The ronny colorscheme gets colors right and has robust coverage, but with TS and LSP tokens
--   it ends up coloring literally everything and floods the brain.

local illuminateColor = { bg = '#434343' }
local hls = {
	---- General
	['Interface']       = { fg = '#B8D7A3' }, -- Interface color from Visual Studio
	['SignColumn']      = { bg = 'NONE' },
	-- Use bg from 'ReactiveVisual@preset.cursorline.@mode.V', just linking would make text white
	['VisualNonText']   = { fg = '#5D5F71', bg = '#3b0764' },
	['StatusLine']      = { fg = '#dddddd', bg = '#560707' },

	['TelescopeBorder'] = { fg = '#eeeeee', bg = 'NONE' },
	['DiffText']        = { bold = true, fg = 'NONE', bg = '#393939', },
	['diffAdded']       = 'Function',
	['diffRemoved']     = 'Operator',
	['LeapBackdrop']    = 'Comment',
	'MarkSignNumHL',


	['IlluminatedWord']      = illuminateColor,
	['IlluminatedCurWord']   = illuminateColor,
	['IlluminatedWordText']  = illuminateColor,
	['IlluminatedWordRead']  = illuminateColor,
	['IlluminatedWordWrite'] = illuminateColor,
	['LspReferenceRead']     = illuminateColor,
	['LspReferenceWrite']    = illuminateColor,
	['LspReferenceText']     = illuminateColor,
	['GitSignsAdd']          = { bg = 'NONE' },
	['GitSignsChange']       = { bg = 'NONE' },
	['GitSignsDelete']       = { bg = 'NONE' },
	['LineflyNormal']        = 'RedrawDebugComposed',
	['LineflyInsert']        = 'SignColumn',
	['LineflyVisual']        = 'IncSearch',
	['LineflyReplace']       = 'ExtraWhitespace',

	---- Languages
	-- C#
	'@punctuation.bracket.c_sharp',
	'@variable.c_sharp',
	'@type.c_sharp',
	['@lsp.type.interface.cs'] = 'Interface',
	'@lsp.type.namespace.cs',
	'@lsp.type.property.cs',
	'@lsp.type.variable.cs',
	'@lsp.type.parameter.cs',
	-- Lua
	'@field.lua',
	'@variable.lua',
	'@variable.member.lua',
	'@lsp.type.property.lua',
	'@lsp.type.variable.lua',
	-- Ruby
	'@variable.ruby',
	'@lsp.type.variable.ruby',
	['@string.special.symbol.ruby'] = 'Number',
	-- TS
	'@property.typescript',
	'@variable.typescript',
	'@variable.member.typescript',
	'@lsp.type.property.typescript',
	'@lsp.type.variable.typescript',
	['@variable.builtin.typescript'] = 'SpecialComment',
	'typescriptVariableDeclaration',
}
vim.iter(hls):each(Util.highlight)

-- Unset LSP highlighting
vim.api.nvim_set_hl(0, '@lsp.type.keyword.cs', {})

---- Illuminate
require 'illuminate'.configure {
	filetypes_denylist = {
		'dirbuf',
		'dirvish',
		'fugitive',
		'neo-tree',
		'man',
		'guihua',
	},
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

		local cursor_node = require 'nvim-treesitter.ts_utils'.get_node_at_cursor()
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
		in_subsection_fn = function(root) return root:type() == 'document' or root:type() == 'fragment' end,
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
-- local au_group_illuminate = function(lang) api.nvim_create_augroup('IlluminateToggle_' .. lang, { clear = true }) end
-- for lang, cfg in pairs(ill_cfgs) do
-- 	api.nvim_create_autocmd({ 'CursorHold' }, {
-- 		group = au_group_illuminate(lang),
-- 		pattern = cfg.pattern,
-- 		callback = create_illuminate_toggle(
-- 			cfg.in_subsection_fn,
-- 			lang,
-- 			cfg.query)
-- 	})
-- end


vim.g.rainbow_delimiters = {
	strategy = {
		[''] = 'rainbow-delimiters.strategy.global',
	},
	priority = {
		[''] = 110,
		-- lua = 210,
	},
	highlight = {
		'RainbowDelimiterYellow',
		'RainbowDelimiterViolet',
		'RainbowDelimiterGreen',
	},
	blacklist = {
		'c_sharp',
	},
	query = {
		[''] = 'rainbow-delimiters',
		latex = 'rainbow-blocks',
		query = 'rainbow-blocks',
	},
}

-- Colors from VSCode's rainbow highlight which work well w/ monokai.
local delimColors = {
	RainbowDelimiterYellow = '#FFFF40',
	RainbowDelimiterViolet = '#FF7FFF',
	RainbowDelimiterGreen  = '#7FFF7F',
	RainbowDelimiterCyan   = '#4FECEC',
}
for k, v in pairs(delimColors) do
	api.nvim_set_hl(0, k, { fg = v })
end
