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
end
M.config = function()
	print("Initialize config")
end

return M
