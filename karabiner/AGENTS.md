# karabiner — keyboard remapping (macOS)

`karabiner.json` (Karabiner-Elements). `automatic_backups/` is
machine-local and gitignored. The package is undeployed on this Linux
machine: `stow-target.sh` prints the picked path unchanged (see
`tv/AGENTS.md`). On the mac it is stowed; Karabiner watches the live
file and reloads on save.

- Screenshot parity with the Linux WM keymap (`awesome/keymaps.lua` is
  the source of truth): global `Cmd+S` → whole screen, `Cmd+Shift+S` →
  interactive selection, via `shell_command` running
  `~/.local/bin/screenshot [-s]` (package `scripts`). The manipulators
  list no `optional` modifiers, so other chords (`opt+cmd+s`,
  `ctrl+cmd+s`, …) fall through untouched. Karabiner sees the key
  before kitty, which is what resolves the collision with kitty's tab
  keymaps — no kitty-side changes were needed.
