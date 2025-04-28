--- All function(s) that can be called externally by other Lua modules.
---
--- If a function's signature here changes in some incompatible way, this
--- package must get a new **major** version.
print("shifty-terminals.nvim/init.lua!!!")
local termstate = require('shifty-terminals.termstate')

local default_cfg = {
    default = {}
}

local M = {}

--- @type table<string, TermState>
M.state = setmetatable({}, {
    __index = function(t, key)
        local cfg = vim.g.shifty_terminals or default_cfg
        local instance = termstate.new()
        instance.name = key
        instance.cmd = cfg[key] and cfg[key].cmd or nil
        t[key] = instance
        return instance
    end
})

--- @type string?
local current = nil

--- @return string?
local _next = function()
    local cfg = vim.g.shifty_terminals or default_cfg
    if current == nil then
        -- check for a default
        for k, v in pairs(cfg) do
            if v.default then
                current = k
                return current
            end
        end
    end
    current = next(cfg, current)
    if not current then
        current = next(cfg, nil)
    end
    return current
end


local function create_floating_window(opts)
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
    if not vim.api.nvim_win_is_valid(instance.win) then
        local new_instance = create_floating_window(instance)
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
--- @param term_id? string defaults to the current index
function M.enable(enable, term_id)
    term_id = term_id or current or _next() or 'default' -- lol
    if not term_id then
        print("enable(): error, term_id and current are nil")
        return
    end
    local instance = M.state[term_id]
    local is_active = vim.api.nvim_win_is_valid(instance.win)
    if enable ~= is_active then
        if current and current ~= term_id then
            M.enable(false, current)
        end
        toggle_terminal(instance)
    end
    if enable then
        current = term_id
    end
end

function M.next()
    if current then
        M.enable(false, current)
    end
    M.enable(true, _next())
end

function M.select()
    local cfg = vim.g.shifty_terminals or default_cfg
    local choices = {}
    for k,v in pairs(cfg) do
        if v.default then
            table.insert(choices, 1, k)
        else
            table.insert(choices, #choices+1, k)
        end
    end
    vim.ui.select(choices, {
        format_item = function(item)
            return " " .. item
        end,
    }, function(choice)
        if choice then
            M.enable(true, choice)
        end
    end)
end

return M
