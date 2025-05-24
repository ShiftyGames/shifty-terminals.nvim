local Config = {}

function Config.default_cfg()
    return {
        term = {
            default = true,
        },
    }
end

function Config.get_default_term()
    local cfg = vim.g.shifty_terminals.terms or Config.default_cfg()
    for k, v in pairs(cfg) do
        if v.default then
            return k
        end
    end
    return next(cfg, nil)
end

function Config.get_cfg()
    if vim.g.shifty_terminals and vim.g.shifty_terminals.terms then
        return vim.g.shifty_terminals.terms
    else
        return Config.default_cfg()
    end
end
return Config
