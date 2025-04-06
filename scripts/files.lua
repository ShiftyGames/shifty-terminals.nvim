local root_pkgpath = vim.fn.stdpath("data") .. "/site/pack/dev/opt/"
local pkgpath = vim.fs.joinpath(root_pkgpath, 'shifty-terminals.nvim')

local function mkdir_p(name)
    print('mkdir', name)
    if not vim.uv.fs_stat(name) then
        vim.cmd.mkdir(name, 'p')
    end
end

if not vim.uv.fs_stat(pkgpath) then
    local r = vim.cmd.mkdir(pkgpath, 'p')
    print('r = ' .. r)
end

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
            print('cp', name, vim.fs.joinpath(pkgpath, name))
        end
    end
end
