# fish — shell

fish with the `pure` prompt, `fisher` plugin manager, `eza` for ls. Bash
`.bashrc` (package `bash`) is minimal — interactive-only.

- `config.fish` sources `~/.config/.env` (untracked secrets, see the root
  `AGENTS.md`).
- On Linux `config.fish` prepends `~/.local/bin` to PATH via plain
  `set -gx` — never `fish_add_path`, whose universal `fish_user_paths` lands
  in the tracked `fish_variables` and would leak Linux paths into the mac.
  Helper scripts: package `scripts`.
- Fish never sources `.profile`, so XDG defaults get `set -q` guards via
  `conf.d/xdg.fish` (see `xdg/AGENTS.md`).
- The `logout` alias stops `graphical-login.target`, then runs
  `awesome-client 'awesome.quit()'` for a graceful WM shutdown; invoked
  directly and from the `tv power` Logout action via `fish -c` — no
  per-service `start`/`restart` calls anywhere, no helper scripts, no bare
  `awesome.quit` keybinding. Rejected alternatives and unit details:
  `systemd/AGENTS.md`.
