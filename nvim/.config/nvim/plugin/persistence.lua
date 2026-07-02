local Util = require 'util'
local map = Util.map_keys_table

Util.create_expand_path(vim.fn.stdpath('state') .. '/sessions/')

require 'persistence'.setup {}
map('n', '<leader>qs', function() require 'persistence'.load() end,
	{ desc = 'load the session for the current directory' })
map('n', '<leader>qS', function() require 'persistence'.select() end, { desc = 'select a session to load' })
map('n', '<leader>ql', function() require 'persistence'.load { last = true } end, { desc = 'load the last session' })
map('n', '<leader>qd', function() require 'persistence'.stop() end,
	{ desc = "stop Persistence => session won't be saved on exit" })
