local M = {}
Buffers = {}
Tabs = {}
Windows = {}
Keys = {}
ExitKeys = { "q", "" }
M.setup = function()
	require("autocmds").add_autocmds()
	-- return M
end
M.buffer_list = function()
	require("bufferlist").display()
	vim.cmd.redraw()

	M.select_buffer()
end
M.select_buffer = function()
	while true do
		local ok, char = pcall(vim.fn.getcharstr)
		if not ok then
			vim.api.nvim_feedkeys(char, 'n', false)
			break
		end
		for _, exit_key in pairs(ExitKeys) do
			if char == exit_key then
				vim.api.nvim_buf_delete(0, { force = true })
				return
			end
		end

		local buffers = 0
		for _, _ in pairs(Buffers) do
			buffers = buffers + 1
		end

		local idx = 0
		for bufnr, buffer_details in pairs(Buffers) do
			if char == buffer_details["key"] then
				vim.api.nvim_buf_delete(0, { force = true })
				vim.api.nvim_set_current_tabpage(buffer_details["tab"])
				vim.cmd("b " .. bufnr)
				return
			else
				if idx == buffers - 1 then
					vim.api.nvim_buf_delete(0, { force = true })
					vim.api.nvim_feedkeys(char, 'n', true)
					vim.notify("Incorrect Key?")
					return
				end
			end
			idx = idx + 1
		end
	end
end
M.edit_buffer_tab = function(bufnr)
	local ok, char = pcall(vim.fn.getcharstr)
	print("TabList:" .. "")
end

M.config = function()
	print("Initialize config")
end

M.store_bufferlist = function()

end

return M
