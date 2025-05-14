---@diagnostic disable: missing-fields
local map = require 'util'.map_keys_table

local opt = vim.opt

-- Treesitter
require 'nvim-treesitter.configs'.setup {
	ensure_installed = {
		'angular',
		'bash',
		'c_sharp',
		'css',
		'html',
		'javascript',
		'json',
		'json5',
		'lua',
		'ruby',
		'scss',
		'typescript',
		'yaml',
	}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
	-- If TS highlights are not enabled at all, or disabled via `disable` prop, highlighting will fallback to default Vim syntax highlighting
	highlight = { enable = true },
	incremental_selection = { enable = true },
	textobjects = { enable = true },
	indent = { enable = true, disable = { 'ruby', 'markdown', } },
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	endwise = { enable = true, },
}
vim.treesitter.language.register('bash', 'zsh')

-- Temp fix for missing htmlangular interactions.
vim.api.nvim_create_autocmd('FileType', {
	pattern = 'htmlangular',
	command = 'set ft=html'
})

require 'nvim-ts-autotag'.setup {
	opts = {
		enable_close = true,
		enable_rename = true,
		enable_close_on_slash = true,
	}
}

-- Only show errors as diag lines
local virt_text_cfg  = { severity = { max = vim.diagnostic.severity.WARN, }, }
local virt_lines_cfg = { severity = { min = vim.diagnostic.severity.ERROR, }, }
-- Toggle between errors as diag lines and text
map('n', '<leader>td', function()
	local curr_virt_lines = vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({
		virtual_text = not curr_virt_lines and virt_text_cfg or true,
		virtual_lines = not curr_virt_lines and virt_lines_cfg or false,
	})
end, { desc = 'Toggle diagnostics' })

---- Language Servers
local on_attach = require 'lspconfig-local'
vim.lsp.config('*', {
	on_attach = on_attach,
	capabilities = vim.lsp.protocol.make_client_capabilities(),
	inlay_hints = { enabled = true },
})
require 'mason'.setup {}
require 'mason-lspconfig'.setup {
	automatic_enable = { exclude = {
		'rubocop',
	}, },
}


require 'fidget'.setup {}

require 'guihua.maps'.setup { maps = { close_view = '<C-c>', }, }
require 'navigator'.setup {
	on_attach = on_attach,
	default_mapping = false,
	icons = { icons = false },
	mason = true,
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
			virtual_text = virt_text_cfg,
			virtual_lines = virt_lines_cfg,
			update_in_insert = true,
		},
	},
	lsp_signature_help = true,
	signature_help_cfg = {
		hint_enable = false,
		hi_parameter = 'CursorLine',
	},
}

-- cmp
opt.completeopt = { 'menu', 'noselect', 'noinsert' }
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
	mapping = {
		['<Tab>']     = function(fallback)
			if luasnip.in_snippet() and luasnip.jumpable(1) then
				luasnip.jump(1)
			elseif cmp.visible() then
				cmp.mapping.select_next_item()()
			else
				fallback()
			end
		end,
		['<S-Tab>']   = function(fallback)
			if cmp.visible() then
				cmp.mapping.select_prev_item()()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end,
		['<C-p>']     = cmp.mapping.select_prev_item(),
		['<C-n>']     = cmp.mapping.select_next_item(),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>']     = cmp.mapping.close(),
		['<C-c>']     = cmp.mapping.close(),
		['<CR>']      = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true, },
		['<C-d>']     = cmp.mapping.scroll_docs(4),
		['<C-u>']     = cmp.mapping.scroll_docs(-4),
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp',   group_index = 1 },
		{ name = 'nvim_lua',   group_index = 1 },
		{ name = 'treesitter', group_index = 2 },
		{ name = 'luasnip',    group_index = 3 },
		{ name = 'buffer', group_index = 4,
			option = {
				get_bufnrs = function()
					return vim.api.nvim_list_bufs()
				end
			}
		},
		{ name = 'async_path', group_index = 5 },
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	completion = {
		completeopt = 'menu,noinsert,noselect',
		-- autocomplete = false,
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
}

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline' }
	}),
	matching = { disallow_symbol_nonprefix_matching = false }
})

-- If you want insert `(` after select function or method item
local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
cmp.event:on(
	'confirm_done',
	cmp_autopairs.on_confirm_done()
)

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

require 'treesj'.setup {
	max_join_length = 480,
	use_default_keymaps = false,
}
map('n', 'gS', require 'treesj'.split)
map('n', 'gJ', require 'treesj'.join)

require 'timber'.setup {
	log_templates = {
		default = {
			javascript = [[console.info("%log_target", %log_target)]],
			typescript = [[console.info("%log_target", %log_target)]],
			ruby = [[ap %log_target]],
		},
		plain = {
			javascript = [[console.info("%insert_cursor")]],
			typescript = [[console.info("%insert_cursor")]],
			ruby = [[ap %insert_cursor]],
		}
	},
	batch_log_templates = {
		default = {
			javascript = [[console.dir({ %repeat<%log_target><, > })]],
			typescript = [[console.dir({ %repeat<%log_target><, > })]],
			ruby = [[ap "%repeat<%log_target: #{%log_target}><, >"]]
		}
	}
}
