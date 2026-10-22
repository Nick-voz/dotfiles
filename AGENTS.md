# dotfiles

Linux (CachyOS/Arch) dotfiles managed with GNU Stow.
Not a software project — no build/test/lint/CI.

## Stow layout

Each top-level directory is a Stow package. Run from repo root:

```sh
stow <package>
```

This symlinks `./<package>/.config/<app>/...` → `~/.config/<app>/...`.
Example: `stow nvim` links `nvim/.config/nvim/` → `~/.config/nvim/`.

Packages: `awesome`, `bash`, `clipcat`, `fish`, `fonts`, `gtk`,
`karabiner`, `kitty`, `nvim`, `opencode`, `pandoc`, `picom`, `scripts`,
`ssh`, `systemd`, `tv`, `udiskie`, `xdg`, `xprofile`, `xremap`.

`.stowrc` ignores `AGENTS.md` at package roots, so per-package instruction
files are never stowed into `$HOME`.

**Most specifics live in per-package `AGENTS.md` files** (one per package,
next to its config); OpenCode loads them when you touch files inside that
package. This file only holds cross-package facts.

## Maintaining AGENTS.md files

Keep the established structure when editing any `AGENTS.md` here:

- Short lines (≤ 80 chars), no wall-of-text paragraphs.
- Structure: headings and bullet lists instead of long prose.
- Facts about a single stow package belong in that package's `AGENTS.md`,
  never in the root file; the root holds only cross-package facts and
  one-line pointers (`<pkg>/AGENTS.md`) to them.
- Cross-package topics: give each side a short summary at home and
  cross-reference the other package's file instead of duplicating detail.

## Cross-package facts

- **Secrets**: `~/.config/.env` is sourced by bash and fish but **not
  tracked** in the repo. `~/.fish_profile` is expected but also untracked.
- **Notifications**: awesome is the session's notification daemon (not
  dunst); `notify-send -A` action buttons work — `awesome/AGENTS.md`.
- **Wi-Fi / Bluetooth**: nm-applet/blueman-applet are intentionally not
  installed — Wi-Fi via `tv wifi` + nmcli, BT via bluetoothctl.
- **Startup**: two-phase systemd startup (infra as
  `graphical-session.target`, GUI apps as `graphical-apps.target`) —
  `systemd/AGENTS.md`; the `rc.lua` hook — `awesome/AGENTS.md`.
- **Menu window**: prewarmed hidden kitty window shared by the launcher —
  mechanics in `awesome/AGENTS.md`, channels in `tv/AGENTS.md`.
- **Editor**: nvim (LazyVim), opened from the menu flow; extras and
  format — `nvim/AGENTS.md`.
- **Custom scripts**: live in package `scripts`, stowed to
  `~/.local/bin`, which fish (`config.fish`) and the GUI session
  (`xdg/.profile`) each put on PATH — `scripts/AGENTS.md`.
- **Apply changes** by re-running `stow <package>` (or symlinking
  manually); preview with `git diff`.

## Development

Nothing to build, test, lint, or format. Unit enablement, `disable`
dangers and logout live in `systemd/AGENTS.md`; stow's package-folding
trap is documented there too.

Comment style for all config code: short comments only where behavior is
not clear from the code itself; facts and behavior belong in the
package's `AGENTS.md`.
