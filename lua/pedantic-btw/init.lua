local M = {}
Buffers = {}
Tabs = {}
Windows = {}
Keys = {}
ExitKeys = {}
function M.setup(opts)
	if opts["exit_keys"] then
		for _, key in ipairs(opts["exit_keys"]) do
			table.insert(ExitKeys, key)
		end
	end
	require("autocmds").add_autocmds()
end

function M.buffer_list()
	if require("bufferlist").display() == 0 then
		return
	end
	vim.cmd.redraw()

	M.select_buffer()
end

function M.select_buffer()
	while true do
		local ok, char = pcall(vim.fn.getcharstr)
		if not ok then
			vim.api.nvim_feedkeys(char, 'n', false)
			break
		end
			if char == "" then
				vim.api.nvim_buf_delete(0, { force = true })
				return
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
					-- vim.api.nvim_buf_delete(0, { force = true })
					vim.notify("Incorrect Key?")
					break
				end
			end
			idx = idx + 1
		end
	end
end

function M.edit_buffer_tab(bufnr)
	local ok, char = pcall(vim.fn.getcharstr)
	print("TabList:" .. "")
end

function M.config()
	print("Initialize config")
end

function M.store_bufferlist()

end

return M
