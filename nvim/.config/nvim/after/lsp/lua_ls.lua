---@type vim.lsp.Config
return {
	on_init = function(client)
		client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
			runtime = { version = 'LuaJIT' },
			-- Make the server aware of Neovim runtime files
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME }
			}
		})
	end,
	settings = {
		Lua = { hint = { enable = true, } }
	}
}
