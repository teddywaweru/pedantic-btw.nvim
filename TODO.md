
## Store information for tabs and buffers(and windows)
- [x] add buffer, tab and window info on BufReadPost to buffer_list
- [x] remove buffer info on BufLeave
- [] Store btw information using a session manager(resession.nvim)

## Quick navigation between open buffers by using assigned keystrokes.
- [x] Assign keystrokes to buffers on BufReadPost
- [x] Have a quick navigation window/list that shows names and keystroke
- [x] Open bufs on keystrokes
- [x] Make window non-modifiable, and disable all other keystrokes apart from exit
- []Close window on exits

## User Experience
- [x] Setting up highlighting colors for texts and floating window layout
- [] Custom configurations of opts
- [x] Even out the displays for buffer numbers
- [] Make shortcut keys replaceable with user defined options
- [] Disregard Uppercase letters if desired
- [] Enable naming of tabs
- [x] Handle buffer deletion
- [x] List needs to automatically expand depending on count of buffers
- [] Separate buffer list depending on their tabs(and make it an optional setting)
- [] What to display when there are no active buffers?
- [] Handle QuickFix List display(and any other that may exist for the same)

## Developer Experience
- [x]Organize the codebase into manageable modules
- [] Add function call to track Bufferlist hashmap

## Navigate open buffers appropriately based on where they were initially opened
- [] handle opening new buffers in preferred tabs based on cwd or quick buffer move to 
desired tab
- [] enable changing of selected tab
- [] Update list of buffers and tables if moved from one to another
- [] Update list of buffers if already opened using session managers?

## Edge Cases
- [] What happens when the last buffer/window/tab is closed?
- [] Query which tab to use on opening a new buffer?


