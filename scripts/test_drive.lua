-- USAGE:
--  nvim -u ./scripts/test_drive.lua

-- cd ~/.local/share/nvim-data/
-- mkdir site/pack/dev/opt/
-- cp -R C:/Users/shift/src/shifty-terminals.nvim ~/.local/share/nvim-data/site/pack/dev/opt/
-- :packadd shifty-terminals.nvim

local pkgpath = vim.fn.stdpath("data") .. "/site/pack"
print("pkgpath is " .. pkgpath)

vim.g.shifty_terminals = {
    names = {
        "beans",
        "test",
        "server",
    },
}

print("calling packadd...")
vim.cmd [[packadd shifty-terminals.nvim]]
vim.cmd [[checkhealth shifty-terminals]]

local shterms = require('shifty-terminals')
print(shterms.items)

vim.ui.select(shterms.items, {
    prompt = "pick one",
    format_item = function(item)
        return "I want " .. item
    end,
}, function(choice)
    if choice then
        print('you chose... poorly (' .. choice .. ')')
    end
end)
