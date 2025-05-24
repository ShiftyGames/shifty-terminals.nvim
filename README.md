# Installation

- [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
    "ShiftyGames/shifty-terminals.nvim",
    --version = "0.1.*",
}
```

- [rocks.nvim](https://github.com/rocks.nvim)
```vim
:Rocks install rocks-git.nvim
:Rocks install ShiftyGames/shifty-terminals.nvim
```

# Configuration
(These are default values)
```lua
vim.g.shifty_terminals = {
    terms = {
        term = {
            default = true,
            cwd = nil,
            cmd = nil,
        },
    },
}
```

Example user config - put in a project's .nvim.lua (see `:h exrc`) or in your
nvim/init.lua
```lua
vim.g.shifty_terminals = {
    terms = {
        build = { default = true }, -- no cmd, good for manual commands
        webserver = {
            -- Automatically run a webserver. The process continues running in
            -- the background even when the terminal is hidden.
            cmd = "node run dev",
        },
        test_blog = {
            cwd = '../_site',
            cmd = "bundle exec jekyll s",
        },
    },
}
```
