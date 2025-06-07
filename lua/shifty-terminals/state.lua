local termstate = require('shifty-terminals.termstate')

local State = {}

---@type table<string, shifty-terminals.TermState>
State.terms = setmetatable({}, {
    __index = function(t, key)
        local instance = termstate.new(key)
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
