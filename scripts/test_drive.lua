-- USAGE:
--  nvim -u ./scripts/test_drive.lua

-- mkdir ~/.local/share/nvim-data/site/pack/dev/opt/
-- cp -R C:/Users/shift/src/shifty-terminals.nvim ~/.local/share/nvim-data/site/pack/dev/opt/
-- nvim -u ./scripts/test_drive.lua
-- :packadd shifty-terminals.nvim

local function mkdir_p(name)
    print('mkdir', name)
    if not vim.uv.fs_stat(name) then
        vim.fn.mkdir(name, 'p')
    end
end

local function copyFile(source, destination)
    -- Open the source file in read mode
    local srcFile, err = io.open(source, "rb") -- 'rb' mode to read binary data
    if not srcFile then
        print("Error opening source file: " .. err)
        return
    end

    -- Open the destination file in write mode
    local destFile, err = io.open(destination, "wb") -- 'wb' mode to write binary data
    if not destFile then
        print("Error opening destination file: " .. err)
        srcFile:close()
        return
    end

    -- Copy the content from source to destination
    local content = srcFile:read("*all") -- Read all content from the source file
    destFile:write(content)              -- Write content to the destination file

    -- Close both files
    srcFile:close()
    destFile:close()

    --print("File copied successfully!")
end

vim.g.mapleader = " "

local root_pkgpath = vim.fn.stdpath("data") .. "/site/pack/dev/opt/"
local pkgpath = vim.fs.joinpath(root_pkgpath, 'shifty-terminals.nvim')
print("pkgpath is " .. pkgpath)

if vim.uv.fs_stat(pkgpath) then
    vim.fs.rm(pkgpath, { recursive = true })
end
mkdir_p(pkgpath)
for name, type in vim.fs.dir('.', { depth = 10, }) do
    --print('name', name, ', type', type)
    if type == 'directory' then
        if string.match(name, '%.git.*') == nil then
            mkdir_p(vim.fs.joinpath(pkgpath, name))
        end
    end
    if type == 'file' then
        --vim.print(string.match(name, '%.git.*'))
        if string.match(name, '%.git.*') == nil then
            --print('cp', name, vim.fs.joinpath(pkgpath, name))
            copyFile(name, vim.fs.joinpath(pkgpath, name))
        end
    end
end

vim.g.shifty_terminals = {
    beans = {},
    test = {},
    server = {},
}

--local m = {
--    s = "out"
--}
--local function f(arg)
--    arg.s = "in"
--end
--print('m.s =', m.s)
--f(m)
--print('f(m) => s =', m.s)

print("calling packadd...")
vim.cmd [[packadd! shifty-terminals.nvim]]
print("calling checkhealth")
vim.cmd [[checkhealth shifty-terminals]]
print("checkhealth complete")


print("set keymap...")
vim.keymap.set({ "n" },
    '<localleader>n',
    '<Plug>(ShiftyTerminalsNext)'
)
vim.keymap.set({ "t" },
    '<localleader>n',
    '<C-\\><C-n><Plug>(ShiftyTerminalsNext)'
)
vim.keymap.set({ "n" },
    '<localleader>t',
    '<Plug>(ShiftyTerminalsEnable)'
)
print("----COMPLETE----")

--local shterms = require('shifty-terminals')
--print(shterms.items)
--
--vim.ui.select(shterms.items, {
--    prompt = "pick one",
--    format_item = function(item)
--        return "I want " .. item
--    end,
--}, function(choice)
--    if choice then
--        print('you chose... poorly (' .. choice .. ')')
--    end
--end)
