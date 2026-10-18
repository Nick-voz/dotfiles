# gtk — GTK settings

`gtk-3.0/` and `gtk-4.0/` each hold `settings.ini`, plus `gtk.css` for
GTK3. Both subdirs are top-level deploy targets, so stow cannot decide
between them for `stow-target.sh` (the `tv dirs-config` preview prints
the picked path unchanged — see `tv/AGENTS.md`).
