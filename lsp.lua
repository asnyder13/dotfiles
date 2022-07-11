require('util')
local map = Util.map

local cmd = vim.cmd
local fn = vim.fn
local g = vim.g
local api = vim.api
local opt = vim.opt

-- Treesitter
require'nvim-treesitter.configs'.setup {
	ensure_installed = {
		'bash',
		'c_sharp',
		'css',
		'html',
		'javascript',
		'json',
		'lua',
		'python',
		'ruby',
		'scss',
		'typescript',
		'yaml',
	}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	-- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
	highlight = { enable = true },
	incremental_selection = { enable = true },
	textobjects = { enable = true },
	indent = { enable = true },
}

---- Language Servers

-- lsp_installer/lspconfig

local lsp_installer = require 'nvim-lsp-installer'

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(_, bufnr)
	local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end

	-- Mappings.
	local opts = { noremap=true, silent=true }

	-- See `:help vim.lsp.*` for documentation on any of the below functions
	buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
	buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
	buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gh', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
	buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
	buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
	buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
	buf_set_keymap('n', '<M-r>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', '<M-e>', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
	buf_set_keymap('n', '<C-Space>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
	buf_set_keymap('n', '<C-F12>', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
	buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
	buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
	buf_set_keymap('n', '==', [[command! Format  execute 'lua vim.lsp.buf.formatting()']], opts)
	-- buf_set_keymap('n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

	cmd([[command! Format  execute 'lua vim.lsp.buf.formatting()']])
end

local custom_settings = {
	lua = {
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
			telemetry = { enable = false },
		}
	}
}

-- Setup installed servers.
lsp_installer.on_server_ready(function(server)
	local opts = { on_attach = on_attach }

	if server.name == 'sumneko_lua' then
		opts.settings = custom_settings.lua
	elseif server.name == 'sorbet' then
		local target_path = Util.create_expand_path('~/.cache/sorbet')
		opts.cmd = { 'srb', 'tc', '--lsp', target_path }
	end

	server:setup(opts)
end)

-- cmpe
opt.completeopt = { 'menuone', 'noselect' }
local cmp = require'cmp'
cmp.setup({
	mapping = {
		["<S-Tab>"] = cmp.mapping.select_prev_item(),
		["<Tab>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.close(),
		["<CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace }),
	},
	sources = cmp.config.sources({
		{ name = 'path' },
		{ name = 'nvim_lsp' },
		{ name = 'treesitter' },
		{ name = 'buffer' },
	})
})

-- map('i', '<Tab>', 'v:lua.tab_complete()', {expr = true})
-- map('s', '<Tab>', 'v:lua.tab_complete()', {expr = true})
-- map('i', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})
-- map('s', '<S-Tab>', 'v:lua.s_tab_complete()', {expr = true})

