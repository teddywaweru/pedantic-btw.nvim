local M = {}
Buffers = {}
Tabs = {}
Windows = {}
Keys = {}
M.setup = function()
	require("autocmds").add_autocmds()
	print("Initialize setup")
	return Buffers
end
M.buffer_list = function()
	require("bufferlist").display()
	vim.cmd.redraw()

	M.select_buffer()
end
M.select_buffer = function()
	local char = vim.fn.getcharstr()

	local buffers = 0
	for _, _ in pairs(Buffers) do
		buffers = buffers + 1
	end

	local idx = 0
	for _, buffer_details in pairs(Buffers) do
		if char == buffer_details["key"] then
			vim.api.nvim_buf_delete(0, { force = true })
			vim.cmd("b " .. buffer_details["buffername"])
			return
		else
			if idx == buffers - 1 then
				vim.notify("Error matching character with any opened buffer")
			end
		end

		idx = idx + 1
	end
end
M.config = function()
	print("Initialize config")
end

return M
