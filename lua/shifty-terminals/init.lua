--- All function(s) that can be called externally by other Lua modules.
---
--- If a function's signature here changes in some incompatible way, this
--- package must get a new **major** version.
print("shifty-terminals.nvim/init.lua!!!")
local M = {}

M.items = { "build", "test", "other" }

return M
