require 'timber'.setup {
	log_templates = {
		default = {
			javascript = [[console.dir('%log_target', %log_target)]],
			typescript = [[console.dir('%log_target', %log_target)]],
			ruby = [[ap({ %log_target: })]],
			lua = [[vim.print(%log_target)]],
			c_sharp = [[%cs_log_format($"%log_target: {%log_target}");]],
		},
		plain = {
			javascript = [[console.dir('%insert_cursor')]],
			typescript = [[console.dir('%insert_cursor')]],
			ruby = [[ap{ %log_target })]],
			lua = [[vim.print(%insert_cursor)]],
			c_sharp = [[%cs_log_format($"{%insert_cursor}");]],
		}
	},
	batch_log_templates = {
		default = {
			javascript = [[console.dir({ %repeat<%log_target><, > })]],
			typescript = [[console.dir({ %repeat<%log_target><, > })]],
			ruby = [[ap({ %repeat<%log_target:><, > })]],
			c_sharp = [[%cs_log_format($"%repeat<%log_target: {%log_target}><, >");]],
		}
	},
	template_placeholders = {
		-- Check if the class is using an ILogger instead.
		---@param ctx Timber.Actions.Context
		cs_log_format = function(ctx)
			local memo = vim.b['cs_log_format']
			if memo == nil then
				for _, line in ipairs(vim.filetype._getlines(0, 1, 200)) do
					local match = line:match('^%s*private%s*%w*%s*ILogger<.+> ([%w_]+)')
					if match ~= nil then
						memo = match .. '.LogInformation'
						break
					end
				end

				memo = memo or 'Console.WriteLine'
				vim.b['cs_log_format'] = memo
			end

			return memo
		end,
	},
}
