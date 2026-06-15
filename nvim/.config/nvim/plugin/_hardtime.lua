require 'hardtime'.setup {
	restriction_mode = 'hint',
	disabled_keys = {
		['<Left>'] = false,
		['<Right>'] = false,
		['<Up>'] = false,
		['<Down>'] = false,
	},
	disable_mouse = false,
	disabled_filetypes = {
		['fugitive*'] = true,
		['nvim-undotree'] = true,
	},
	hints = {
		['yyp'] = {
			message = function(keys) return 'Use gmm instead of ' .. keys end,
			length = 3,
		},
		['ggyG'] = {
			message = function(keys) return 'Use :%y+ instead of ' .. keys end,
			length = 4,
		},
		["[dcyvV][ia][%(%)]"] = {
			message = function(keys) return "Use " .. keys:sub(1, 2) .. "b instead of " .. keys end,
			length = 3,
		},
		["[dcyvV][ia][%{%}]"] = {
			message = function(keys) return "Use " .. keys:sub(1, 2) .. "B instead of " .. keys end,
			length = 3,
		},
	},
}
