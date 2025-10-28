local M = {}
-- Contains all buffer info that is used in the plugin
-- with the bufnr set as the key value
Buffers = {}
-- Contains all tab info that is used in the plugin
-- with the tubnr set as the key value
Tabs = {}
-- Contains all window info that is used in the plugin
-- with the winnr set as the key value
Windows = {}
Keys = {}
Keys["exit"] = {"q"}
Keys["second_key_trigger"] = {"/"}
function M.setup(opts)
	if opts["exit_keys"] then
		for _, key in ipairs(opts["exit_keys"]) do
			table.insert(Keys["exit"], key)
		end
	end

	-- local track_tabs = opts["track_tabs"]
	--- @class Config
	--- @field track_windows boolean
	--- @field enable_bufferlist boolean
	--- @field bufferlist_exit_keys table

	--- @type Config
	local config = {
		track_windows = true,
		enable_bufferlist = true,
		bufferlist_exit_keys = {}
	}
	require("autocmds").add_autocmds(config)
end

-- Open floating window with open buffer details
function M.buffer_list()
	if require("bufferlist").display() == 0 then
		return
	end
	vim.cmd.redraw()

	M.handle_user_input()

	-- M.select_buffer()
end

-- Handle User Input after Bufferlist is displayed
--- @var input_level String
function M.handle_user_input(input_level)
	while true do
		local ok, char = pcall(vim.fn.getcharstr)
		if not ok then
			-- vim.api.nvim_feedkeys(char, 'n', false)
			vim.api.nvim_buf_delete(0, { force = true })
			break
		end

		for _, exit_key in pairs(Keys["exit"]) do
			if char == exit_key then
				vim.api.nvim_buf_delete(0, { force = true })
				return
			end
		end
		if char == Keys["second_key_trigger"][1] then
				vim.api.nvim_buf_delete(0, { force = true })
			require("bufferlist").display_secondary()
			vim.cmd.redraw()
			M.handle_user_input("second")
			break
		else
			if input_level == "second" then
				if M.select_buffer_on_second_key(char) then
					vim.notify("triggering from second level?")
					break
				end
			else
				if M.select_buffer_on_first_key(char) then
					vim.notify("triggering from first level?")
					break
				end
			end
		end
	end
end

-- Handle buffer selection displayed from buffer_list() function
--- @var char String
--- @return boolean
function M.select_buffer_on_first_key(char)
		local buffers = 0
		for _, _ in pairs(Buffers) do
			buffers = buffers + 1
		end

		local idx = 0
		for bufnr, buffer_details in pairs(Buffers) do
			if char == buffer_details["first_key"] then
				M.load_buffer_pedantically(bufnr, buffer_details)
				return true
			else
				if idx == buffers - 1 then
					-- vim.api.nvim_buf_delete(0, { force = true })
					vim.notify("Incorrect Key?")
				end
			end
			idx = idx + 1
		end
		return false
end

--- @var char String
--- @return boolean
function M.select_buffer_on_second_key(char)
	local buffers = 0
	for _, values in pairs(Buffers) do
		if values["second_key"]~=nil then
			buffers = buffers + 1
		end
	end
	if buffers ==0 then
	vim.notify("No secondary keys assigned")
	end
	local idx = 0
	for bufnr, buffer_details in pairs(Buffers) do
		if char == buffer_details["second_key"] then
			M.load_buffer_pedantically(bufnr, buffer_details)
			return true
		else
			if idx == buffers - 1 then
				-- vim.api.nvim_buf_delete(0, { force = true })
				vim.notify("Incorrect Key?")
			end
		end
		idx = idx + 1
	end
	return false
end

function M.load_buffer_pedantically(bufnr, buffer_details)
	vim.api.nvim_buf_delete(0, { force = true })
	vim.api.nvim_set_current_tabpage(buffer_details["tab"])
	vim.api.nvim_set_current_win(buffer_details["window"])
	vim.cmd("b " .. bufnr)
end

function M.edit_buffer_tab(bufnr)
	local ok, char = pcall(vim.fn.getcharstr)
	print("TabList:" .. "")
end

function M.config()
	print("Initialize config")
end

