local M = {}
M.add_autocmds = function()
	vim.api.nvim_create_augroup("PBTWAddingBuffer", { clear = true })
	vim.api.nvim_create_autocmd("BufReadPost", {
		desc = "Adds Buffer to its window list when opened for the first time",
		group = "PBTWAddingBuffer",
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local tabnr = vim.api.nvim_get_current_tabpage()
			local winnr = vim.api.nvim_get_current_win()
			local buffername = vim.fn.expand("%:t")
			local bufferpath = vim.api.nvim_buf_get_name(vim.fn.bufnr())

			-- Updates tabs list
			if Tabs[tabnr] == nil then
				Tabs["" .. tabnr] = {}
			end
			Tabs["" .. tabnr]["buffers"] = bufnr
			Tabs["" .. tabnr]["windows"] = winnr

			-- Updates buffers list
			if Buffers["" .. bufnr] == nil then
				Buffers["" .. bufnr] = {}
				Buffers["" .. bufnr]["buffername"] = buffername
				Buffers["" .. bufnr]["bufferpath"] = bufferpath
				Buffers["" .. bufnr]["window"] = winnr
				Buffers["" .. bufnr]["tab"] = tabnr

				local key = M.assign_key(buffername, bufferpath)
				Buffers["" .. bufnr]["key"] = key[1]
				Buffers["" .. bufnr]["key_idx"] = key[2]
			end

			-- Updates windows list
			if Windows["" .. winnr] == nil then
				Windows["" .. winnr] = {}
			end
			Windows["" .. winnr]["buffers"] = bufnr
			Windows["" .. winnr]["tab"] = tabnr
		end
	})

	vim.api.nvim_create_augroup("PBTWRemoveBuffer", { clear = true })
	vim.api.nvim_create_autocmd("BufDelete", {
		desc = "Removes Buffer from bufferlistwhen closed",
		group = "PBTWRemoveBuffer",
		callback = function()
			local bufnr = vim.fn.bufnr(vim.fn.expand("<afile>"))

			if type(Buffers["" .. bufnr]) == "table" then
				Buffers["" .. bufnr] = nil
			end
		end
	})
end

M.assign_key = function(buffername, bufferpath)
	if #Keys == 0 then
		local char = buffername:sub(1, 1)
		table.insert(Keys, char)
		return { char, 1 }
	end
	for idx = 1, #buffername do
		local char = buffername:sub(idx, idx)
		for key_idx = 0, #Keys do
			if char == Keys[key_idx] then
				if idx == #buffername then
					return M.random_key()
				else
					break
				end
			else
				if key_idx == #Keys then
					table.insert(Keys, char)
					return { char, idx }
				end
			end
		end
	end
end

M.random_key = function()
	return { "XXXXX", 3 }
end

return M
