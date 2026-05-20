local Util = {}

---@param path string
function Util.create_expand_path(path)
	vim.validate('path', path, { 'string', })

	local target_path = vim.fn.expand(path)
	if not vim.fn.isdirectory(target_path) == 1 then
		vim.cmd('call system("mkdir -p " . ' .. target_path .. ')')
	end
	return target_path
end

---@param mode string|table    Mode short-name, see |nvim_set_keymap()|.
---                            Can also be list of modes to create mapping on multiple modes.
---@param lhs string|table     Left-hand side |{lhs}| of the mapping.
---@param rhs string|function  Right-hand side |{rhs}| of the mapping, can be a Lua function.
---
---@param opts vim.keymap.set.Opts|nil Table of |:map-arguments|.
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
	vim.validate('mode', mode, { 'string', 'table' })
	vim.validate('lhs', lhs, { 'string', 'table' })
	vim.validate('rhs', rhs, { 'string', 'function', 'nil' })
	vim.validate('opts', opts, { 'table', }, true)

	opts = vim.tbl_extend('force', { silent = true, noremap = true, }, opts or {})
	if not rhs then return end

	if type(lhs) == 'string' then
		vim.keymap.set(mode, lhs, rhs, opts)
	else
		for _, key in ipairs(lhs) do
			vim.keymap.set(mode, key, rhs, opts)
		end
	end
end

--- HighlightGroup                => link to 'Text'
--- HighlightGroup:Highlights     => merge existing highlight
--- HighlightGroup:HighlightGroup => link specific group.
---
---@param group number|string
---@param group_or_highlight string|table
function Util.highlight(group, group_or_highlight)
	vim.validate('group', group, { 'number', 'string' })
	vim.validate('group_or_highlight', group_or_highlight, { 'string', 'table' })

	if type(group) == 'number' then
		-- Link to 'Text' by default
		-- Lua table literals auto-key w/ incrementing index when given literal values
		vim.api.nvim_set_hl(0, group_or_highlight, { link = 'Text' })
	elseif type(group_or_highlight) == 'table' then
		-- Merge with existing highlight highlight
		local existing_hl = vim.api.nvim_get_hl(0, { name = group })
		local merged_hl = vim.tbl_deep_extend('force', existing_hl, group_or_highlight)
		vim.api.nvim_set_hl(0, group, merged_hl)
	elseif type(group_or_highlight) == 'string' then
		-- Link to specific group
		vim.api.nvim_set_hl(0, group, { link = group_or_highlight })
	else
		error('Invalid type passed to Util.highlight()')
	end
end

--- Run a command then center cursor on screen.
---@param func function
---@return unknown
function Util.run_then_center_cursor(func)
	local res = func()
	vim.cmd 'normal! zz'
	return res
end

--- Function to run a command then center cursor on screen.
---@param func function
---@return function
function Util.run_then_center_cursor_func(func)
	return function() Util.run_then_center_cursor(func) end
end

local ftset_augroup = vim.api.nvim_create_augroup('FTSet', { clear = true })
--- Create autocmd to set ft on files that filetype.add doesn't work for.
---@param pattern string
---@param ft string
function Util.ftset(pattern, ft)
	vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNewFile' }, {
		group = ftset_augroup,
		pattern = pattern,
		command = 'set ft=' .. ft,
	})
end

--- Get the first ancestor node of certain type.
---@param type string
---@param node? TSNode
---@return nil|TSNode
function Util.get_node_type_ancestor(type, node)
	node = node or vim.treesitter.get_node()

	while node ~= nil and node:type() ~= type do
		node = node:parent()
	end
	return node
end

--- Get a field from the first ancestor node of certain type.
---@param type string
---@param field_name string
---@param node? TSNode
---@return nil|string
function Util.get_ancestor_field(type, field_name, node)
	node = node or vim.treesitter.get_node()

	local node = Util.get_node_type_ancestor(type, node)
	if node == nil then return nil end

	local name_nodes = node:field(field_name)
	if name_nodes and #name_nodes > 0 then
		return vim.treesitter.get_node_text(name_nodes[1], 0)
	end
end

return Util
