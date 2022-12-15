require('util')
local map = Util.map

local cmd = vim.cmd
local fn  = vim.fn
local g   = vim.g
local api = vim.api
local opt = vim.opt

-- Treesitter
require'nvim-treesitter.configs'.setup {
	ensure_installed = {
		'bash',
		'c_sharp',
		'css',
		'html',
		'java',
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
require'mason'.setup()
require'mason-lspconfig'.setup()
require'mason-nvim-dap'.setup()

-- lsp_installer/lspconfig

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
	buf_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
	buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
	buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
	buf_set_keymap('n', '==', [[command! Format  execute 'lua vim.lsp.buf.formatting()']], opts)
	-- buf_set_keymap('n', '<C-]>', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

	cmd([[command! Format  execute 'lua vim.lsp.buf.formatting()']])
end

-- Setup installed servers.
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
				globals = { 'vim' },
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

local lspconfig = require'lspconfig'
require'mason-lspconfig'.setup_handlers {
	function(server_name)
		lspconfig[server_name].setup {
			on_attach = on_attach,
		}
	end,
	["sumneko_lua"] = function()
		lspconfig.sumneko_lua.setup {
			on_attach = on_attach,
			settings = custom_settings.lua,
		}
	end,
	['sorbet'] = function()
		local target_path = Util.create_expand_path('~/.cache/sorbet')
		lspconfig.sorbet.setup {
			on_attach = on_attach,
			cmd = { 'srb', 'tc', '--lsp', target_path },
		}
	end
}

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

-- DAP
local dap = require'dap'
require'nvim-dap-virtual-text'.setup()

-- dap mappings
local dap_opts = {
	silent = true,
	buffer = true,
}
vim.keymap.set('n', '<F5>',         function() return dap.continue() end, dap_opts)
vim.keymap.set('n', '<Leader><F5>', function() return dap.terminate() end, dap_opts)
vim.keymap.set('n', '<F10>',        function() return dap.step_over() end, dap_opts)
vim.keymap.set('n', '<F11>',        function() return dap.step_into() end, dap_opts)
vim.keymap.set('n', '<F12>',        function() return dap.step_out() end, dap_opts)
vim.keymap.set('n', '<Leader>db',   function() return dap.toggle_breakpoint() end, dap_opts)
vim.keymap.set('n', '<F9>',         function() return dap.toggle_breakpoint() end, dap_opts)
vim.keymap.set('n', '<Leader>dB',   function() return dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, dap_opts)
vim.keymap.set('n', '<Leader>lp',   function() return dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, dap_opts)
vim.keymap.set('n', '<Leader>dr',   function() return dap.repl.open() end, dap_opts)
vim.keymap.set('n', '<Leader>dl',   function() return dap.run_last() end, dap_opts)

require'dap-ruby'.setup()
-- re-set configs, only want one.
dap.configurations.ruby = {
	{
		type = 'ruby';
		name = 'debug current file';
		bundle = '';
		request = 'attach';
		command = "ruby";
		script = "${file}";
		port = 38698;
		server = '127.0.0.1';
		options = {
			source_filetype = 'ruby';
		};
		localfs = true;
		waiting = 1000;
	},
}

