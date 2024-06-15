local map = require 'util'.map_keys_table

local prettierd = require 'formatter.defaults.prettierd'
local formatter_fts = {
	['*'] = {
		-- 'formatter.filetypes.any' defines default configurations for any filetype
		require('formatter.filetypes.any').remove_trailing_whitespace,
	},
	ruby = { require 'formatter.filetypes.ruby'.rubocop },

	css = { prettierd },
	graphql = { prettierd },
	html = { prettierd },
	javascript = { prettierd },
	javascriptreact = { prettierd },
	['javascript.jsx'] = { prettierd },
	json = { prettierd },
	jsonc = { prettierd },
	less = { prettierd },
	markdown = { prettierd },
	scss = { prettierd },
	typescript = { prettierd },
	typescriptreact = { prettierd },
	['typescript.tsx'] = { prettierd },
	vue = { prettierd },
	yaml = { prettierd },
}
require 'formatter'.setup {
	logging = true,
	log_level = vim.log.levels.WARN,
	-- All formatter configurations are opt-in
	filetype = formatter_fts,
}

local ft_extensions = vim.tbl_keys(formatter_fts)
local map_formatting_group = vim.api.nvim_create_augroup('FormattingMaps', { clear = true })
vim.api.nvim_create_autocmd({ 'FileType', }, {
	group = map_formatting_group,
	pattern = '*',
	callback = function(event)
		local bufnr = event.buf
		if vim.tbl_contains(ft_extensions, event.match) then
			map('n', '==', ':Format<CR>', { buffer = bufnr, desc = 'Format file' })
		else
			map('n', '==', function()
				vim.lsp.buf.format { async = true }
			end, { buffer = bufnr, desc = 'Format file' })
		end
	end
})
