---@diagnostic disable: missing-fields
local map = require 'util'.map_keys_table

-- Treesitter
local langs = {
	'angular',
	'bash',
	'c_sharp',
	'css',
	'html',
	'javascript',
	'json',
	'json5',
	'lua',
	'make',
	'markdown',
	'markdown_inline',
	'ruby',
	'scss',
	'typescript',
	'xml',
	'yaml',
}
require 'nvim-treesitter'.install(langs)
vim.treesitter.language.register('bash', 'zsh')
vim.api.nvim_create_autocmd('FileType', {
	pattern = vim.tbl_extend('force', langs, { 'cs' }),
	callback = function(args)
		vim.treesitter.start(args.buf)
		if not args.match == 'yaml' then
			vim.bo[args.buf].indentexpr = "v:lua.require 'nvim-treesitter'.indentexpr()"
		end
	end
})

-- Temp fix for missing htmlangular interactions.
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'htmlangular',
	command = 'set ft=html'
})
vim.api.nvim_create_autocmd('LspAttach', {
	desc = 'Prevent ruby_lsp from loading twice',
	callback = function(event)
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and client.name == 'ruby_lsp' then
			local clients = vim.lsp.get_clients({ bufnr = event.buf, name = 'ruby_lsp' })
			if #clients > 1 then
				vim.defer_fn(function()
					vim.lsp.buf_detach_client(event.buf, client.id)
				end, 0)
			end
		end
	end
})

require 'nvim-ts-autotag'.setup {
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = true,
	}
}

require 'tiny-inline-diagnostic'.setup {
	preset = 'powerline',
	options = { multilines = { enabled = true, }, },
}
vim.diagnostic.open_float = require 'tiny-inline-diagnostic.override'.open_float

---- Language Servers
local on_attach = require 'lspconfig'
vim.lsp.config('*', {
	on_attach = on_attach,
	capabilities = vim.lsp.protocol.make_client_capabilities(),
	inlay_hints = { enabled = true },
})
require 'mason'.setup({
	registries = {
		'github:mason-org/mason-registry',
		'github:Crashdummyy/mason-registry',
	},
})
require 'mason-lspconfig'.setup {
	automatic_enable = { exclude = { 'rubocop', }, },
}


require 'fidget'.setup {}

require 'guihua.maps'.setup { maps = { close_view = '<C-c>', }, }
require 'navigator'.setup {
	on_attach = on_attach,
	default_mapping = false,
	icons = { icons = false },
	lsp = {
		enable = true,
		disable_lsp = 'all',
		code_action = { sign = false, virtual_text = false, },
		code_lens_action = { sign = false, virtual_text = false, },
		format_on_save = false,
		document_highlight = false,
		diagnostic_scrollbar_sign = false,
		diagnostic = {
			underline = true,
			virtual_text = false,
			update_in_insert = true,
		},
	},
	lsp_signature_help = false,
}

require '_cmp'

-- luasnip
require 'luasnip.loaders.from_vscode'.lazy_load()
require 'luasnip.loaders.from_snipmate'.lazy_load()

map({ 'n', 'x', 'o' }, '<leader>v', function()
	if vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()] ~= nil then
		require 'treemonkey'.select({
			ignore_injections = false,
			highlight = { backdrop = 'FloatTitle', label = 'HopNextKey1' },
		})
	else
		vim.print('TS not active for this ft (' .. vim.cmd 'set ft?' .. ')')
	end
end, { desc = 'Treemonkey' })

require 'treewalker'.setup {
	highlight_group = 'VisualNOS',
}
map('n', '<C-h>', ':Treewalker Left<CR>')
map('n', '<C-j>', ':Treewalker Down<CR>')
map('n', '<C-k>', ':Treewalker Up<CR>')
map('n', '<C-l>', ':Treewalker Right<CR>')

local lang_utils = require 'treesj.langs.utils'
local treesj_langs = {
	c_sharp = {
		argument_list = lang_utils.set_preset_for_args(),
		parameter_list = lang_utils.set_preset_for_args(),
		initializer_expression = lang_utils.set_preset_for_list(),
		element_binding_expression = lang_utils.set_preset_for_list(),
		block = lang_utils.set_preset_for_statement(),
	}
}
require 'treesj'.setup {
	max_join_length = 14720,
	use_default_keymaps = false,
	langs = treesj_langs,
}
map('n', 'gS', require 'treesj'.split)
map('n', 'gJ', require 'treesj'.join)

require 'timber'.setup {
	log_templates = {
		default = {
			javascript = [[console.dir('%log_target', %log_target)]],
			typescript = [[console.dir('%log_target', %log_target)]],
			ruby = [[ap %log_target]],
			lua = [[vim.print(%log_target)]],
		},
		plain = {
			javascript = [[console.dir('%insert_cursor')]],
			typescript = [[console.dir('%insert_cursor')]],
			ruby = [[ap %insert_cursor]],
			lua = [[vim.print(%log_target)]],
		}
	},
	batch_log_templates = {
		default = {
			javascript = [[console.dir({ %repeat<%log_target><, > })]],
			typescript = [[console.dir({ %repeat<%log_target><, > })]],
			ruby = [[ap ({ %repeat<%log_target:><, > })]],
		}
	}
}

require 'ts-error-translator'.setup { auto_attach = true, }
