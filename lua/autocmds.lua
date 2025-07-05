local M = {}
-- local special_keys = { "j", "k", "q", "d" }

---@param config Config
function M.add_autocmds(config)
	vim.api.nvim_create_augroup("PBTWReadingBuffer", { clear = true })
	vim.api.nvim_create_autocmd("BufReadPost", {
		desc = "Adds Buffer to its window list when opened for the first time",
		group = "PBTWReadingBuffer",
		callback = function()
			local bufnr = vim.api.nvim_get_current_buf()
			local tabnr = vim.api.nvim_get_current_tabpage()
			local winnr = vim.api.nvim_get_current_win()
			local buffername = vim.fn.expand("%:t")

			M.add_buffer(bufnr, tabnr, winnr, buffername, config)
		end
	})

	vim.api.nvim_create_augroup("PBTWDeleteTab", { clear = true })
	vim.api.nvim_create_autocmd("TabClosed", {
		desc = "Moves buffers in current tab to first tab when current tab closed",
		group = "PBTWDeleteTab",
		callback = function()
			--on tab close, <afile> expands to tab number
			local closed_tabnr = vim.fn.expand("<afile>")
			for tabnr, _ in pairs(Tabs) do
				-- Just place the buffers in the first available Tab
				-- TODO: User is able to select tabs to use
				if tonumber(tabnr) ~= tonumber(closed_tabnr) then
					-- table.move(Tabs["" .. closed_tab]["buffers"], 1, #Tabs["" .. closed_tab]["buffers"],
					-- #Tabs["" .. key]["buffers"] + 1,
					-- Tabs["" .. key]["buffers"])
					for _, buffer in pairs(Tabs["" .. closed_tabnr]["buffers"]) do
						Tabs["" .. tabnr]["buffers"][#Tabs["" .. tabnr]["buffers"] + 1] = buffer

						Buffers["" .. buffer]["tab"] = tonumber(tabnr)
						-- Just place the Buffers in the first window of the new tab
						-- TODO: User is able to select the windows to use
						Buffers["" .. buffer]["window"] = Tabs["" .. tabnr]["windows"][1]
					end
					break
				end
			end
			Tabs["" .. closed_tabnr] = nil
		end

	})
	if config.track_windows == true then
		vim.api.nvim_create_augroup("PBTWDeleteWindow", { clear = true })
		vim.api.nvim_create_autocmd("WinClosed", {
			desc = "Moves buffers in current window to first window in tab when current window is closed",
			group = "PBTWDeleteWindow",
			callback = function()
				local closed_winnr = vim.fn.expand("<afile>")
				-- Temporary Windows are not added to the BTW tables,
				-- ie. Telescope Browsing Windows
				if Windows["" .. closed_winnr] == nil then
					return
				end

				for _, winnr in Tabs["" .. Windows["" .. closed_winnr]["tab"]]["windows"] do
					if winnr ~= closed_winnr then
						-- Just move Buffers to first valid window in Tab
						for bufnr in Windows["" .. winnr]["buffers"] do
							Windows["" .. winnr][#Windows["" .. winnr + 1]]["buffers"] = bufnr
							Buffers["" .. bufnr]["window"] = winnr
						end
						break
					end
				end
				-- FIX: What happens if closed_winnr has already been iterated?
				for tabs_key, winnr in ipairs(Tabs["" .. Windows["" .. closed_winnr]["tab"]]["windows"]) do
					if winnr == closed_winnr then
						-- WARNING:  Unclear if addressing with tabs_key will lead to
						-- empty index in table
						Tabs["" .. Windows["" .. closed_winnr]["tab"]]["window"][tabs_key] = nil
					end
				end

				Windows["" .. closed_winnr] = nil

				-- TODO: Delete winnr in Tabs table
				-- Buffers
				-- Update winnr
				-- Windows
				-- move buffers to new winnr
				-- Tabs[""..Windows["" ..closed_winr]["tab"]]
				-- Handle deletions from Buffers, Windows and Tabs tables
				-- for buffer in reassign_bufs do
				-- Change  data in Windows
				-- end
			end
		})
	end
	vim.api.nvim_create_augroup("PBTWDeleteBuffer", { clear = true })
	vim.api.nvim_create_autocmd("BufDelete", {
		desc = "Removes Buffer from bufferlist when closed",
		group = "PBTWDeleteBuffer",
		callback = function()
			local filename = vim.fn.expand("<afile>")

			-- If buffer does not have a filename, then it may be a temporary
			-- use buffer, and would not have been added.
			if filename == "" then
				return
			end

			local bufnr = vim.fn.bufnr(filename)

			-- Confirm if buffer exists
			-- Some buffers may not have been added to the buffer list
			if Buffers["" .. bufnr] == nil then
				return
			end

			if #Keys > 0 then
				for i = 0, #Keys do
					if Buffers["" .. bufnr]["key"] == Keys[i] then
						Keys[i] = nil
					end
				end
			end
			if type(Buffers["" .. bufnr]) == "table" then
				Buffers["" .. bufnr] = nil
			end
		end
	})
end

function M.add_buffer(bufnr, tabnr, winnr, buffername, config)
	-- Disregard buffers without names. Typically would be temp lists ie. QuickFixList, Unnamed Buffer
	-- There is no name on this file, so why add it?
	if buffername == "" then
		return
	end

	local bufferpath = vim.api.nvim_buf_get_name(vim.fn.bufnr())


	-- Updates tabs list

	if Tabs["" .. tabnr] == nil then
		Tabs["" .. tabnr] = {}
		Tabs["" .. tabnr]["buffers"] = {}
		Tabs["" .. tabnr]["windows"] = {}
	end
	Tabs["" .. tabnr]["buffers"][#Tabs["" .. tabnr]["buffers"] + 1] = bufnr


	--check if winnr exists in Tabs table
	if config.track_windows == false then
		vim.notify("Not tracking windows...")
		return
	else
		local win_added_to_Tabs = false
		for _, v in pairs(Tabs["" .. tabnr]["windows"]) do
			if v == winnr then
				win_added_to_Tabs = true
				break
			end
		end
		if not win_added_to_Tabs then
			Tabs["" .. tabnr]["windows"][#Tabs["" .. tabnr]["windows"] + 1] = winnr
		end
		-- Updates windows list
		if Windows["" .. winnr] == nil then
			Windows["" .. winnr] = {}
			Windows["" .. winnr]["buffers"] = {}
			Windows["" .. winnr]["tab"] = {}
		end
		Windows["" .. winnr]["buffers"] = bufnr
		Windows["" .. winnr]["tab"] = tabnr
	end

	-- Updates buffers list
	if Buffers["" .. bufnr] == nil then
		Buffers["" .. bufnr] = {}
		Buffers["" .. bufnr]["buffername"] = buffername
		Buffers["" .. bufnr]["bufferpath"] = bufferpath
		Buffers["" .. bufnr]["window"] = winnr
		Buffers["" .. bufnr]["tab"] = tabnr

		-- TODO: might fail if key is not assigned.
		-- Tighten edge cases
		local key = M.assign_key(buffername, bufferpath)
		if key == nil then
			return
		end

		Buffers["" .. bufnr]["key"] = key[1]
		Buffers["" .. bufnr]["key_idx"] = key[2]
	end
end

--Assign a key character to the file based on filename or path
--if other characters have already been assigned to other open buffers.
---@var buffername
---@var bufferpath
---@return table{string, int}
M.assign_key = function(buffername, bufferpath)
	local char, char_idx = nil, nil
	if #Keys == 0 then
		char = buffername:sub(1, 1)
		char_idx = 1
		table.insert(Keys, char)
	else
		for idx = 1, #buffername do
			if idx == #buffername then
				char, char_idx = M.key_from_bufferpath(bufferpath)
				if #char > 1 then
					char, char_idx = M.random_key()
					break
				else
					break
				end
			end

			char = buffername:sub(idx, idx)

			for key_idx = 1, #Keys do
				if char == Keys[key_idx] then
					break
				else
					if key_idx == #Keys then
						table.insert(Keys, char)
						char_idx = idx
						break
					end
				end
			end
			if char_idx ~= nil then
				break
			end
		end
	end
	return { char, char_idx }
end

M.edit_buffer_tab = function(bufnr)
end

-- Not truly random
-- returns the next available character that has not been assigned so far
-- iterates through all valid ASCII characters.
-- if fails, session has 93 buffers open..... at which returns 0 to end
-- the key assignment process
---@return table
M.random_key = function()
	for i = 33, 126 do
		for key in Keys do
			if key ~= string.char(i) then
				return string.char(i)
			end
		end
		if i == 126 then
			print("Unable to assign a key. Failed")
			return { "Failed", 999999 }
		end
	end
	return { "XXXXX", 3 }
end

---@return table
function M.key_from_bufferpath(bufferpath)
	for key_idx = 0, #bufferpath do
		print("" .. key_idx)
	end
	-- TODO:
	return { "XXXXX", 3 }
end

return M
