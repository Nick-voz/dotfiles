# awesome — AwesomeWM config

Catppuccin Mocha theme, `Mod4` as the primary key. Files: `rc.lua`,
`menu.lua`, `rules.lua`, `keymaps.lua`, `scripts/menu`, `themes/`.

`TERMINAL` comes from the environment (`xdg/.profile`, fallback `kitty`),
`EDITOR_CMD` is built from it in `rc.lua`.

## Startup hook

No system services are started from `rc.lua` directly; the only hook at the
**end** of `rc.lua` pulls in `graphical-apps.target` (GUI app units) so they
never race WM init (cursor theme, EWMH, tray). Infra units are a separate
phase driven from `~/.xprofile` — full unit picture in `systemd/AGENTS.md`.

## Firefox focus grab

Any firefox window title change jumps to that window — `property::name`
in `rc.lua`: `first_tag:view_only()`, focus, raise. That is how pages
opened via `tv bookmarks` / `web-search.sh` / `translate.sh` hand the user
over.

Filter: no grab for the empty tab page — titles starting with "New Tab"
or "New Private Browsing Window" (about:newtab changes the title too and
would steal focus for a page that is not there). The handover for a real
page simply happens once its title lands.

## Notifications

**Awesome is the notification daemon** — there is no dunst/notify-send
daemon to look for. It owns `org.freedesktop.Notifications` on the session
bus (`busctl --user list | grep Notifications` → PID of awesome) and renders
notifications as naughty popups. Its `GetCapabilities` include `actions`, so
libnotify action buttons work — this is why udiskie's "Browse directory" /
"Mount" buttons and `notify-send -A` are usable. dunst is installed but not
running and is *not* what answers on the bus.

`awesome-client` is only needed for state libnotify cannot express (the menu
window's busy/done events in `menu.lua`).

## Menu window

One dedicated kitty window (`WM_CLASS=menu`, `menu.service` in
`graphical-apps.target`) stays alive for the whole session and is kept
hidden by awesome — `hidden` in the rule is applied on `manage`, i.e. before
the first map, so the window never flashes at spawn.

### The two sides

- `menu.lua` (WM side): show, `request::activate`, hide, autoclose on
  `unfocus`, ignore-while-busy, `systemctl --user start`/`restart` when the
  window is gone. systemd owns spawning, lua must not, or two servers would
  race on the FIFO.
- `scripts/menu` (terminal side): blocks on the FIFO
  `$XDG_RUNTIME_DIR/awesome-menu/request`, runs the command on the pty and
  reports back with `awesome-client "require('menu').event('busy'|'done',
  rc)"` — arbitrary X properties emit no signal in awesome, so this is the
  only reverse channel.

### Environment

The server `source`s `~/.config/.env` before it starts reading requests:
the unit runs bash non-interactively, so neither `.bashrc` nor
`config.fish` (where the shells source it) is ever read, and everything run
in that window — nvim via `edit-file.sh`, firefox via `web-search.sh`, yazi
via udiskie's file manager — would otherwise miss the API keys (nvim's
parrot reads `PERPLEXITY_API_KEY`).

`EnvironmentFile=` on the unit is *not* an alternative: systemd silently
drops the `export KEY=...` lines that file is written in (checked with
`systemd-run -p EnvironmentFile=` on systemd 262). Verify with
`menu --send 'env > f'` from a shell, not `/proc/<pid>/environ` — that only
shows the env from `exec`, so sourced variables are invisible there.

### Requests and chaining

A request is two lines: mode + command. `menu --send "<cmd>"` queues a
follow-up, which is how the `menu` channel chains menu → brightness → …
into one window instead of spawning a kitty per step. After a command exits
the wrapper peeks the FIFO for 50ms: a queued follow-up is found instantly
and the window stays up; an empty FIFO only costs the 50ms right before the
window hides anyway.

tv is not special-cased (tv renders on stderr), and menu-like channels only
chain *terminal* follow-ups that end where they started (a tv channel,
`read`). GTK apps get their own `setsid kitty` window, and so do
`apps`/`bookmarks` (launchers, not flows).

