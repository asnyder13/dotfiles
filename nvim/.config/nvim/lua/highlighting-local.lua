local api = vim.api

local colors = require "ronny.colors"
-- for _, v in pairs(colors.syntax) do v.italic = false end
require 'ronny'.setup {
	colors = colors,
	display = { monokai_original = true },
}
vim.cmd 'colorscheme ronny'

---- Highlight changes
-- The ronny colorscheme gets colors right and has robust coverage, but with TS and LSP tokens
--   it ends up coloring literally everything and floods the brain.

-- Interface color from Visual Studio
vim.api.nvim_set_hl(0, 'Interface', { fg = '#B8D7A3' })
local highlightReLinks = {
	-- C#
	'@punctuation.bracket.c_sharp',
	'@variable.c_sharp',
	'@type.c_sharp',
	['@lsp.type.interface.cs'] = 'Interface',
	'@lsp.type.namespace.cs',
	'@lsp.type.property.cs',
	'@lsp.type.variable.cs',
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

	['NormalFloat'] = 'Normal',
	['diffAdded'] = 'Function',
	['diffRemoved'] = 'Operator',
}
for k, v in pairs(highlightReLinks) do
	-- Lua table literals auto-key w/ incrementing index when given literal values.
	if type(k) == 'number' then
		api.nvim_set_hl(0, v, { link = 'Text' })
	else
		api.nvim_set_hl(0, k, { link = v })
	end
end

local illuminateColor = { bg = '#434343' }
local highlights = { 'IlluminatedWord', 'IlluminatedCurWord', 'IlluminatedWordText', 'IlluminatedWordRead',
	'IlluminatedWordWrite' }
for _, group in ipairs(highlights) do vim.api.nvim_set_hl(0, group, illuminateColor) end
require 'illuminate'.configure {
	filetypes_denylist = {
		'dirbuf',
		'dirvish',
		'fugitive',
		'NvimTree',
		'man',
	},
}
