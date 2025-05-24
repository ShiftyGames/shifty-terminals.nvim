local termstate = require('shifty-terminals.termstate')
local default_cfg = require('shifty-terminals.config').default_cfg()

local State = {}

---@type table<string, shifty-terminals.TermState>
State.terms = setmetatable({}, {
    __index = function(t, key)
        local cfg = vim.g.shifty_terminals.terms or default_cfg
        local instance = termstate:new()
        instance.name = key
        instance.cmd = cfg[key] and cfg[key].cmd or nil
        t[key] = instance
        return instance
    end
})

---@param term_id string
---@return shifty-terminals.TermState
function State.get(term_id)
    return State.terms[term_id]
end

return State
