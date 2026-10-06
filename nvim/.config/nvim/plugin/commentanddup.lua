local Util = require 'util'
local map  = Util.map_keys_table

map('n', 'yc', function()
	vim.go.operatorfunc = 'v:lua.commentanddup'
	return 'g@'
end, { desc = 'Comment and duplicate', expr = true, remap = true, })
map('n', 'ycc', function()
	vim.go.operatorfunc = 'v:lua.commentanddup'
	return 'g@' .. vim.v.count1 .. '_'
end, { desc = 'Comment and duplicate', remap = true, expr = true, })
map('x', 'yc', function()
	vim.go.operatorfunc = 'v:lua.commentanddup'
	return 'g@'
end, { desc = 'Comment and duplicate', remap = true, expr = true, })

---@diagnostic disable-next-line: duplicate-set-field
_G.commentanddup = function(type)
	local is_line = (type == 'line')
	-- print(string.format("is_line=%s, type=%s", is_line, type))
	local start_pos = vim.api.nvim_buf_get_mark(0, '[')
	local end_pos = vim.api.nvim_buf_get_mark(0, ']')

	local cs = vim.bo.commentstring
	if not cs or cs == '' or not cs:find('%%s') then
		return
	end

	if is_line then
		local start_row = start_pos[1]
		local end_row = end_pos[1]
		local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

		local commented_lines = {}
		local last_indent = 0
		for _, line in ipairs(lines) do
			if line:match('^%s*$') then
				table.insert(commented_lines, line)
			else
				local indent, content = line:match('^(%s*)(.*)$')
				last_indent = #indent
				local commented = string.format(cs, content)
				table.insert(commented_lines, indent .. commented)
			end
		end

		vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, commented_lines)
		vim.api.nvim_buf_set_lines(0, end_row, end_row, false, lines)
		vim.api.nvim_win_set_cursor(0, { end_row + 1, last_indent })
	end
end
