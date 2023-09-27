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

-- https://thevaluable.dev/vim-create-text-objects/
Util.create_text_object = function (char)
	for _,mode in ipairs({ 'x', 'o' }) do
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

return Util
