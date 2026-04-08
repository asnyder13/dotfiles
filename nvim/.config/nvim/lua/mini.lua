local map = require 'util'.map_keys_table

map('n', 'gbd', function() require 'mini.bufremove'.wipeout() end, { desc = 'Buffer delete, keep window' })

require 'mini.align'.setup {}
require 'mini.ai'.setup { n_lines = 10000, }
require 'mini.diff'.setup { view = { style = 'number' }, }
require 'mini.operators'.setup { sort = { prefix = '', }, }
