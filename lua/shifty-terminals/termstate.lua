local M = {}

--- @class TermState
--- @field name string
--- @field buf number
--- @field win number
--- @field cmd string?
local TermState = {
    __tostring = function(t)
        local s = t["name"] .. " = { "
        local sep = ""
        for _, k in ipairs({ "buf", "win", "cmd", "default"}) do
            s = s .. sep .. k .. "=" .. (t[k] or "nil")
            sep = ", "
        end
        return s .. " }"
        --return "{ name=" .. t.name .. ", buf=" .. t.buf .. ", win=" .. t.win .. ", cmd=" .. t.cmd .. "}"
    end
}

function M.new()
    return setmetatable({
        name = "",
        buf = -1,
        win = -1,
        cmd = nil,
        default = false,
    }, TermState)
end

return M

--[[

local index = nil
local t = setmetatable({}, {
    __index = function(t, key)
        --print("calling __index")
        local instance = M.new()
        instance.name = key
        t[key] = instance
        return instance
    end,
})

local _next = function()
    index = next(t, index)
    if not index then
        index = next(t, nil)
    end
    return index
end

t_tostring = function(t)
    local s = "{"
    local sep = "\n  "
    for k,v in pairs(t) do
        s = s .. sep .. tostring(v)
        sep = ",\n  "
    end
    return s .. "\n}"
    --return "{ name=" .. t.name .. ", buf=" .. t.buf .. ", win=" .. t.win .. ", cmd=" .. t.cmd .. "}"
end

print(t)
print("t="..t_tostring(t))
print('next(t, '.. tostring(index) .. ') = ' .. tostring(_next()))
print(t.default)
print(t["default"])
print(t.build)
local count = 0; for k in pairs(t) do count = count+ 1 end
print("count = " .. count)
print(t)
print("t="..t_tostring(t))

--local index = nil
print('next(t, '.. tostring(index) .. ') = ' .. tostring(_next()))
print('next(t, '.. tostring(index) .. ') = ' .. tostring(_next()))
print('next(t, '.. tostring(index) .. ') = ' .. tostring(_next()))

--for n in pairs(_G) do print(n) end

]] --
