local Util = require 'util'

local colors = require 'ronny.colors'
-- autocmd to overwrite other highlight groups.  Setup before :colorscheme
vim.api.nvim_create_autocmd('ColorScheme', {
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

local illuminateUnderline = { underdotted = true }
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


	['MiniCursorword']    = illuminateUnderline,
	['LspReferenceRead']  = illuminateUnderline,
	['LspReferenceWrite'] = illuminateUnderline,
	['LspReferenceText']  = illuminateUnderline,
	['GitSignsAdd']       = { bg = 'NONE' },
	['GitSignsChange']    = { bg = 'NONE' },
	['GitSignsDelete']    = { bg = 'NONE' },
	['LineflyNormal']     = 'RedrawDebugComposed',
	['LineflyInsert']     = 'SignColumn',
	['LineflyVisual']     = 'IncSearch',
	['LineflyReplace']    = 'ExtraWhitespace',

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
	condition = function()
		local filesize = vim.fn.getfsize(vim.fn.expand('%'))
		if filesize > 250000 then
			return false
		else
			return true
		end
	end
}

-- Colors from VSCode's rainbow highlight which work well w/ monokai.
local delimColors = {
	RainbowDelimiterYellow = '#FFFF40',
	RainbowDelimiterViolet = '#FF7FFF',
	RainbowDelimiterGreen  = '#7FFF7F',
	RainbowDelimiterCyan   = '#4FECEC',
}
for k, v in pairs(delimColors) do
	vim.api.nvim_set_hl(0, k, { fg = v })
end

-- Indent Blankline
require 'ibl'.setup {
	exclude = { filetypes = { '' } },
	whitespace = {
		remove_blankline_trail = false,
	},
}
