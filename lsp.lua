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

-- Install missing servers
local function setup_servers()
	local lspinstall = require'lspinstall'
	lspinstall.setup()

	local required_servers = {
		'bash',
		'css',
		'html',
		'json',
		'lua',
		'ruby',
		'typescript',
		'yaml',
	}
	local installed_servers = lspinstall.installed_servers()
	for _, server in pairs(required_servers) do
		if not vim.tbl_contains(installed_servers, server) then
			lspinstall.install_server(server)
		end
	end

	local servers = lspinstall.installed_servers()
	for _, server in pairs(servers) do
		if server == 'lua' then
			local config = {}
			config.settings = lua_settings
			require'lspconfig'[server].setup(config)
		else
			require'lspconfig'[server].setup({})
		end
	end
end

setup_servers()
-- Automatically reload after `:LspInstall <server>` so we don't have to restart neovim
require'lspinstall'.post_install_hook = function ()
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
