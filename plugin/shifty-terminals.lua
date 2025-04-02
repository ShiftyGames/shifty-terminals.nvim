print("hello plugin/shifty_terminals.lua")
local _PREFIX = 'ShiftyTerm'

vim.api.nvim_create_user_command(_PREFIX,
  function(_)
    if vim.g.shifty_terminals.name then
      print("hello " .. vim.g.shifty_terminals.name)
    end
  end,
  { desc = "Just saying hello" }
)
