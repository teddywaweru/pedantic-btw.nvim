local M = {}

M.display = function()
	-- vim.api.nvim_command('botright vnew')
	-- local buf = vim.api.nvim_get_current_buf()
	local buf = vim.api.nvim_create_buf(false, true)





	vim.api.nvim_buf_set_name(buf, "BufferList #" .. buf)
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(buf, 'filetype', 'nvim-bufferlist')


	vim.api.nvim_buf_set_option(buf, 'modifiable', true)
	-- local buffer_count = vim.api.nvim_win_get_height(win) - 1
	print("BufferList" .. vim.inspect(Buffers))
	print("Keys" .. vim.inspect(Keys))

	-- Highlights
	vim.api.nvim_set_hl(0, "DutchTabsLetter",
		{ fg = '#ff007c', bold = true, ctermfg = 198, cterm = { bold = true }, default = true });
	vim.api.nvim_set_hl(0, "DutchTabsPath",
		{ fg = '#0C1B33', bold = true, ctermfg = 198, cterm = { bold = true }, default = true });

	local buffer_details = {}
	for bufnr, values in pairs(Buffers) do
		local detail = "" .. bufnr .. "		" .. values["buffername"]
		table.insert(buffer_details, detail)

		local filepath = "" .. values["bufferpath"]
		table.insert(buffer_details, filepath)
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer_details)
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	local ui = vim.api.nvim_list_uis()[1]
	print("UIs" .. vim.inspect(ui))
	-- print("UI width" .. type(ui[1]) .. vim.inspect(ui))

	local width = 40
	local height = 10
	local win_opts = {
		relative = "editor",
		width = width,
		height = height,
		col = (ui.width / 2) + (width / 2),
		row = (ui.height / 2) + (height / 2) ,
		anchor = "SE",
		title = "BufferList",
		style = "minimal",
		border = "rounded",
	}
	local win = vim.api.nvim_open_win(buf, 1, win_opts)

	for idx = 0, vim.fn.line("$"), 2 do
		-- local values = Buffers[idx]
		vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsLetter", idx, 1, 4)
		vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsPath", idx + 1, 1, 4)
		-- vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsLetter", idx, 1, (string.len(values["buffername"]) ))
		-- vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsPath", idx + 1, 1, string.len(values["bufferpath"]))
	end

end

return M
