local Config = {}

function Config.default_cfg()
    return {
        term = {
            default = true,
        },
    }
end

function Config.get_default_term()
    local cfg = vim.g.shifty_terminals or Config.default_cfg()
    for k, v in pairs(cfg) do
        if v.default then
            return k
        end
    end
    return next(cfg, nil)
end

return Config
