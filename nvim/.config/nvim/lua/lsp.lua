local map = require 'util'.map_keys_table

local opt = vim.opt

-- Hide default LSP popup
map('n', '<C-k>', '<NOP>')

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
	indent = { enable = true, disable = { 'ruby' } },
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
	endwise = { enable = true, },
}
require 'ts_context_commentstring'.setup {}
vim.g.skip_ts_context_commentstring_module = true

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

---- Language Servers
require 'mason'.setup {}
require 'mason-lspconfig'.setup {}

require 'fidget'.setup {}

vim.diagnostic.config {
	virtual_lines = { only_current_line = true, },
}
require 'lsp_lines'.setup()

local default_cfg, custom_cfg = require 'lspconfig-local' ()
-- Setup installed servers.
require 'mason-lspconfig'.setup_handlers {
	function(server_name)
		local cfg = custom_cfg[server_name] and vim.tbl_deep_extend('force', default_cfg, custom_cfg[server_name]()) or
				default_cfg
		require 'lspconfig'[server_name].setup(cfg)
	end,
	-- Ignore RuboCop for LSP stuff, but we want it installed for formatting
	rubocop = function() end,
}

require 'guihua.maps'.setup { maps = { close_view = '<C-c>', }, }
require 'navigator'.setup {
	on_attach = function(...) on_attach.base(...) end,
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
			virtual_text = true,
			update_in_insert = true,
		},
	},
}

-- cmp
opt.completeopt = { 'menu', 'noselect', 'noinsert' }
local cmp = require 'cmp'
local luasnip = require 'luasnip'

cmp.setup {
	mapping = {
		['<Tab>']     = function(fallback)
			if cmp.visible() then
				cmp.mapping.select_next_item()()
			elseif luasnip.expand_or_locally_jumpable() then
				luasnip.expand_or_jump()
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
		-- nvim_lsp_signature_help fixes, still doesn't work great.
		-- ['<CR>']      = function(fallback)
		-- 	-- Don't replace with the signature help param name when <CR> is hit.
		-- 	local entries = cmp.get_entries()
		-- 	if entries and entries[1] and entries[1].source and entries[1].source.source and entries[1].source.source['signature_help'] == nil then
		-- 		cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true, } ()
		-- 	else
		-- 		fallback()
		-- 	end
		-- end,
		['<C-d>']     = cmp.mapping.scroll_docs(4),
		['<C-u>']     = cmp.mapping.scroll_docs(-4),
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp',   group_index = 1 },
		{ name = 'treesitter', group_index = 2 },
		{ name = 'luasnip',    group_index = 3 },
		{ name = 'buffer', group_index = 4,
			option = {
				get_bufnrs = function()
					local bufs = {}
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						bufs[vim.api.nvim_win_get_buf(win)] = true
					end
					return vim.tbl_keys(bufs)
				end
			}
		},
		{ name = 'path', group_index = 5 },
		-- { name = 'nvim_lsp_signature_help' },
	}),
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	completion = { completeopt = 'menu,noinsert,noselect' },
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
}

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
