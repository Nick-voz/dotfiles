# dotfiles

Linux (CachyOS/Arch) dotfiles managed with GNU Stow. Not a software project — no build/test/lint/CI.

## Stow layout

Each top-level directory is a Stow package. Run from repo root:

```
stow <package>
```

This symlinks `./<package>/.config/<app>/...` → `~/.config/<app>/...`. Example: `stow nvim` links `nvim/.config/nvim/` → `~/.config/nvim/`.

Packages: `awesome`, `bash`, `clipcat`, `fish`, `fonts`, `gtk`, `kitty`, `nvim`, `pandoc`, `picom`, `systemd`, `tv`, `opencode`, `xdg`, `xprofile`.

## Key facts

- **Shell**: fish with `pure` prompt, `fisher` plugin manager, `eza` for ls. Bash `.bashrc` is minimal (interactive-only).
- **WM**: AwesomeWM with Catppuccin Mocha theme, `Mod4` as primary key. No in-`rc.lua` autostart; two-phase systemd startup: infra (picom, clipcatd, xremap) as user units `WantedBy=graphical-session.target`, pulled in via the `graphical-login.target` wrapper from `~/.xprofile`; GUI apps (throne, telegram, discord, steam, superproductivity, firefox, obsidian) as units `WantedBy=graphical-apps.target`, started by a hook at the end of `rc.lua` so they never race WM init (cursor theme, EWMH, tray). All app units use `Restart=always` + `StartLimitIntervalSec=0` — a closed window comes back; stop for real with `systemctl --user stop <name>`. discord additionally waits for `throne-tun` via `ExecStartPre` + `Wants=throne.service` (start ordering only, no stop propagation). nm-applet/blueman-applet are intentionally not installed (Wi-Fi via `tv wifi` + nmcli, BT via bluetoothctl).
- **Terminal**: kitty, exported once as `TERMINAL` from `xdg/.profile` (SDDM sources it before Awesome, so GUI shells inherit it); `rc.lua` and tv channels fall back to `kitty` when unset (TTY/ssh).
- **Editor**: nvim (LazyVim) with extras: mini-surround, mini-move, json, markdown, python, toml. Stylua format: spaces, indent 2, width 120.
- **Launcher**: tv channels. Brightness, clipboard (clipcat via `tv clipboard`), power and wifi live in `tv` channels. Firefox bookmarks moved to `tv bookmarks` (foxmarks + xdg-open), launched from `tv menu`. Web search is a `web-search.sh` helper under `tv/.config/television/scripts/`, launched from `tv menu`.
- **TV**: television terminal viewer with extensive channel configs under `tv/.config/television/cable/`.
- **Pandoc**: Eisvogel template files under `pandoc/.local/share/pandoc/templates/` — symlinked to `~/.local/share/pandoc/templates/` (not `.config`).
- **Secrets**: `~/.config/.env` is sourced by bash and fish but **not tracked** in repo. Also `~/.fish_profile` is expected but not tracked.
- **XDG**: base-directory defaults live in the `xdg` stow package (`xdg/.profile`, `.config/mimeapps.list`, `.config/user-dirs.dirs`, `.config/environment.d/10-xdg.conf` for user services). Fish never sources `.profile`, so it gets `set -q` guards via `fish/.config/fish/conf.d/xdg.fish`.
- **Fonts**: fontconfig config enables JetBrains Mono (likely).
- **OpenCode** config at `opencode/.config/opencode/opencode.json` — permission rules for git/ls/pwd.

## Development

Nothing to build, test, lint, or format. Changes are applied by re-running `stow <package>` or by symlinking manually. To preview file changes before commit, use `git diff`.

Systemd units live in the `systemd` package, but enablement state (`*.target.wants/`) is machine-local and gitignored. After `stow systemd`, enable explicitly: `systemctl --user daemon-reload && systemctl --user enable --now clipcat.service`. NEVER run `systemctl --user disable/reenable` on stow-managed units: disable cannot tell the stow symlink apart from an enablement symlink and deletes `~/.config/systemd/user/<unit>` itself (recover with `stow systemd` + `daemon-reload` + `enable`); to move a unit between targets, `enable` the new target and `rm` the old `*.target.wants/` symlink manually. Graphical-session-bound services (`clipcat`, `xremap`) are pulled in via the `graphical-login.target` wrapper started from `~/.xprofile` (stow package `xprofile`, sourced by SDDM Xsession before the WM): stock `graphical-session.target` has `RefuseManualStart=yes`, so it can only be activated as a dependency (`Requires=` in the wrapper), never via `systemctl start` directly. Logout is the `logout` fish alias (stops the target, then `awesome-client 'awesome.quit()'` for a graceful WM shutdown), invoked directly and from the `tv power` Logout action via `fish -c` — no per-service `start`/`restart` calls anywhere, no helper scripts, and no bare `awesome.quit` keybinding. (`loginctl terminate-session` was tried but reverted: the harsh SIGKILL made Discord dump a ~10 GB core, freezing the machine under systemd-coredump; `systemctl --user exit` was also rejected — it only quits the user manager, leaving Awesome/X running.) `clipcat.service` cleans its pid file in `ExecStopPost` to avoid stale-pid wait loops after unclean stops. Note: stow folds a package dir into one symlink when the target path is new — if `~/.config/systemd/user` ever becomes a single symlink into the repo, `systemctl enable` will write absolute symlinks into the repo; fix by `stow -D systemd`, `mkdir -p ~/.config/systemd/user`, `stow systemd` (per-file symlinks), then enable again.
