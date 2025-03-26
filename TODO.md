
## Store information for tabs and buffers(and windows)
- [x] add buffer, tab and window info on BufReadPost to buffer_list
- [x] remove buffer info on BufLeave
- [] Store btw information using a session manager(resession.nvim)

## Quick navigation between open buffers by using assigned keystrokes.
- [x] Assign keystrokes to buffers on BufReadPost
- [x] Have a quick navigation window/list that shows names and keystroke
- [x] Open bufs on keystrokes
- [x] Make window non-modifiable, and disable all other keystrokes apart from exit
- [x] Close window on exits

## Bugs
- [x] Handle closed windows and closed buffers ie. update Buffers table
- [] Handle buffers that miss buffername and bufferpath
- [] Assigning Random Key, and temporary name
- [] dap.txt help file is not removed from Buffers when closed(may have to do with bufnr assignment?)
- [] Handling No Name buffer - buffer edited when Nvim is opened initially
- [] Opeining LspInfo tab leads to error

## User Experience
- [x] Setting up highlighting colors for texts and floating window layout
- [] Custom configurations of opts
- [x] Even out the displays for buffer numbers
- [] Enable buffer selection using buffer numbers on BufferList
- [] Make shortcut keys replaceable with user defined options
- [] Disregard Uppercase letters if desired
- [] Enable naming of tabs
- [x] Handle buffer deletion
- [x] List needs to automatically expand depending on count of buffers
- [] Columned buffer list depending on tabs(and make it an optional setting)
- [x] What to display when there are no active buffers?
- [] Handle QuickFix List display(and any other that may exist for the same)
- [x] Handle invalid input. Currently transfers to editor if input is not in list
- [x] Handle empty bufferlist at start
- [x] Modifiable exit keys for users
- [x] How to handle Ctrl-C exit command
- [] Adding buffers that are opened when Neovim is started ie. "nvim new_file.txt"
- [x] Handling when a buffer is not on the BufferList is deleted?
- [] Handle buffer renaming
- [x] Handling window information for buffers

## User Opts Table
- [] Track Windows
- [] Use buffer numbers, assigned letters, both
- [] Use Uppercase
- [] Columned Bufferlist for different tabs
- [] Exit Keys

## Developer Experience
- [x] Organize the codebase into manageable modules
- [] Add function call to track Bufferlist hashmap

## Navigate open buffers appropriately based on where they were initially opened
- [] handle opening new buffers in preferred tabs based on cwd or quick buffer move to 
desired tab
- [] enable changing of selected tab
- [x] Update list of buffers and tables if moved from one to another
- [] Update list of buffers if already opened using session managers?

## Edge Cases
- [] What happens when the last buffer/window/tab is closed?
- [] Query which tab to use on opening a new buffer?
- [] Handling instances when no ASCII key is available to assign a buffer
- [] Add functionality that syncs Tabs, Windows and Buffers in the autocmds


