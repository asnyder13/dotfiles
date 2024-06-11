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

	['LspReferenceRead'] = illuminateColor,
	['LspReferenceWrite'] = illuminateColor,
	['LspReferenceText'] = illuminateColor,

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
