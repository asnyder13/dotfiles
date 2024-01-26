local map = require 'util'.map_keys_table

require 'nvim-dap-virtual-text'.setup {}
local dap = require 'dap'

-- dap mappings
local dap_opts = {
	silent = true,
	buffer = true,
}
map('n', '<F5>', function() return dap.continue() end, dap_opts)
map('n', '<Leader><F5>', function() return dap.terminate() end, dap_opts)
map('n', '<F10>', function() return dap.step_over() end, dap_opts)
map('n', '<Leader><F11>', function() return dap.step_into() end, dap_opts)
map('n', '<F11>', function() return dap.step_into() end, dap_opts)
map('n', '<F12>', function() return dap.step_out() end, dap_opts)
map('n', { '<Leader>db', '<F9>' }, function() return dap.toggle_breakpoint() end, dap_opts)
map('n', '<Leader>dB', function() return dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, dap_opts)
map('n', '<Leader>lp', function() return dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, dap_opts)
map('n', '<Leader>dr', function() return dap.repl.open() end, dap_opts)
map('n', '<Leader>dl', function() return dap.run_last() end, dap_opts)
map({ 'n', 'v' }, '<Leader>dh', function() require('dap.ui.widgets').hover() end)
map({ 'n', 'v' }, '<Leader>dp', function() require('dap.ui.widgets').preview() end)
map('n', '<Leader>df', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.frames)
end)
map('n', '<Leader>ds', function()
	local widgets = require('dap.ui.widgets')
	widgets.centered_float(widgets.scopes)
end)

---- Ruby
require 'dap-ruby'.setup()
-- re-set configs, only want one.
dap.configurations.ruby = {
	{
		type = 'ruby',
		name = 'debug current file',
		bundle = '',
		request = 'attach',
		command = 'ruby',
		script = '${file}',
		port = 38698,
		server = '127.0.0.1',
		options = {
			source_filetype = 'ruby',
		},
		localfs = true,
		waiting = 1000,
	},
}

---- dotnet
dap.adapters.coreclr = {
	type = 'executable',
	command = '~/.local/share/nvim/mason/bin/netcoredbg',
	args = { '--interpreter=vscode' }
}

dap.configurations.cs = {
	{
		type = 'coreclr',
		name = 'launch - netcoredbg',
		request = 'launch',
		program = function()
			return vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/', 'file')
		end,
	},
}
