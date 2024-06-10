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
	['Interface'] = { fg = '#B8D7A3' }, -- Interface color from Visual Studio
	['SignColumn'] = { bg = 'NONE' },
	['TelescopeBorder'] = { fg = '#eeeeee' },
	['DiffText'] = { bold = true, fg = 'NONE', bg = '#393939', },
	['diffAdded'] = 'Function',
	['diffRemoved'] = 'Operator',

	['IlluminatedWord'] = illuminateColor,
	['IlluminatedCurWord'] = illuminateColor,
	['IlluminatedWordText'] = illuminateColor,
	['IlluminatedWordRead'] = illuminateColor,
	['IlluminatedWordWrite'] = illuminateColor,

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

---- Illuminate
require 'illuminate'.configure {
	filetypes_denylist = {
		'dirbuf',
		'dirvish',
		'fugitive',
		'NvimTree',
		'man',
	},
}

local function toggle_illuminate_on_cursor()
	local cursor_node = require 'nvim-treesitter.ts_utils'.get_node_at_cursor()
	if cursor_node ~= nil then
		local root = cursor_node:tree():root()

		local illuminate = require 'illuminate'
		if root:type() == 'document' or root:type() == 'fragment' then
			illuminate.pause_buf()
		else
			illuminate.resume_buf()
		end
	end
end

local au_group_angular_illuminate = api.nvim_create_augroup('AngularIlluminateToggle', { clear = true })
local function check_if_file_has_angular_inline()
	-- Check if file has inline template
	local query = vim.treesitter.query.parse('typescript', [[
		(pair
			value: (template_string) @template_string
		)
	]])
	local bufnr = vim.api.nvim_get_current_buf()

	-- Opening a blank .ts file will throw on `:tree():root()`
	pcall(function()
		local first_node = vim.treesitter.get_node({ bufnr, pos = { 0, 0 }, lang = 'typescript' }):tree():root()
		if query:iter_captures(first_node, bufnr)() ~= nil then
			-- Inline template found
			api.nvim_create_autocmd({ 'CursorHold', }, {
				group = au_group_angular_illuminate,
				buffer = bufnr,
				callback = toggle_illuminate_on_cursor,
			})
		end
	end)
end

-- Disable illuminate when inside an angular inline template.
api.nvim_create_autocmd({ 'BufReadPost' }, {
	group = au_group_angular_illuminate,
	pattern = '*.ts',
	callback = check_if_file_has_angular_inline
})

vim.g.rainbow_delimiters = {
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
		lua = 'rainbow-blocks',
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
