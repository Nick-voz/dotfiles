# xremap — input remapping

`config.yml` here (per-file stow symlink); `xremap.service` is an infra
unit in `systemd/AGENTS.md`.

## Window matching

`xremap --list-windows` reports the prewarmed menu window as `menu.menu`,
so every `tv.tv` match in `config.yml` became `menu.menu` (the TV
word/line ops `only`, and the `not` exclusion of the Ctrl+C/V/X/Z
disabling rule). The `/kitty/` rules were deliberately left alone: the
window is a kitty window that no longer calls itself `kitty.*`, so it
takes exactly the path the old tv windows took — Super-C/V/A become
Ctrl-C/V/A (no kitty copy/paste) and Ctrl+C/V/X/Z are not suppressed.

## Verification

XTEST events (`xdotool key/type`) never reach xremap, which grabs evdev
devices, so remap behaviour cannot be verified that way — use a uinput
device (xremap auto-selects by capability, so a uinput keyboard with a
minimal key set is listed but not grabbed; copy the capabilities of an
already-selected virtual keyboard).

## Conflicts

`Ctrl-BackSpace` is claimed by both the TV rule (`Alt-u` → tv
`delete_line`) and the "delete to line start" rule: the first matching
keymap wins, so in tv/menu it deletes the whole input line and the latter
rule is dead code there.
