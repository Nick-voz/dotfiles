# dotfiles

Linux (CachyOS/Arch) dotfiles managed with GNU Stow. Not a software project — no build/test/lint/CI.

## Stow layout

Each top-level directory is a Stow package. Run from repo root:

```
stow <package>
```

This symlinks `./<package>/.config/<app>/...` → `~/.config/<app>/...`. Example: `stow nvim` links `nvim/.config/nvim/` → `~/.config/nvim/`.

Packages: `awesome`, `bash`, `fish`, `fonts`, `greenclip`, `gtk`, `karabiner`, `kitty`, `nvim`, `picom`, `rofi`, `tv`, `opencode`.

## Key facts

- **Shell**: fish with `pure` prompt, `fisher` plugin manager, `eza` for ls. Bash `.bashrc` is minimal (interactive-only).
- **WM**: AwesomeWM with Catppuccin Mocha theme, `Mod4` as primary key, autostarts picom/nm-applet/blueman/steam/Telegram/discord/betterbird/greenclip/firefox.
- **Terminal**: kitty (hardcoded in awesome and fish configs).
- **Editor**: nvim (LazyVim) with extras: mini-surround, mini-move, json, markdown, python, toml. Stylua format: spaces, indent 2, width 120.
- **Launcher**: rofi with custom dmenu scripts (brightness, clipboard, power-menu, web-search, firefox-bookmarks) and networkmanager-dmenu.
- **TV**: television terminal viewer with extensive channel configs under `tv/.config/television/cable/`.
- **Secrets**: `~/.config/.env` is sourced by bash and fish but **not tracked** in repo. Also `~/.fish_profile` is expected but not tracked.
- **Fonts**: fontconfig config enables JetBrains Mono (likely).
- **OpenCode** config at `opencode/.config/opencode/opencode.json` — permission rules for git/ls/pwd.

## Development

Nothing to build, test, lint, or format. Changes are applied by re-running `stow <package>` or by symlinking manually. To preview file changes before commit, use `git diff`.
