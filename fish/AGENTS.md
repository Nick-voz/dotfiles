# fish — shell

fish with the `pure` prompt, `fisher` plugin manager, `eza` for ls. Bash
`.bashrc` (package `bash`) is minimal — interactive-only.

- `config.fish` sources `~/.config/.env` (untracked secrets, see the root
  `AGENTS.md`).
- `config.fish` prepends `~/.local/bin` (stow package `scripts` to both
  Linux and the mac) to PATH via plain `set -gx` — never `fish_add_path`,
  whose universal `fish_user_paths` lands in the tracked `fish_variables`
  and would leak machine-specific PATH order into the other shell.
  Helper scripts: package `scripts`.
- `update`: Linux → `sudo pacman -Syu --noconfirm` (the identical vendor
  alias in `cachyos-config.fish` is overridden by `config.fish`, vendor
  file left pristine). `--noconfirm` skips the "Proceed with
  installation?" prompt; pacman 7.1 has no narrower flag (no
  `--no-install-confirmation`, no `NoInstallConfirmation` in
  `pacman.conf`), so it also auto-answers any other sync prompt — conflict
  resolution, PGP key import. Manual `pacman -S/-R` calls stay
  interactive. macOS → function: `sudo -v` authenticates once up front and
  exported `HOMEBREW_SUDO_CHECKED=1` makes brew skip its startup
  `sudo --reset-timestamp` (Homebrew `utils/sudo.sh`), so pkg/dmg casks
  reuse the ticket instead of prompting mid-run; if the sudo timeout
  (~5 min) lapses mid-run brew prompts once anyway. Brew itself is
  never run under sudo — prefix is user-owned, root-owned files would
  break later runs. Homebrew 7 enables "ask mode" by default (y/N before
  installs/upgrades); `config.fish` exports `HOMEBREW_NO_ASK=1`, so no y/N
  prompts exist in the chain (explicit `--ask` still prompts). Exported
  `HOMEBREW_NO_ENV_HINTS=1` silences the post-command "Hide these
  hints" notes. Enabling Touch ID for sudo in System Settings
  turns any remaining prompt into a fingerprint scan.
- `tv power` → Update runs the alias in a fresh plain kitty window:
  `fish -C update` (config read, prompt stays afterwards) through
  `tv/.config/television/scripts/update-window.sh` — mechanics in
  `tv/AGENTS.md`.
- Fish never sources `.profile`, so XDG defaults get `set -q` guards via
  `conf.d/xdg.fish` (see `xdg/AGENTS.md`).
- The `logout` alias stops `graphical-login.target`, then runs
  `awesome-client 'awesome.quit()'` for a graceful WM shutdown; invoked
  directly and from the `tv power` Logout action via `fish -c` — no
  per-service `start`/`restart` calls anywhere, no helper scripts, no bare
  `awesome.quit` keybinding. Rejected alternatives and unit details:
  `systemd/AGENTS.md`.
