local Util = require 'util'

require 'timber'.setup {
	log_templates = {
		default = {
			javascript = [[console.dir('%log_target', %log_target)]],
			typescript = [[console.dir('%log_target', %log_target)]],
			ruby = [[ap({ %log_target: })]],
			lua = [[vim.print(%log_target)]],
			c_sharp = [[%cs_log_format%log_target: {%log_target}");]],
		},
		plain = {
			javascript = [[console.dir('%insert_cursor')]],
			typescript = [[console.dir('%insert_cursor')]],
			ruby = [[ap{ %log_target })]],
			lua = [[vim.print(%insert_cursor)]],
			c_sharp = [[%cs_log_format{%insert_cursor}");]],
		}
	},
	batch_log_templates = {
		default = {
			javascript = [[console.dir({ %repeat<%log_target><, > })]],
			typescript = [[console.dir({ %repeat<%log_target><, > })]],
			ruby = [[ap({ %repeat<%log_target:><, > })]],
			c_sharp = [[%cs_log_format%repeat<%log_target: {%log_target}><, >");]],
		}
	},
	template_placeholders = {
		-- Check if the class is using an ILogger
		-- Add class and method names if available
		---@param ctx Timber.Actions.Context
		cs_log_format = function(ctx)
			local memo_logger = vim.b['cs_log_format_logger']

			-- Memoize class name
			if memo_logger == nil then
				for _, line in ipairs(vim.filetype._getlines(0, 1, 200)) do
					local match = line:match('.*ILogger<.+>%s*([%w_]+)')
					if match ~= nil then
						memo_logger = match .. '.LogInformation'
						break
					end
				end

				memo_logger = memo_logger or 'Console.WriteLine'
				vim.b['cs_log_format_logger'] = memo_logger
			end

			local classname = Util.get_ancestor_field('class_declaration', 'name')
			classname = classname and classname .. '::' or ''

			local fnname = Util.get_ancestor_field('method_declaration', 'name')
			fnname = fnname and fnname .. '() ' or ' '

			return string.format('%s($"%s%s', memo_logger, classname, fnname)
		end,
	},
}
