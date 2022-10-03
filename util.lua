Util = {}

-- thank you https://oroques.dev/notes/neovim-init/
Util.map = function (mode, lhs, rhs, opts)
	vim.keymap.set(mode, lhs, rhs, opts)
end

Util.create_expand_path = function (path)
	local target_path = vim.fn.expand(path)
	if not vim.fn.isdirectory(target_path) == 1 then
		vim.cmd('call system("mkdir -p " . ' .. target_path .. ')')
	end
	return target_path
end

return Util
