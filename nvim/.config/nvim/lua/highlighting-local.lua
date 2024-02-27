local api = vim.api

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

-- Interface color from Visual Studio
vim.api.nvim_set_hl(0, 'Interface', { fg = '#B8D7A3' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
vim.api.nvim_set_hl(0, 'TelescopeBorder', { fg = '#808080' })
local highlightReLinks = {
	---- General
	['FloatBorder'] = 'SpecialComment',
	['NormalFloat'] = 'Normal',
	['diffAdded'] = 'Function',
	['diffRemoved'] = 'Operator',

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
	local first_node = vim.treesitter.get_node({ bufnr, pos = { 0, 0 }, lang = 'typescript' }):tree():root()

	if query:iter_captures(first_node, bufnr)() ~= nil then
		-- Inline template found
		api.nvim_create_autocmd({ 'CursorHold', }, {
			group = au_group_angular_illuminate,
			buffer = bufnr,
			callback = toggle_illuminate_on_cursor,
		})
	end
end

-- Disable illuminate when inside an angular inline template.
api.nvim_create_autocmd({ 'BufReadPost' }, {
	group = au_group_angular_illuminate,
	pattern = '*.ts',
	callback = check_if_file_has_angular_inline
})
