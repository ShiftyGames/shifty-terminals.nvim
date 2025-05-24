--- A collection of types to be included / used in other Lua files.
---
--- These types are either required by the Lua API or required for the normal
--- operation of this Lua plugin.
---

---@class shifty-terminals.Configuration
---    The configuration stored in vim.g.shifty_terminals
---@field terms table<string, shifty-terminals.TermConfig>

---@class shifty-terminals.TermConfig
---@field cmd string? the command to execute upon opening the terminal
---@field cwd string? the path to set the current working directory to before executing the cmd
---@field default boolean?


---@class shifty-terminals.state.WindowOpts
---@field cmd string
---@field cwd string
