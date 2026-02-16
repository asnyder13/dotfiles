local map = require 'util'.map_keys_table

require 'mason-nvim-dap'.setup {}
require 'nvim-dap-virtual-text'.setup {}
local dap = require 'dap'

-- dap mappings
-- local dap_opts = { desc = 'DAP' }

local dap_on_attach = function(bufnr)
	local opts = { noremap = true, buffer = bufnr, desc = nil }
	local o = function(desc) return vim.tbl_extend('force', opts, { desc = 'DAP ' .. desc }) end

	map('n', '<F5>', dap.continue, o('continue'))
	map('n', '<Leader><F5>', dap.terminate, o('terminate'))
	map('n', '<F10>', dap.step_over, o('step_over'))
	map('n', { '<Leader><F11>', '<F11>' }, dap.step_into, o('step_into'))
	map('n', '<F12>', dap.step_out, o('step_out'))
	map('n', { '<Leader>db', '<F9>' }, dap.toggle_breakpoint, o('toggle_breakpoint'))
	map('n', '<Leader>dB', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
		o('conditional breakpoint'))
	map('n', '<Leader>lp', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log print message: ')) end,
		o('log breakpoint'))
	map('n', '<Leader>dr', dap.repl.open, o('repl open'))
	map('n', '<Leader>dl', dap.run_last, o('run_last'))
	map({ 'n', 'v' }, '<Leader>dh', require 'dap.ui.widgets'.hover, o('ui hover'))
	map({ 'n', 'v' }, '<Leader>dp', require 'dap.ui.widgets'.preview, o('ui preview'))
	map('n', '<Leader>df', function()
		local widgets = require 'dap.ui.widgets'
		widgets.centered_float(widgets.frames)
	end, o('ui centered float frames'))
	map('n', '<Leader>ds', function()
		local widgets = require 'dap.ui.widgets'
		widgets.centered_float(widgets.scopes)
	end, o('ui centered float scopes'))
end


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
			return vim.fn.input('Path to dll ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
		end,
	},
}

---- TS/ng/JS
dap.adapters.firefox = {
	type = 'executable',
	command = 'node',
	args = { os.getenv('HOME') .. '/.local/share/nvim/mason/packages/firefox-debug-adapter/dist/adapter.bundle.js' }
}
dap.adapters.chrome = {
	type = 'executable',
	command = 'node',
	args = { os.getenv('HOME') .. '/.local/share/nvim/mason/packages/chrome-debug-adapter/src/chromeDebug.ts' }
}
local chrome_config = {
	name = 'Debug with Chrome',
	type = 'chrome',
	request = 'attach',
	program = '${file}',
	cwd = vim.fn.getcwd(),
	sourceMaps = true,
	protocol = 'inspector',
	port = 9222,
	webRoot = '${workspaceFolder}'
}
local firefox_config = {
	name = 'Debug with Firefox',
	type = 'firefox',
	request = 'launch',
	reAttach = true,
	url = 'http://localhost:4200',
	webRoot = '${workspaceFolder}',
	firefoxExecutable = '/usr/local/bin/firefox'
}
dap.configurations.typescript = { firefox_config, chrome_config, }
dap.configurations.javascriptreact = { firefox_config, chrome_config, }
dap.configurations.typescriptreact = { firefox_config, chrome_config, }

return dap_on_attach
