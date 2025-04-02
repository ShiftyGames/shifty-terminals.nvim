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
    if not data or vim.tbl_isempty(data) then
        local defaults = {} -- TODO
        data = vim.tbl_deep_extend("force", defaults, vim.g.shifty_terminals or {})
        --data = configuration_.resolve_data(vim.g.plugin_template_configuration)
    end

    --_LOGGER:debug("Running plugin-template health check.")
    vim.health.start("Configuration")

    local success, result = pcall(vim.validate, "names", data.names, "table")
    if not success then
        vim.health.error(result or "")
    else
        vim.health.ok("Your vim.g.shifty_terminals variable is great!")
    end
end

return M
