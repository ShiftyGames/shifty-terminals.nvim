Features:
- [ ] add a 'cwd' field to set the directory of the shell before executing the command
- [ ] update README.md
- [ ] add more checks in health.check()
- [ ] add command-line completions for term names

Bug Fixes:
- [x] fix the handling of config changes after startup
- [ ] fix the :ShiftyTerm enable <term_id> command

Refactor/Clean up:
- [-] refactor the 'toggle' logic out of M.enable
- [ ] change initialization strategy: consider moving 'current' to the state module
