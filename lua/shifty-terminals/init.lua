--- All function(s) that can be called externally by other Lua modules.
---
--- If a function's signature here changes in some incompatible way, this
--- package must get a new **major** version.
local state = require('shifty-terminals.state')
local config = require('shifty-terminals.config')

local M = {}

---@type string? The currently selected term
local current = nil

---@return string?
local _next = function()
    local cfg = config.get_cfg()
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


---@param term_id? string defaults to the current index
local function get_term_cmd(term_id)
    term_id = term_id or current
    if not term_id then
        return nil
    end
    local cfg = config.get_cfg()
    if not cfg[term_id] then
        return nil
    end
    return cfg[term_id].cmd
end

---@param term_id? string defaults to the current index
function M.toggle(term_id)
    term_id = term_id or current or _next()
    assert(type(term_id) == 'string')
    local instance = state.get(term_id)
    if vim.api.nvim_win_is_valid(instance.win) then
        instance:hide()
    else
        instance.cmd = get_term_cmd(term_id)
        instance:show()
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
            state.get(current):hide()
        end
    end
    if enable and not is_next_active then
        next_instance.cmd = get_term_cmd(term_id)
        next_instance:show()
        current = term_id
    end
end

function M.next()
    local next_term = _next()
    if next_term == current then
        return
    end
    M.enable(true, next_term)
end

function M.select()
    local cfg = config.get_cfg()
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
        if choice then
            M.enable(true, choice)
        end
    end)
end

return M
