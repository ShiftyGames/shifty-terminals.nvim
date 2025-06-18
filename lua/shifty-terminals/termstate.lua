---@class shifty-terminals.TermState
---@field name string
---@field buf number
---@field win number
---@field cmd string?
---@field cwd string?
---@field oneshot boolean
---@field default boolean
local TermState = {}

local default_termstate = {
    name = "",
    buf = -1,
    win = -1,
    cmd = nil,
    cwd = nil,
    oneshot = false,
    default = false,
}

TermState.__tostring = function(t)
    local s = t["name"] .. " = { "
    local sep = ""
    for _, k in ipairs({ "buf", "win", "cmd", "cwd", "oneshot", "default" }) do
        s = s .. sep .. k .. "=" .. tostring(t[k])
        sep = ", "
    end
    return s .. " }"
end

local function new_mt(name)
    assert(name, "table t must have a name!")
    assert(type(name) == "string", "name must be a string")
    return {
        __tostring = TermState.__tostring,
        __index = function(_, key)
            if TermState[key] ~= nil then
                return TermState[key]
            end
            if vim.g.shifty_terminals.terms ~= nil
                and vim.g.shifty_terminals.terms[name] ~= nil
                and vim.g.shifty_terminals.terms[name][key] ~= nil
            then
                return vim.g.shifty_terminals.terms[name][key]
            else
                return default_termstate[key]
            end
        end,
    }
end

---@param name string
---@return shifty-terminals.TermState
function TermState.new(name)
    assert(name, "must provide a name")
    assert(type(name) == "string", "name must be a string")
    local instance = { name = name }
    return setmetatable(instance, new_mt(name))
end

---@param opts shifty-terminals.state.WindowOpts
function TermState:create_floating_window(opts)
    opts = opts or {}
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)

    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    if not vim.api.nvim_buf_is_valid(self.buf or -1) then
        self.buf = vim.api.nvim_create_buf(false, true)
    end

    self.win = vim.api.nvim_open_win(self.buf, true, {
        relative = 'editor', -- Relative to the entire editor
        row = row,           -- Vertical position
        col = col,           -- Horizontal position
        width = width,       -- Window width
        height = height,     -- Window height
        border = 'rounded',  -- Window border style
        style = 'minimal',   -- No status line, no number line
        title = " " .. self.name,
        title_pos = 'center',
    })
end

function TermState:hide()
    if vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_hide(self.win)
    end
end

function TermState:show()
    self:create_floating_window({
        -- TODO: user configurable options
    })

    vim.api.nvim_win_call(
        self.win,
        function()
            local firstpass = false
            if vim.bo[self.buf].buftype ~= "terminal" then
                firstpass = true
                vim.cmd.term()
                vim.cmd.startinsert()
                if self.cwd then
                    vim.api.nvim_input(
                        vim.api.nvim_replace_termcodes(
                            "cd " .. self.cwd .. "<CR>",
                            true, false, true)
                    )
                end
                vim.keymap.set(
                    { "t", "i", "n" },
                    "<ESC><ESC>",
                    function()
                        self:hide()
                    end,
                    { buffer = true, }
                )
            end
            -- start in the terminal insert mode
            vim.cmd.startinsert()
            if self.cmd then
                -- Launch the cmd. If oneshot is true, only run the cmd on the
                -- first pass (the first time the window is opening)
                if firstpass or not self.oneshot then
                    local CR = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
                    vim.api.nvim_input(self.cmd .. CR)
                end
            end
        end
    )
end

return TermState
