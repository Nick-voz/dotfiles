# xremap — input remapping

`config.yml` here (per-file stow symlink); `xremap.service` is an infra
unit in `systemd/AGENTS.md`.

## Window matching

`xremap --list-windows` reports the prewarmed menu window as `menu.menu`,
so every `tv.tv` match in `config.yml` became `menu.menu` (the TV
word/line ops `only`, and the `not` exclusions of the universal
navigation and Ctrl+C/V/X/Z disabling rules). The `/kitty/` rules were
deliberately left alone: the
window is a kitty window that no longer calls itself `kitty.*`, so it
takes exactly the path the old tv windows took — Super-C/V/A become
Ctrl-C/V/A (no kitty copy/paste) and Ctrl+C/V/X/Z are not suppressed.

## Universal navigation

The "Universal navigation" keymap is the global cursor scheme:
Alt+arrows move by word / line start / first non-blank, Ctrl+arrows
jump to line ends / buffer ends, Alt/Ctrl-BackSpace delete word/line,
Shift on any of them extends the selection. It replaced the GTK3
`gtk.css` binding set (`gtk/AGENTS.md`), so the scheme now applies
per-window in *all* apps except kitty and tv/menu — GTK4 too (it has no
CSS bindings) and outside text widgets: Firefox Alt-arrows no longer go
back/forward and Thunar's Alt-up no longer ascends, by choice. App-specific
overrides must be listed *above* it: keymaps cascade per binding and the
first keymap claiming a key wins, later maps are dead code for it.

The Super map is exact-match, so a combo carrying a stray extra
modifier (e.g. Shift not fully released after a selection) matches
nothing and falls through raw — Firefox gets Meta+z and does nothing.
If it ever bites: add an `exact_match: false` `only: [/firefox/]` map
above the Super map (app string is `Navigator.firefox`).

## Verification

XTEST events (`xdotool key/type`) never reach xremap, which grabs evdev
devices, so remap behaviour cannot be verified that way — use a uinput
device (xremap auto-selects by capability, so a uinput keyboard with a
minimal key set is listed but not grabbed; copy the capabilities of an
already-selected virtual keyboard).

## Conflicts

`Ctrl-BackSpace` is claimed by both the TV rule (`Alt-u` → tv
`delete_line`) and universal navigation (delete to line start):
navigation's `not` keeps it out of tv/menu, so there TV always wins.
