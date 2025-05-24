Features:
- [ ] add a 'cwd' field to set the directory of the shell before executing the command
- [x] update README.md
- [x] add more checks in health.check()
- [ ] add command-line completions for term names
- [ ] add logging

Bug Fixes:
- [x] fix the handling of config changes after startup
- [ ] fix the :ShiftyTerm enable <term_id> command

Refactor/Clean up:
- [-] refactor the 'toggle' logic out of M.enable
- [ ] change initialization strategy: consider moving 'current' to the state module
