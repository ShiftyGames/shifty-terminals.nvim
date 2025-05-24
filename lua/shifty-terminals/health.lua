--- Make sure `shifty-terminals` will work as expected.
---
--- At minimum, we validate that the user's configuration is correct. But other
--- checks can happen here if needed.
---
local M = {}

--- Make sure `data` will work for `shifty-terminals`.
---
---@param data shifty-terminals.Configuration? All extra customizations for this plugin.
---
function M.check(data)
    data = data or vim.g.shifty_terminals

    vim.health.start("Configuration")

    local all_success = true
    local success, result = pcall(
        vim.validate,
        "data|vim.g.shifty_terminals",
        data,
        "table"
    )
    if not success then
        all_success = false
        vim.health.error(result or "")
    end

    if not data.terms then
        all_success = false
        vim.health.error(
            'config table is missing a field named "terms"\n'
            .. 'Expected a table of this form:\n'
            .. vim.inspect(require('shifty-terminals.config').default_cfg()) .. '\n'
            .. 'Your config table:\n'
            .. vim.inspect(data)
        )
    end

    if data.terms then
        local default = nil
        for k, v in pairs(data.terms) do
            if v.default then
                vim.health.ok("default term is defined: " .. k)
                default = k
            end
        end
        if not default then
            all_success = false
            vim.health.error('no default term is defined')
        end
    end

    if all_success then
        vim.health.ok("Your vim.g.shifty_terminals variable is great!")
    end
end

return M
