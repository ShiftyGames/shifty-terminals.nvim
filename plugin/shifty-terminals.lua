--print("hello plugin/shifty_terminals.lua")
local _PREFIX = 'ShiftyTerm'

vim.api.nvim_create_user_command(_PREFIX,
    function(opts)
        --print('func called with opts=', vim.inspect(opts))
        if opts.fargs[1] == 'enable' then
            require('shifty-terminals').enable()
        elseif opts.fargs[1] == 'next' then
            require('shifty-terminals').next()
        elseif opts.fargs[1] == 'select' then
            require('shifty-terminals').select()
        end
    end,
    {
        nargs = 1,
        desc = "TODO FIXME",
        complete = function(_, _, _)
            return { "enable", "next", "select" }
        end,
    }
)

vim.keymap.set({ "n" },
    "<Plug>(ShiftyTerminalsNext)",
    function()
        require('shifty-terminals').next()
    end
)

vim.keymap.set({ "n" },
    "<Plug>(ShiftyTerminalsEnable)",
    function()
        require('shifty-terminals').enable()
    end
)

vim.keymap.set({ "n" },
    "<Plug>(ShiftyTerminalsSelect)",
    function()
        require('shifty-terminals').select()
    end
)
