local M = {}
-- local special_keys = { "j", "k", "q", "d" }

---@param config Config
function M.add_autocmds(config)
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

--Assign a key character to the file based on filename or path
--if other characters have already been assigned to other open buffers.
M.assign_key = function(buffername, bufferpath)
	if #Keys == 0 then
		local char = buffername:sub(1, 1)
		table.insert(Keys, char)
		return { char, 1 }
	end
	-- Confirm details exists for buffer opened
	-- Handles for some windows that may be loaded temporarily
	for idx = 1, #buffername do
		local char = buffername:sub(idx, idx)

		-- for special_idx = 0, #special_keys do
		-- 		print("Trying to check key to assign")
		-- 	if char == special_keys[special_idx] then
		-- 		print("Assigning a Special Key?")
		-- 	goto next_char_in_buffername
		-- 	end
		-- end

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
		-- ::next_char_in_buffername::
	end
end

M.edit_buffer_tab = function(bufnr)
end

M.random_key = function()
	return { "XXXXX", 3 }
end

return M
