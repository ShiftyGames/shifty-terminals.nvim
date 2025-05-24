-- USAGE:
--  $Env:NVIM_APPNAME = 'nvim-test-terms'
--  nvim -u ./scripts/test_drive.lua

-- mkdir ~/.local/share/nvim-data/site/pack/dev/opt/
-- cp -R C:/Users/shift/src/shifty-terminals.nvim ~/.local/share/nvim-data/site/pack/dev/opt/
-- nvim -u ./scripts/test_drive.lua
-- :packadd shifty-terminals.nvim

local function mkdir_p(name)
    --print('mkdir', name)
    if not vim.uv.fs_stat(name) then
        vim.fn.mkdir(name, 'p')
    end
end

local function copyFile(source, destination)
    -- Open the source file in read mode
    local srcFile, err = io.open(source, "rb") -- 'rb' mode to read binary data
    if not srcFile then
        vim.notify("Error opening source file: " .. err)
        return
    end

    -- Open the destination file in write mode
    local destFile, err = io.open(destination, "wb") -- 'wb' mode to write binary data
    if not destFile then
        vim.notify("Error opening destination file: " .. err)
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
vim.notify("pkgpath is " .. pkgpath)

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
            --print('cp   ', vim.fs.joinpath(pkgpath, name))
            copyFile(name, vim.fs.joinpath(pkgpath, name))
        end
    end
end

vim.g.shifty_terminals = {
    terms = {
        beans = {},
        test = {
            default = true,
            cmd = "echo Hello",
        },
        server = {},
    }
}

vim.notify("calling packadd...")
vim.cmd [[ packadd! shifty-terminals.nvim ]]
--vim.cmd [[ checkhealth shifty-terminals ]]
--vim.cmd.messages()

vim.notify("set keymap...")
vim.keymap.set({ "n" },
    '<localleader>n',
    '<Plug>(ShiftyTerminalsNext)'
)
vim.keymap.set({ "t" },
    '<localleader>n',
    '<C-\\><C-n><Plug>(ShiftyTerminalsNext)'
)
vim.keymap.set({ "n", "t" },
    '<leader>t',
    '<Plug>(ShiftyTerminalsToggle)'
)
vim.keymap.set({ "n", "t" },
    '<localleader>s',
    '<Plug>(ShiftyTerminalsSelect)'
)


-- lol, this is silly
local function chain_schedule(...)
    local function _r(s, f, ...)
        f(s)
        local fs = { ... }
        if #fs > 0 then
            vim.schedule(function() _r(s, unpack(fs)) end)
        end
    end
    local stack = {}
    _r(stack, ...)
end

local function run_test()
    --[
    chain_schedule(
        function(s)
            vim.notify('f1')
            require('shifty-terminals').toggle()
            s.orig_buf = require('shifty-terminals.state').get('test').buf
            assert(s.orig_buf > 0)
        end,
        function(_)
            vim.notify('f2')
            require('shifty-terminals').toggle()
        end,
        function(s)
            vim.notify('f3')
            require('shifty-terminals').toggle()
            assert(require('shifty-terminals.state').get('test').buf > 0)
            assert(require('shifty-terminals.state').get('test').buf == s.orig_buf)
            vim.notify('assert success!')
        end,
        function()
            vim.notify('f10')
            require('shifty-terminals').toggle()
        end,
        function()
            vim.notify("----COMPLETE----")
        end
    )
    --]]
    --[[
vim.schedule(function()
    st.toggle()
    local state = require('shifty-terminals.state')
    local inst = state.get('test')
    local buf = inst.buf
    assert(buf > 0)
    vim.schedule(function()
        st.toggle()
        vim.schedule(function()
            st.toggle()
            vim.schedule(function()
                assert(buf == state.get('test').buf)
                vim.notify('assert success!')
            end)
        end)
    end)
end)
--]]
end

vim.api.nvim_create_user_command("ShiftyTest", run_test, {})
