# gtk — GTK settings

`gtk-3.0/` and `gtk-4.0/` each hold only `settings.ini`. Both subdirs
are top-level deploy targets, so stow cannot decide between them for
`stow-target.sh` (the `tv dirs-config` preview prints the picked path
unchanged — see `tv/AGENTS.md`).

Cursor/selection keybindings are not configured here anymore: the old
GTK3 `gtk.css` binding set was replaced by the universal xremap keymap,
which works in every toolkit (and in GTK4, which dropped CSS bindings) —
`xremap/AGENTS.md`.
