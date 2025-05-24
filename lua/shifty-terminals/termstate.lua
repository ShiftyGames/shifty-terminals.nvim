local config = require('shifty-terminals.config')

---@class shifty-terminals.TermState
---@field name string
---@field buf number
---@field win number
---@field cmd string?
---@field cwd string?
---@field default boolean
local TermState = {
    name = "",
    buf = -1,
    win = -1,
    cmd = nil,
    cwd = nil,
    default = false,
}

TermState.__tostring = function(t)
    local s = t["name"] .. " = { "
    local sep = ""
    for _, k in ipairs({ "buf", "win", "cmd", "cwd", "default" }) do
        s = s .. sep .. k .. "=" .. (t[k] or "nil")
        sep = ", "
    end
    return s .. " }"
end

---@return shifty-terminals.TermState
function TermState:new()
    self.__index = self
    return setmetatable({}, self)
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
    self.cmd = opts.cmd
end

function TermState:hide()
    if vim.api.nvim_win_is_valid(self.win) then
        vim.api.nvim_win_hide(self.win)
    end
end

function TermState:show()
    local cfg = config.get_cfg()[self.name]
    self:create_floating_window({
        cwd = cfg.cwd,
        cmd = cfg.cmd,
    })
    vim.api.nvim_win_call(self.win, function()
        if vim.bo[self.buf].buftype ~= "terminal" then
            vim.cmd.term()
            vim.keymap.set({ "t", "i", "n" }, "<ESC><ESC>",
                function()
                    self:hide()
                end,
                { buffer = true, }
            )
        end
        -- start in the terminal insert mode
        local keys = vim.api.nvim_replace_termcodes("<ESC>A", true, false, true)
        if self.cmd then
            local CR = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
            keys = keys .. self.cmd .. CR
        end
        vim.api.nvim_input(keys)
    end)
end

return TermState
