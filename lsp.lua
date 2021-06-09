require('util')
local cmd = Util.cmd
local fn = Util.fn
local g = Util.g
local api = Util.api

local opt = Util.opt
local map = Util.map

-- Treesitter
require'nvim-treesitter.configs'.setup {
	ensure_installed = {
		'bash',
		'css',
		'html',
		'json',
		'lua',
		'python',
		'ruby',
		'typescript',
		'yaml',
	}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	highlight = { enable = true },
	incremental_selection = { enable = true },
	textobjects = { enable = true },
	indent = { enable = true },
}

---- Language Servers

-- lspinstall/lspconfig
local lua_settings = {
	Lua = {
		runtime = {
			-- LuaJIT in the case of Neovim
			version = 'LuaJIT',
			path = vim.split(package.path, ';'),
		},
		diagnostics = {
			-- Get the language server to recognize the `vim` global
			globals = {'vim'},
		},
		workspace = {
			-- Make the server aware of Neovim runtime files
			library = {
				[fn.expand('$VIMRUNTIME/lua')] = true,
				[fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
			},
		},
	}
}

local lspconfig = require('lspconfig')
local lspinstall = require'lspinstall'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

	-- Mappings.
	local opts = { noremap=true, silent=true }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	buf_set_keymap('n', '<M-r>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	buf_set_keymap('n', '<C-F12', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
	buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

	cmd([[command! Format  execute 'lua vim.lsp.buf.formatting()']])
end

-- Install missing servers
local function setup_servers()
	lspinstall.setup()

	-- Setup installed servers.
	local servers = lspinstall.installed_servers()
	for _, server in pairs(servers) do
		if server == 'lua' then
			local config = {
				settings = lua_settings,
				on_attach = on_attach,
			}
			lspconfig[server].setup(config)
		else
			lspconfig[server].setup({
				on_attach = on_attach,
			})
		end
	end
end

setup_servers()
-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
lspinstall.post_install_hook = function ()
	setup_servers() -- reload installed servers
	cmd('bufdo e') -- this triggers the FileType autocmd that starts the server
end

-- compe
opt('o', 'completeopt', 'menuone,noselect')
require'compe'.setup {
	source = {
		path = true,
		nvim_lsp = true,
		treesitter = true,
	};
}

local t = function(str)
	return api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
	local col = fn.col('.') - 1
	if col == 0 or fn.getline('.'):sub(col, col):match('%s') then
		return true
	else
		return false
	end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
	if fn.pumvisible() == 1 then
		return t '<C-n>'
	elseif check_back_space() then
		return t '<Tab>'
	else
		return fn['compe#complete']()
	end
end
_G.s_tab_complete = function()
	if fn.pumvisible() == 1 then
		return t '<C-p>'
	else
		return t '<S-Tab>'
	end
end

map('i', '<Tab>', 'v:lua.tab_complete()', {expr = true})
map('s', '<Tab>', 'v:lua.tab_complete()', {expr = true})
map('i', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
map('s', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})

cmd([[
	inoremap <silent><expr> <C-Space> compe#complete()
	inoremap <silent><expr> <CR>      compe#confirm('<CR>')
	inoremap <silent><expr> <C-e>     compe#close('<C-e>')
	inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
	inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
]])

