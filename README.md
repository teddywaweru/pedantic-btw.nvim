## Pedantic Buffers, Tabs and Windows
Navigating through Buffers, Tabs, Windows and maintaining their opened positions
Buffer, Tabs and Windows context is maintained while switching between open buffers.
It's regarded pedantic in terms of the placement of buffers and windows relative to their Tabs, and Windows

Motivation:
Sometimes I had to work on projects that have several sub-sections, and some have similarly named files. Having these buffers separated makes it easier to navigate the opened buffers without mixing up.
Also, places all buffers switches within a keystroke(disregarding the keymap to open the bufferlist)


To enable on Lazy Plugin Manager

```viml
{
  "teddywaweru/pedantic-btw.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
  {
    'gj', '<cmd>lua require("pedantic-btw").buffer_list()<CR>', 'n', desc = "Open Buffer List" }
  },
}
```
