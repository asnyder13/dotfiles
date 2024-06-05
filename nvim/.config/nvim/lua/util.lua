local Util = {}

---@param path string
function Util.create_expand_path(path)
	vim.validate {
		path = { path, { 'string', } },
	}
	local target_path = vim.fn.expand(path)
	if not vim.fn.isdirectory(target_path) == 1 then
		vim.cmd('call system("mkdir -p " . ' .. target_path .. ')')
	end
	return target_path
end

-- https://thevaluable.dev/vim-create-text-objects/
---@param char string
function Util.create_text_object(char)
	vim.validate {
		char = { char, { 'string', } },
	}
	for _, mode in ipairs { 'x', 'o' } do
		vim.api.nvim_set_keymap(
			mode,
			'i' .. char,
			string.format(':<C-u>silent! normal! f%sF%slvt%s<CR>', char, char, char),
			{ noremap = true, silent = true }
		)
		vim.api.nvim_set_keymap(
			mode,
			'a' .. char,
			string.format(':<C-u>silent! normal! f%sF%svf%s<CR>', char, char, char),
			{ noremap = true, silent = true }
		)
	end
end

---@param mode string|table    Mode short-name, see |nvim_set_keymap()|.
---                            Can also be list of modes to create mapping on multiple modes.
---@param lhs string|table     Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---
---@param opts table|nil Table of |:map-arguments|.
---                      - Same as |nvim_set_keymap()| {opts}, except:
---                        - "replace_keycodes" defaults to `true` if "expr" is `true`.
---                        - "noremap": inverse of "remap" (see below).
---                      - Also accepts:
---                        - "buffer" number|boolean Creates buffer-local mapping, `0` or `true`
---                        for current buffer.
---                        - remap: (boolean) Make the mapping recursive. Inverses "noremap".
---                        Defaults to `false`.
---                      - Defaults to `{ silent = true }`
function Util.map_keys_table(mode, lhs, rhs, opts)
	vim.validate {
		mode = { mode, { 'string', 'table' } },
		lhs = { lhs, { 'string', 'table' } },
		rhs = { rhs, { 'string', 'function' } },
		opts = { opts, { 'table', }, true },
	}
	opts = opts or { silent = true }
	if type(lhs) == 'string' then
		vim.keymap.set(mode, lhs, rhs, opts)
	else
		for _, key in ipairs(lhs) do
			vim.keymap.set(mode, key, rhs, opts)
		end
	end
end

--- HighlightGroup                => link to 'Text'
--- HighlightGroup:Highlights     => apply highlight
--- HighlightGroup:HighlightGroup => link specific group.
---
---@param idx_or_group number|string
---@param group_or_highlight string|table
function Util.highlight(idx_or_group, group_or_highlight)
	vim.validate {
		idx_or_group = { idx_or_group, { 'number', 'string' } },
		group_or_highlight = { group_or_highlight, { 'string', 'table' } },
	}

	if type(idx_or_group) == 'number' then
		-- Link to 'Text' by default
		-- Lua table literals auto-key w/ incrementing index when given literal values
		vim.api.nvim_set_hl(0, group_or_highlight, { link = 'Text' })
	elseif type(group_or_highlight) == 'table' then
		-- Apply highlight
		vim.api.nvim_set_hl(0, idx_or_group, group_or_highlight)
	elseif type(group_or_highlight) == 'string' then
		-- Link to specific group
		vim.api.nvim_set_hl(0, idx_or_group, { link = group_or_highlight })
	else
		error('Invalid type passed to Util.highlight()')
	end
end

return Util