Which tv channels run in the window and their status bar config:
`tv/AGENTS.md`. Editor-window and xremap class details: also there and in
`xremap/AGENTS.md`.

### Focus, hiding, restart

- The window **autocloses on focus loss**:
  `client.connect_signal("unfocus", ...)` — awesome 4.3 emits
  `focus`/`unfocus`, there is no `property::focus`. The same signal comes
  out of `banning_need_update` when our own `hide()` runs, which is why
  `hide(c)` takes the client and no-ops when it is already hidden. Clicking
  another window, a focus hotkey or a focus-stealing window (firefox from
  `tv bookmarks`) hides it even mid-flow; the command keeps running
  headless.
- That would strand the menu (`busy` stays set until the wrapper reports
  `done`), so the next `menu.open` with the window hidden **restarts the
  unit** instead of queueing behind the abandoned flow: systemd stops the
  control group, reaping that command and anything still in it (a `setsid
  kitty` window is detached from the tty but not from the cgroup), while
  `pending` survives `unmanage` so the fresh window picks the request up.
  Killing the abandoned flow is deliberate — the alternative (restore the
  window) makes the menu key hand back whatever was still running.
- Showing it needs `lower()` before `request::activate{raise=true}`:
  `luaA_client_raise()` (awesome 4.3, `objects/client.c`) returns early
  when the client already sits at the end of `globalconf.stack`, and
  nothing ever takes the prewarmed window off that list — from the second
  open on no restack was scheduled and the remapped window landed under
  whatever was focused last. The order inside `awesome_refresh()` is what
  makes that restack survive unhide: `stack_windows()` only sets a flag,
  the actual ConfigureWindow requests go out in `stack_refresh()`, i.e.
  after `banning_refresh()` mapped the window.
- Focus needs its own nudge for the same reason — `SetInputFocus` against
  a not-yet-mapped window is a BadMatch, so `menu.open` re-activates once
  from a 50ms timer, guarded by `not c.hidden and client.focus == c`
  (awesome's own re-issue in `client_unban()` only happens while the menu
  is still the focus target).
- Switching workspace closes the menu too, via
  `tag.connect_signal("property::selected")` — the window is sticky, so it
  would otherwise follow the user to the other tag.

### Traps

- The lock and FIFO fds must be closed for the command:
  `bash -c "$cmd" 9>&- 3<&-`. Any descendant that outlives the request (an
  editor window, `xsel` serving a selection, a daemon) inherits them and
  keeps the flock alive, so the *next* server exits at `flock -n 9` and
  `Restart=always` + `RestartSec=100ms` turns any restart into a crash loop
  until that stray process dies (this really happened: `xsel` from
  `edit-file.sh` held the lock and `systemctl --user restart menu.service`
  spun at 10Hz).
- `read -t ''` is not "no timeout" in bash 5.3 — use plain `read -r -u 3`
  (the FIFO is held `exec 3<>`, so writers never block and there is no
  EOF).
- `awful.rules` documents an `ontop` property that does not exist in 4.3 —
  use `above`.
- `menu --send` falls back to a throwaway `kitty --class tv` window when
  no server holds the lock, so the channels keep working without the unit.

### How it replaced the old tv windows

The prewarmed window replaces the old `kitty --class tv` menu windows,
which input remapping matched by class: `xremap --list-windows` reports it
as `menu.menu`, so every `tv.tv` in `xremap/.config/xremap/config.yml`
became `menu.menu` (the TV word/line ops `only`, and the `not` exclusion of
the Ctrl+C/V/X/Z disabling rule). The `/kitty/` rules were deliberately
left alone: the window is a kitty window that no longer calls itself
`kitty.*`, so it takes exactly the path the tv windows took — Super-C/V/A
become Ctrl-C/V/A (no kitty copy/paste) and Ctrl+C/V/X/Z are not
suppressed. Rule and verification details: `xremap/AGENTS.md`.
