--- All function(s) that can be called externally by other Lua modules.
---
--- If a function's signature here changes in some incompatible way, this
--- package must get a new **major** version.
print("shifty-terminals.nvim/init.lua!!!")
local termstate = require('shifty-terminals.termstate')

local function table_find(tbl, value)
    for i, v in ipairs(tbl) do
        if v == value then
            return i
        end
    end
    return nil
end

local M = {}

--- @type table<string, TermState>
M.state = setmetatable({}, {
    __index = function(t, key)
        local instance = termstate.new()
        instance.name = key
        t[key] = instance
        return instance
    end
})

--- @type string?
local current = nil

--- @return string?
local _next = function()
--[[ 1st pass
    --current = next(M.state, current)
    --if not current then
    --    current = next(M.state, nil)
    --end
    --return current
--]]

--[[ 2nd pass
    local names = vim.g.shifty_terminals.names
    if #names == 0 then
        table.insert(vim.g.shifty_terminals.names, 0, 'default')
    end
    local current_idx = nil
    if current then
        current_idx = table_find(names, current)
    end
    local idx = next(names, current_idx)
    if not idx then
        --current = next(M.state, nil)
        idx = next(names, nil)
    end
    current = names[idx]
--    print('_next(): current = ' .. current)
    return current
--]]

    if current == nil then
        -- check for a default
        for k, v in pairs(vim.g.shifty_terminals) do
            if v.default then
                current = k
                return current
            end
        end
    end
    current = next(vim.g.shifty_terminals, current)
    if not current then
        current = next(vim.g.shifty_terminals, nil)
    end
    return current
end


local function create_floating_window(opts)
--    print("create_floating_window! opts=" .. tostring(opts))
    opts = opts or {}
    local width = opts.width or math.floor(vim.o.columns * 0.8)
    local height = opts.height or math.floor(vim.o.lines * 0.8)

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = nil
    if vim.api.nvim_buf_is_valid(opts.buf or -1) then
        buf = opts.buf
    else
        buf = vim.api.nvim_create_buf(false, true)
    end

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor', -- Relative to the entire editor
        row = row,           -- Vertical position
        col = col,           -- Horizontal position
        width = width,       -- Window width
        height = height,     -- Window height
        border = 'rounded',  -- Window border style
        style = 'minimal',   -- No status line, no number line
        title = opts.name,
        title_pos = 'center',
    })

    return { win = win, buf = buf, cmd = opts.cmd or nil }
end


--- @param instance TermState
local function toggle_terminal(instance)
--    print("toggle_terminal! (" .. instance.name .. ")")
    if not vim.api.nvim_win_is_valid(instance.win) then
        local new_instance = create_floating_window(instance) --  buf = instance.buf, cmd = instance.cmd })
        instance.win = new_instance.win
        instance.buf = new_instance.buf
        instance.cmd = new_instance.cmd
        if vim.bo[instance.buf].buftype ~= "terminal" then
            vim.cmd.term()
            vim.keymap.set({ "t", "i", "n" }, "<ESC><ESC>",
                function()
                    toggle_terminal(instance)
                end,
                { buffer = true, }
            )
        end
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<ESC>A", true, false, true),
            "ni",
            false
        )
        if instance.cmd then
            local CR = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
            vim.api.nvim_feedkeys(instance.cmd, "t", true)
            vim.api.nvim_feedkeys(CR, "t", false)
        end
    else
        vim.api.nvim_win_hide(instance.win)
    end
end


--- @param enable? boolean defaults to true
--- @param term_id? string  defaults to the current index
function M.enable(enable, term_id)
--    print('enable! args = ' .. vim.inspect({enable, term_id}))
    --enable = enable or true
    term_id = term_id or current or _next() or 'default' -- lol
    if not term_id then
        print("enable(): error, term_id and current are nil")
        return
    end
    local instance = M.state[term_id]
--    print('enable(): instance.name = ' .. instance.name)
    local is_active = vim.api.nvim_win_is_valid(instance.win)
    --vim.print({enable=enable, is_active=is_active})
    if enable ~= is_active then
        if current and current ~= term_id then
--            print("enable(): hiding the previous term...")
            M.enable(false, current)
        end
--        print('enable(): toggling instance ' .. tostring(instance))
        toggle_terminal(instance)
    end
    if enable then
        current = term_id
    end
end

function M.next()
--    print("next!")
    if current then
--        print("next(): current = " .. current .. ", disabling...")
        M.enable(false, current)
    end
--    print("next(): enabling next...")
    M.enable(true, _next())
end

local function table_keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, #keys+1, k)
    end
    return keys
end

function M.select()
    --local choices = table_keys(vim.g.shifty_terminals)
    local choices = {}
    for k,v in pairs(vim.g.shifty_terminals) do
        if v.default then
            table.insert(choices, 1, k)
        else
            table.insert(choices, #choices+1, k)
        end
    end
    vim.ui.select(choices, {
        --prompt = "pick one",
        format_item = function(item)
            return " " .. item
        end,
    }, function(choice)
        if choice then
            --print('you chose... poorly (' .. choice .. ')')
            M.enable(true, choice)
        end
    end)
end

return M
