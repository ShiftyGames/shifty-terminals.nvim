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
        data = vim.g.shifty_terminals or {}
        --data = vim.tbl_deep_extend("force", defaults, vim.g.shifty_terminals or {})
        --data = configuration_.resolve_data(vim.g.plugin_template_configuration)
    end

    --_LOGGER:debug("Running plugin-template health check.")
    vim.health.start("Configuration")

    local all_success = true
    local success, result = pcall(vim.validate, "vim.g.shifty_terminals", vim.g.shifty_terminals, "table")
    if not success then
        all_success = false
        vim.health.error(result or "")
    end

    -- TODO: check that /if/ vim.g.shifty_terminals is defined, then one of the
    -- terms is set as the 'default'
    --local success, result = pcall(???)

    if all_success then
        vim.health.ok("Your vim.g.shifty_terminals variable is great!")
    end
end

return M