-- Using the resession.nvim plugin to save buffer details to use when session is restored
-- Resession.nvim does not maintain bufnr, winnr or tabnr upon restart
-- Tabnr are reset from one depending on their order when nvim was saved.
-- Winnr are reset starting arbitrarily, same for bufnrs.
-- HACK: We use the tabnr increments to save buffers per their tabs,
-- Windows are assigned arbitrarily, only tabs are maintained.
-- Involves a lot of cleaning the tables so that errors are prevented during resessions
function M.save_btws()
	-- Handle Changes in Tabs
	local new_tabnr = 1
	local store_tabs = {}
	local store_buffers = Buffers
	local vim_tabs = vim.api.nvim_list_tabpages()
	for _,vim_tab in ipairs(vim_tabs) do
				-- Update the tabnr in Buffers
				for _, bufnr in pairs(Tabs["" .. vim_tab]["buffers"]) do
					store_buffers["" .. bufnr]["tab"] = new_tabnr
				end
				-- tab["buffers"] = nil
				store_tabs["" .. new_tabnr] = Tabs["" .. vim_tab]
				store_tabs["" .. new_tabnr]["buffers"] = nil

				new_tabnr = new_tabnr + 1
	end

	return { Buffers = store_buffers, Windows = Windows, Tabs = store_tabs, Keys = Keys }
end

function M.print_bufferlist()
	for _, buffer_details in pairs(Buffers) do
		for k, v in pairs(buffer_details) do
			print("" .. k .. ":" .. tostring(v))
		end
	end
end

function M.print_tabs()
	for tabnr, tab_tables in pairs(Tabs) do
		print("Tab Number " .. tabnr)
		for k, v in pairs(tab_tables) do
			print("" .. k .. ":" .. table.concat(v, ","))
		end
	end
end

function M.print_windows()
	for winnr, win_tables in pairs(Windows) do
		print("Window Number" .. winnr)
		for k, v in pairs(win_tables) do
			if type(v) == "table" then
				print("" .. k .. ":" .. table.concat(v, ","))
			else
				print("" .. k .. ":" .. v)
			end
		end
	end
end

function M.get_btws()
	return {Buffers = Buffers, Windows = Windows, Tabs = Tabs}
end

-- Change values of bufferlist
function M.edit_bufferlist(buf)
end

-- Change values of buf
function M.edit_Tabs(buf)
end

-- Change values of buf
function M.edit_Windows(buf)
	-- TODO: How to get buf details from user?
end

--Check if Tabs, Windows, and Buffers details have changed
-- Calls autocmd triggered on BufEnter
function M.update_bufs()
	-- Get list of buffers
end

function M.load_session(data)
	local tabs = data["Tabs"]
	local buffers = {}
	local windows = {}
	for tabnr, tab_details in pairs(tabs) do
		tab_details["buffers"] = {}
		local winnrs = vim.api.nvim_tabpage_list_wins(tonumber(tabnr))
		tab_details["windows"] = winnrs

		for _, winnr in ipairs(winnrs) do
			windows["" .. winnr] = {}
			windows["" .. winnr]["tab"] = tabnr
		end
	end

	local bufnrs = vim.api.nvim_list_bufs()
	for _, bufnr in ipairs(bufnrs) do
		local bufferpath = vim.api.nvim_buf_get_name(bufnr)
		for _, store_buffer_details in pairs(data["Buffers"]) do
			if bufferpath == store_buffer_details["bufferpath"] then
				buffers["" .. bufnr] = {}
				buffers["" .. bufnr]["buffername"] = store_buffer_details["buffername"]
				buffers["" .. bufnr]["bufferpath"] = bufferpath

				-- HACK: Just dump all buffers in the first window of their tab
				local winnr = tabs["" .. store_buffer_details["tab"]]["windows"][1]
				local tabnr = store_buffer_details["tab"]
				buffers["" .. bufnr]["window"] = winnr

				-- Update windows, windows["buffers"] here
				if windows["" .. winnr]["buffers"] == nil then
					windows["" .. winnr]["buffers"] = {}
				end
				windows["" .. winnr]["buffers"][#windows["" .. winnr]["buffers"] + 1] = bufnr
				windows["" .. winnr]["tab"] = tabnr

				-- Update tabs["buffers"] here
				tabs["" .. tabnr]["buffers"][#tabs["" .. tabnr]["buffers"] + 1] = bufnr

				buffers["" .. bufnr]["tab"] = store_buffer_details["tab"]
				buffers["" .. bufnr]["key"] = store_buffer_details["key"]
				buffers["" .. bufnr]["key_idx"] = store_buffer_details["key_idx"]
			end
		end
	end

	Tabs = tabs
	Buffers = buffers
	Windows = windows
	Keys = data["Keys"]
end

function M.clear_data()
	Buffers = {}
	Windows = {}
	Tabs = {}
	Keys = {}
end

return M
