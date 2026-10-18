# xdg — base-directory defaults

- `.profile` — sourced by SDDM's Xsession before the WM; exports
  `TERMINAL=kitty` (consumed by `rc.lua` and tv channels, see
  `kitty/AGENTS.md`).
- `.config/mimeapps.list` — default applications.
- `.config/user-dirs.dirs` — XDG user dirs.
- `.config/environment.d/10-xdg.conf` — env for user services.

Fish never sources `.profile`, so it gets `set -q` guards via
`fish/.config/fish/conf.d/xdg.fish` (package `fish`).
