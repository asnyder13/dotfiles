local map = require 'util'.map_keys_table

map('n', 'gbd', function() require 'mini.bufremove'.wipeout() end, { desc = 'Buffer delete, keep window' })

require 'mini.align'.setup {}
require 'mini.ai'.setup { n_lines = 10000, }
require 'mini.diff'.setup {
	view = {
		style = 'number'
	},
}
require 'mini.operators'.setup {}
local animate = require 'mini.animate'
local timing50 = animate.gen_timing.linear { duration = 50, unit = 'total' }
animate.setup {
	curosr = { timing = timing50, },
	scroll = { timing = timing50 },
	resize = { timing = timing50 },
	close = { timing = timing50 },
	open = { timing = timing50 },
}
