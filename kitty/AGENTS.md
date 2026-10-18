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
