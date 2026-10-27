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

	local cs = vim.bo.commentstring
	if not cs or cs == '' or not cs:find('%%s') then
		return
	end

	local s_row = vim.api.nvim_buf_get_mark(0, '[')[1] - 1
	local e_row = vim.api.nvim_buf_get_mark(0, ']')[1]
	if is_line then
		local lines = vim.api.nvim_buf_get_lines(0, s_row, e_row, false)
		local commented_lines = {}

		for _, line in ipairs(lines) do
			if line:match('^%s*$') then
				table.insert(commented_lines, line)
			else
				local indent, content = line:match('^(%s*)(.*)$')
				local commented = string.format(cs, content)
				table.insert(commented_lines, indent .. commented)
			end
		end

		vim.api.nvim_buf_set_lines(0, s_row, s_row, false, commented_lines)
	else
		local text = vim.fn.getregion(
			vim.fn.getpos("'<"),
			vim.fn.getpos("'>"),
			{ type = "\22" }
		)

		-- Keep line indent
		local line_text = vim.api.nvim_buf_get_lines(0, s_row, s_row + 1, false)
		local indent = ''
		if #line_text > 0 then
			indent = line_text[1]:match('^(%s*).*$')
		end

		local commented_text = vim.iter(text):map(function(line)
			return indent .. string.format(cs, line)
		end):totable()

		vim.api.nvim_buf_set_lines(0, s_row, s_row, false, commented_text)
	end
end
