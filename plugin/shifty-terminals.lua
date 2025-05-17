local _PREFIX = 'ShiftyTerm'

-- Command interface
vim.api.nvim_create_user_command(_PREFIX,
    function(opts)
        --print('func called with opts=', vim.inspect(opts))
        if opts.fargs[1] == 'enable' then
            require('shifty-terminals').enable(true, opts.fargs[2])
        elseif opts.fargs[1] == 'next' then
            require('shifty-terminals').next()
        elseif opts.fargs[1] == 'select' then
            require('shifty-terminals').select()
        elseif opts.fargs[1] == 'toggle' then
            require('shifty-terminals').toggle()
        end
    end,
    {
        nargs = 1,
        desc = "TODO FIXME",
        complete = function(_, _, _)
            return { "enable", "next", "select", "toggle" }
        end,
    }
)

-- Key Mappings
vim.keymap.set({ "n" },
    "<Plug>(ShiftyTerminalsNext)",
    function()
        require('shifty-terminals').next()
    end
)

vim.keymap.set({ "n" },
    "<Plug>(ShiftyTerminalsToggle)",
    function()
        require('shifty-terminals').toggle()
    end
)

vim.keymap.set({ "n" },
    "<Plug>(ShiftyTerminalsSelect)",
    function()
        require('shifty-terminals').select()
    end
)
