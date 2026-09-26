# dotfiles

Linux (CachyOS/Arch) dotfiles managed with GNU Stow. Not a software project — no build/test/lint/CI.

## Stow layout

Each top-level directory is a Stow package. Run from repo root:

```
stow <package>
```

This symlinks `./<package>/.config/<app>/...` → `~/.config/<app>/...`. Example: `stow nvim` links `nvim/.config/nvim/` → `~/.config/nvim/`.

Packages: `awesome`, `bash`, `clipcat`, `fish`, `fonts`, `gtk`, `kitty`, `nvim`, `pandoc`, `picom`, `rofi`, `systemd`, `tv`, `opencode`.

## Key facts

- **Shell**: fish with `pure` prompt, `fisher` plugin manager, `eza` for ls. Bash `.bashrc` is minimal (interactive-only).
- **WM**: AwesomeWM with Catppuccin Mocha theme, `Mod4` as primary key, autostarts picom/nm-applet/blueman/steam/Telegram/discord/betterbird/firefox. Clipboard history is handled by clipcatd via a systemd user service, not Awesome autostart.
- **Terminal**: kitty (hardcoded in awesome and fish configs).
- **Editor**: nvim (LazyVim) with extras: mini-surround, mini-move, json, markdown, python, toml. Stylua format: spaces, indent 2, width 120.
- **Launcher**: rofi with a custom web-search dmenu script and networkmanager-dmenu. Brightness, clipboard (clipcat via `tv clipboard`), power and wifi live in `tv` channels. Firefox bookmarks moved to `tv bookmarks` (foxmarks + xdg-open), launched from `tv menu`.
- **TV**: television terminal viewer with extensive channel configs under `tv/.config/television/cable/`.
- **Pandoc**: Eisvogel template files under `pandoc/.local/share/pandoc/templates/` — symlinked to `~/.local/share/pandoc/templates/` (not `.config`).
- **Secrets**: `~/.config/.env` is sourced by bash and fish but **not tracked** in repo. Also `~/.fish_profile` is expected but not tracked.
- **Fonts**: fontconfig config enables JetBrains Mono (likely).
- **OpenCode** config at `opencode/.config/opencode/opencode.json` — permission rules for git/ls/pwd.

## Development

Nothing to build, test, lint, or format. Changes are applied by re-running `stow <package>` or by symlinking manually. To preview file changes before commit, use `git diff`.
