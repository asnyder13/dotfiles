local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api

cmd('packadd paq-nvim')
local paq = require'paq-nvim'.paq
paq {'savq/paq-nvim', opt=true}

-- Regular vim
paq 'ntpeters/vim-better-whitespace'
paq 'tpope/vim-commentary'
paq 'airblade/vim-gitgutter'
paq 'machakann/vim-highlightedyank'
paq 'sheerun/vim-polyglot'
paq 'vim-scripts/ReplaceWithRegister'
paq 'ngmy/vim-rubocop'
paq 'justinmk/vim-sneak'
paq 'kshenoy/vim-signature'
paq 'tpope/vim-surround'
paq 'tpope/vim-vinegar'
paq 'crusoexia/vim-monokai'

-- Neovim specific
paq 'norcalli/nvim-colorizer.lua'
paq 'ojroques/nvim-hardline'
paq 'phaazon/hop.nvim'
paq 'nvim-lua/plenary.nvim'
paq 'nvim-lua/popup.nvim'
paq 'nvim-telescope/telescope.nvim'

---- General Settings ----
-- thank you https://oroques.dev/notes/neovim-init/
local scopes = { o = vim.o, b = vim.bo, w = vim.wo }
local function opt(scope, key, value)
	scopes[scope][key] = value
	if scope ~= 'o' then scopes['o'][key] = value end
end

cmd([[
	" Sytaxes
	autocmd BufNewFile,BufRead *.npmrc   set syntax=dosini
	autocmd BufNewFile,BufRead *bash-fc* set syntax=sh
	" Don't auto-comment on a new line
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

	" https://github.com/jeffkreeftmeijer/vim-numbertoggle
	augroup NumberToggle
		autocmd!
		autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
		autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
	augroup END
]])

-- General
opt('o', 'clipboard', 'unnamed')
opt('w', 'number', true)
opt('w', 'cursorline', true)
opt('b', 'tabstop', 2)
opt('b', 'shiftwidth', 2)
opt('b', 'expandtab', false)
opt('b', 'autoindent', true)
opt('o', 'showmatch', true)
opt('o', 'visualbell', true)
opt('o', 'showmode', true)
opt('o', 'wildmode', 'list:longest,longest:full')
opt('o', 'scrolloff', 0)
cmd([[
	set wildignore+=*/node_modules/*
	set wildignore+=*/.git/*,*/tmp/*,*.swp
]])

opt('o', 'confirm', true)
opt('o', 'backup', false)
opt('o', 'hidden', true)
opt('o', 'history', 1000)
opt('o', 'termguicolors', true)

-- Searching
opt('o', 'hlsearch', true)
opt('o', 'ignorecase', true)
opt('o', 'smartcase', true)

-- opt('o', 'Folding', )
opt('w', 'foldmethod', 'syntax')
opt('o', 'foldlevelstart', 99)

-- Syntax hl/colors
opt('b', 'syntax', 'on')
cmd 'colorscheme monokai'
g.monokai_term_italic = true
g.monokai_gui_italic = true
cmd('set list lcs=tab:\\|\\ ')

-- Persistent Undo/Redo
if fn.has('persistent_undo') then
	local target_path = fn.expand('~/.local/share/nvim/nvim-persisted-undo/')
	if not fn.isdirectory(target_path) then
		cmd("call system('mkdir -p ' . " .. target_path .. ")")
	end

	opt('o', 'undodir', target_path)
	opt('b', 'undofile', true)
end

---- Mappings ----
-- thank you https://oroques.dev/notes/neovim-init/
local function map(mode, lhs, rhs, opts)
	local options = { noremap = true }
	if opts then options = vim.tbl_extend('force', options, opts) end
	api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Collapse all levels under current fold
map('n', 'zs', 'zCzozo', { noremap = true })
-- Quick buffer switch (for tabline)
map('n', 'gbn', ':bn<CR>', { noremap = true })
map('n', 'gbN', ':bN<CR>', { noremap = true })
map('n', 'gbd', ':bd<CR>', { noremap = true })
map('n', '<leader>b', ':ls<CR>:b', { noremap = true })

---- Plugin Settings ----
-- Vim plugins
-- netrw
g.netrw_banner = 0
g.netrw_liststyle = 3
g.netrw_browse_split = 4
g.netrw_altv = 1
g.netrw_winsize = 25
-- Sneak
cmd([[
	let g:sneak#use_ic_scs = 1
	let g:sneak#map_netrw = 1
]])
-- Highlighted yank
g.highlightedyank_highlight_duration = 500
-- Polyglot
g.ruby_recommended_style = 0
-- Signature
g.SignatureMarkTextHLDynamic = 1
-- Rubocop
map('n', '<LEADER>r', ':RuboCop <CR>')

-- Neovim plugins
require'colorizer'.setup()
require'hardline'.setup({
	bufferline = true,
	bufferline_settings = { show_index = true },
	theme = 'default'
})
-- Telescope
map('', '<C-p>', '<cmd>lua require("telescope.builtin").find_files({ hidden = true })<cr>')
-- Hop
require'hop'.setup { keys = 'abcdefgimnorstuvwxz' }
map('n', '<leader>f', "<cmd>lua require('hop').hint_char1()<CR>")
map('n', '<leader>w', "<cmd>lua require('hop').hint_words()<CR>")
