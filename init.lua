local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api

cmd([[
	set runtimepath^=~/.vim runtimepath+=~/.vim/after
	let &packpath = &runtimepath
	source ~/.vimrc
]])

cmd([[
	" guard for distributions lacking the persistent_undo feature.
	if has('persistent_undo')
		" define a path to store persistent_undo files.
		let target_path = expand('~/.local/share/nvim/nvim-persisted-undo/')

		" create the directory and any parent directories
		" if the location does not exist.
		if !isdirectory(target_path)
			call system('mkdir -p ' . target_path)
		endif

		" point Vim to the defined undo directory.
		let &undodir = target_path

		" finally, enable undo persistence.
		set undofile
	endif
]])

require('colorizer').setup()
require('hardline').setup({
	bufferline = true,
	bufferline_settings = {
		show_index = true
	},
	theme = 'default'
})

-- Mappings
local function map(mode, lhs, rhs, opts)
	local options = {noremap = true}
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Telescope
map('', '<C-p>', '<cmd>lua require("telescope.builtin").find_files({hidden = true})<cr>')
-- Hop
map('n', '<leader>f', "<cmd>lua require('hop').hint_char1()<CR>")
map('n', '<leader>w', "<cmd>lua require('hop').hint_words()<CR>")
