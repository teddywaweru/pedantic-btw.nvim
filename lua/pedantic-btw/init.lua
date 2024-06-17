local M = {}
local buffers = {}
local tabs = {}
local windows = {}
M.setup = function()
	vim.api.nvim_create_augroup("AddingBuffers", { clear = true })
	vim.api.nvim_create_autocmd("BufReadPost", {
		desc = "Add Buffer to its window list when opened for the first time",
		group = "AddingBuffers",
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local tabnr = vim.api.nvim_get_current_tabpage()
			local winnr = vim.api.nvim_get_current_win()
			local buffername = vim.fn.expand("%")
			local bufferpath = vim.api.nvim_buf_get_name(vim.fn.bufnr())

			-- Updates tabs list
			if tabs[tabnr] == nil then
				tabs["" .. tabnr] = {}
			end
			tabs["" .. tabnr]["buffers"] = bufnr
			tabs["" .. tabnr]["windows"] = winnr

			-- Updates buffers list
			if buffers["" .. bufnr] == nil then
				buffers["" .. bufnr] = {}
				buffers["" .. bufnr]["buffername"] = buffername
				buffers["" .. bufnr]["bufferpath"] = bufferpath
				buffers["" .. bufnr]["window"] = winnr
				buffers["" .. bufnr]["tab"] = tabnr
			end

			-- Updates windows list
			if windows["" .. winnr] == nil then
				windows["" .. winnr] = {}
			end
			windows["" .. winnr]["buffers"] = bufnr
			windows["" .. winnr]["tab"] = tabnr

			-- print("current_tabnr " .. tabnr)
			-- print("current_bufnr " .. bufnr)
			-- print("current_tabnr " .. tabnr)
			-- print("buffername " .. buffername)
			-- print("BufferList" .. vim.inspect(buffers))
			-- print("TabList" .. vim.inspect(tabs))
		end

	})
	print("Initialize setup")
	-- print("current_tabnr " .. tabnr)
	-- print("current_bufnr " .. bufnr)
	-- print("current_tabnr " .. tabnr)
	-- print("buffername " .. buffername)
	return buffers
end
M.buffer_list = function()
	-- print("BufferList" .. vim.inspect(buffers))
	-- print("TabList" .. vim.inspect(tabs))
	-- print("WindowList" .. vim.inspect(windows))
	local start_win = vim.api.nvim_get_current_win()
	vim.api.nvim_command('botright vnew')
	-- local win = vim.api.get_current_win()
	local buf = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_set_name(buf, "BufferList #" .. buf)
	vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
	vim.api.nvim_buf_set_option(buf, 'swapfile', false)
	vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
	vim.api.nvim_buf_set_option(buf, 'filetype', 'nvim-bufferlist')
	-- vim.api.nvim_buf_set_option(buf, 'wrap', false)
	-- vim.api.nvim_buf_set_option(buf, 'cursorline', true)


	vim.api.nvim_buf_set_option(buf, 'modifiable', true)
	-- local buffer_count = vim.api.nvim_win_get_height(win) - 1
	print("BufferList" .. vim.inspect(buffers))

	-- Highlights
	vim.api.nvim_set_hl(0, "DutchTabsLetter",
		{ fg = '#ff007c', bold = true, ctermfg = 198, cterm = { bold = true }, default = true });
	vim.api.nvim_set_hl(0, "DutchTabsPath",
		{ fg = '#0C1B33', bold = true, ctermfg = 198, cterm = { bold = true }, default = true });

	local buffer_details = {}
	for bufnr, values in pairs(buffers) do
		local detail = "" .. bufnr .. "" .. values["buffername"]
		table.insert(buffer_details, detail)

		local filepath = "" .. values["bufferpath"]
		table.insert(buffer_details, filepath)
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, buffer_details)
	vim.api.nvim_buf_set_option(buf, 'modifiable', false)

	for idx=0, vim.fn.line("$"), 2 do
		local values = buffers[idx]
		vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsLetter", idx, 1, 4)
		vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsPath", idx + 1, 1, 4)
		-- vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsLetter", idx, 1, (string.len(values["buffername"]) ))
		-- vim.api.nvim_buf_add_highlight(0, -1, "DutchTabsPath", idx + 1, 1, string.len(values["bufferpath"]))

	end


	-- for k, v in pairs(buffers) do
	-- 	print("index: " .. k)
	-- 	print("filename: " .. v["buffername"])
	-- 	print("window: " .. v["window"])
	-- 	print("tab: " .. v["tab"])
	-- end
end
M.config = function()
	print("Initialize config")
end

return M
