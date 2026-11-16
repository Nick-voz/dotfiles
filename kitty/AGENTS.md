# kitty — terminal

`TERMINAL` is exported once from `xdg/.profile` (SDDM sources it before
Awesome, so GUI shells inherit it); `rc.lua` and tv channels fall back to
`kitty` when unset (TTY/ssh).

## Tab keymaps

- `ctrl+[1..9,0]` → `goto_tab 1..10`
- `ctrl+shift+[1..9,0]` → move the active tab to position 1..10

kitty has no absolute reorder — only `move_tab_forward`/`move_tab_backward`
(one step, no arguments) and no `@ move-tab` subcommand — so the ten
`ctrl+shift+digit` maps are `remote_control_script scripts/move-tab-to <n>`.

### How move-tab-to works

The script asks `kitten @ ls` for the index of the tab with `is_focused`
(the `self.tabs` order `Tab.move_tab` uses; `tab_bar_filter` is empty, so
`tabs_to_be_shown_in_tab_bar` never filters), clamps `n` (`0`/below →
first, past the end → last) and issues one `kitten @ action
move_tab_forward|move_tab_backward` per step — nothing more, since
`move_tab` wraps mod n anyway.

It works with no `--to` because a `remote_control_script` is spawned via
`run_background_process(allow_remote_control=True)`, i.e. it inherits
`KITTY_LISTEN_ON=fd:N` (and `kitten @` picks that env up); a plain
`kitten @` from a normal shell has neither. Relative paths in
`remote_control_script` resolve against the config dir
(`resolve_custom_file`), hence `scripts/move-tab-to`, and the script must
be executable — otherwise all kitty does is log "not executable".

### Side effects

The ten chords shadow the built-in `first_window`…`tenth_window` defaults
(`kitty_mod` is ctrl+shift), so focusing the nth window by digit is gone —
`ctrl+shift+[`/`]` still do `previous_window`/`next_window`, and no
`rc.lua`/`xremap` binding uses ctrl+shift+digit. kitty auto-reloads
`kitty.conf` on change, so the maps are live in already-running instances
without a restart.

## super+v → smart-paste

`map super+v remote_control_script scripts/smart-paste`.

- Clipboard has text (or nothing) → the script runs `kitten @ action
  paste_from_clipboard` — the old static map, unchanged for shells,
  editors and the menu/input prompts.
- Image-only clipboard → it sends the raw `super+v` key event
  (`\e[118;9u`, CSI-u encoding of the kitty keyboard protocol) instead.
  A terminal can only paste text, so an image in the clipboard would
  otherwise arrive as nothing; apps that read the clipboard themselves
  react to the key — OpenCode binds `prompt.paste` to `super+v` (and
  `ctrl+v` on macOS) and attaches the image (`opencode/AGENTS.md`).
  Apps that don't parse CSI-u swallow the escape silently.
- Clipboard sniffing is per-platform: `xclip` TARGETS on X11; on macOS
  a cached Swift helper (`NSPasteboard.canReadObject`, exit 0 =
  image-only) at `~/.cache/kitty-smart-paste/pbtype`, compiled by the
  script on first use (~40s once) via swiftc — ~15ms per paste after.
  The fallback there is `osascript clipboard info`, which costs ~1s
  and made every image paste feel slow. No xclip existed on the Mac,
  so before this branch the map exited 0 and pasted nothing at all.
- Mixed clips (text + image) and Finder file copies (`furl`,
  `text/uri-list`) paste as text on both platforms.
- Same spawn/env mechanics as move-tab-to; a plain shell has no
  `KITTY_LISTEN_ON`, so the script can only be exercised by pressing
  the key for real.
