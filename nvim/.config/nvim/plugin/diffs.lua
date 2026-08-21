local map = require 'util'.map_keys_table

require 'diffview'.setup {
	hide_merge_artifacts = true,
	clean_up_buffers = true,
	enhanced_diff_hl = true,
	diffopt = { algorithm = 'histogram' },
	view = {
		merge_tool = {
			layout = "diff4_mixed",
			disable_diagnostics = true,
			winbar_info = true,
		},
		cycle_layouts = {
			merge_tool = { "diff4_mixed", "diff3_mixed", "diff3_horizontal", "diff1_plain" },
		},
	},
}
-- Toggle diffview open/close
map('n', '<leader>dv', '<cmd>DiffviewToggle<cr>', { desc = 'Toggle Diffview' })
-- Diff working directory
map('n', '<leader>do', '<cmd>DiffviewOpen<cr>', { desc = 'Diffview open' })
map('n', '<leader>dc', '<cmd>DiffviewClose<cr>', { desc = 'Diffview close' })
-- File history
map('n', '<leader>dh', '<cmd>DiffviewFileHistory %<cr>', { desc = 'File history (current file)' })
map('n', '<leader>dH', '<cmd>DiffviewFileHistory<cr>', { desc = 'File history (repo)' })
-- Visual mode: history for selection
map('v', '<leader>dh', "<Esc><cmd>'<,'>DiffviewFileHistory --follow<CR>", { desc = 'Range history' })
-- Single line history
map('n', '<leader>dl', '<cmd>.DiffviewFileHistory --follow<CR>', { desc = 'Line history' })
-- Diff against main/master branch (useful before merging)
map('n', '<leader>dm', function()
	-- Try main first, fall back to master
	local result = vim.fn.systemlist({ 'git', 'rev-parse', '--verify', 'main' })
	local ok = vim.v.shell_error == 0 and result[1] ~= nil and result[1] ~= ''
	local branch = ok and 'main' or 'master'
	vim.cmd('DiffviewOpen ' .. branch)
end, { desc = 'Diff against main/master' })
-- Diff against a branch selected via Telescope
map('n', '<leader>db', function()
	require 'telescope.builtin'.git_branches({
		attach_mappings = function(_, map)
			map('i', '<CR>', function(prompt_bufnr)
				local selection = require 'telescope.actions.state'.get_selected_entry()
				require 'telescope.actions'.close(prompt_bufnr)
				vim.cmd('DiffviewOpen ' .. selection.value)
			end)
			return true
		end,
	})
end, { desc = 'Diffview branch' })
-- File history for a commit selected via Telescope
map('n', '<leader>dC', function()
	require 'telescope.builtin'.git_commits {
		attach_mappings = function(_, map)
			map('i', '<CR>', function(prompt_bufnr)
				local selection = require 'telescope.actions.state'.get_selected_entry()
				require 'telescope.actions'.close(prompt_bufnr)
				vim.cmd('DiffviewOpen ' .. selection.value .. '^!')
			end)
			return true
		end,
	}
end, { desc = 'Diffview commit' })

require 'gitgraph'.setup {
	hooks = {
		-- <CR> on a commit: show that commit's own changes.
		on_select_commit = function(commit)
			vim.notify('DiffviewOpen ' .. commit.hash .. '^!')
			vim.cmd('DiffviewOpen ' .. commit.hash .. '^!')
		end,
		-- <CR> over a visual range: diff the whole selected range.
		on_select_range_commit = function(from, to)
			vim.notify('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
			vim.cmd('DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
		end,
	},
}
map('n', '<leader>dg', function()
	require 'gitgraph'.draw({}, { all = true, max_count = 5000 })
end, { desc = 'Commit graph' })
