--- All function(s) that can be called externally by other Lua modules.
---
--- If a function's signature here changes in some incompatible way, this
--- package must get a new **major** version.
local state = require('shifty-terminals.state')
local config = require('shifty-terminals.config')
local default_cfg = config.default_cfg()

local M = {}

---@type string? The currently selected term
local current = nil

---@return string?
local _next = function()
    local cfg = vim.g.shifty_terminals or default_cfg
    if current == nil then
        return config.get_default_term()
    else
        local curr = next(cfg, current)
        if not curr then
            curr = next(cfg, nil)
        end
        return curr
    end
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

    return { win = win, buf = buf, cmd = opts.cmd }
end


---@param term_id? string defaults to the current index
local function get_term_cmd(term_id)
    term_id = term_id or current
    if not term_id then
        return nil
    end
    if not vim.g.shifty_terminals then
        return nil
    end
    if not vim.g.shifty_terminals[term_id] then
        return nil
    end
    return vim.g.shifty_terminals[term_id].cmd
end

---@param instance TermState
local function hide(instance)
    if vim.api.nvim_win_is_valid(instance.win) then
        vim.api.nvim_win_hide(instance.win)
    end
end

---@param instance TermState
local function show(instance)
    local new_instance = create_floating_window(instance)
    instance.win = new_instance.win
    instance.buf = new_instance.buf
    instance.cmd = new_instance.cmd
    print('  show(instance) win =', instance.win)
    if vim.bo[instance.buf].buftype ~= "terminal" then
        vim.cmd.term()
        vim.keymap.set({ "t", "i", "n" }, "<ESC><ESC>",
            function()
                print('hiding terminal')
                hide(instance)
            end,
            { buffer = true, }
        )
    end
    -- start in the terminal insert mode
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
end

---@param term_id? string defaults to the current index
function M.toggle(term_id)
    term_id = term_id or current or _next()
    assert(type(term_id) == 'string')
    local instance = state.get(term_id)
    if vim.api.nvim_win_is_valid(instance.win) then
        hide(instance)
    else
        instance.cmd = get_term_cmd(term_id)
        show(instance)
        current = term_id
    end
end

---@param enable boolean
---@param term_id? string defaults to the current index
function M.enable(enable, term_id)
    term_id = term_id or current or _next()
    assert(term_id, "could not determine the term_id, see :che shifty-terminals")
    local next_instance = state.get(term_id)
    local is_next_active = vim.api.nvim_win_is_valid(next_instance.win)
    if (not enable) or (enable ~= is_next_active) then
        -- disable the current term, if different than the requested term
        if current and current ~= term_id then
            hide(state.get(current))
        end
    end
    if enable and not is_next_active then
        next_instance.cmd = get_term_cmd(term_id)
        show(next_instance)
        current = term_id
    end
end

function M.next()
    local next_term = _next()
    if next_term == current then
        return
    end
    M.enable(true,next_term)
end

function M.select()
    local cfg = vim.g.shifty_terminals or default_cfg
    local choices = {}
    for k, v in pairs(cfg) do
        if v.default then
            table.insert(choices, 1, k)
        else
            table.insert(choices, #choices + 1, k)
        end
    end
    vim.ui.select(choices, {
        format_item = function(item)
            return " " .. item
        end,
    }, function(choice)
        print('choice =', choice)
        if choice then
            M.enable(true, choice)
        else
            print('no choice was made')
        end
    end)
end

return M
