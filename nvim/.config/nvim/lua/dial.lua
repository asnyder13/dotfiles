local map = require 'util'.map_keys_table

local dial_map = require('dial.map')
map('n', '<C-a>', function()
	dial_map.manipulate('increment', 'normal')
end)
map('n', '<C-x>', function()
	dial_map.manipulate('decrement', 'normal')
end)
map('n', 'g<C-a>', function()
	dial_map.manipulate('increment', 'gnormal')
end)
map('n', 'g<C-x>', function()
	dial_map.manipulate('decrement', 'gnormal')
end)
map('x', '<C-a>', function()
	dial_map.manipulate('increment', 'visual')
end)
map('x', '<C-x>', function()
	dial_map.manipulate('decrement', 'visual')
end)
map('x', 'g<C-a>', function()
	dial_map.manipulate('increment', 'gvisual')
end)
map('x', 'g<C-x>', function()
	dial_map.manipulate('decrement', 'gvisual')
end)

local dial_config = require('dial.config')
local augend = require('dial.augend')

---@param keys table
---@param word nil|boolean
local function cycle(keys, word)
	if type(word) ~= 'boolean' then
		word = true
	end

	return augend.constant.new {
		elements = keys,
		word = word, -- if false, 'sand' is incremented into 'sor', 'doctor' into 'doctand', etc.
		cyclic = true, -- 'or' is incremented into 'and'.
	}
end

local default = {
	-- Defaults
	augend.integer.alias.hex,
	augend.date.alias['%Y/%m/%d'],
	augend.date.alias['%Y-%m-%d'],
	augend.date.alias['%m/%d'],
	augend.date.alias['%H:%M'],

	augend.integer.alias.decimal_int,
	augend.constant.alias.en_weekday,
	augend.constant.alias.en_weekday_full,
	augend.constant.alias.bool,
	augend.constant.alias.Bool,
	cycle({ 'and', 'or' }),
	cycle({ '&&', '||' }, false),
	cycle({ '===', '!==' }, false),
	cycle({ '==', '!=' }, false),
	cycle({ '+=', '-=' }, false),
	cycle({ '++', '--' }, false),
}
dial_config.augends:register_group { default = default, }

---@param custom Augend[]
local function default_and(custom) return vim.tbl_extend('force', default, custom) end
dial_config.augends:on_filetype {
	ruby = default_and {
		cycle({ 'if', 'unless' }),
		cycle({ 'while', 'until' }),
		cycle({ '..', '...' }, false),
	},
	lua = default_and {
		cycle({ '==', '~=' }, false)
	},
	html = default_and {
		cycle({ 'start', 'end', 'center', 'baseline', 'between', 'around', }),
	},
}
