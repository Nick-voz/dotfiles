# systemd — user units

All user units live here (`~/.config/systemd/user/`): `clipcat`, `discord`,
`firefox`, `menu`, `obsidian`, `picom`, `steam`, `superproductivity`,
`telegram`, `throne`, `udisksie`, `xremap`, `nextcloud-sync@.service` +
timers, and the targets `graphical-login.target` / `graphical-apps.target`.

Enablement state (`*.target.wants/`) is machine-local and gitignored.

## Applying changes

After `stow systemd`, enable explicitly:

```sh
systemctl --user daemon-reload && systemctl --user enable --now clipcat.service
```

**NEVER run `systemctl --user disable`/re-enable on stow-managed units:**
disable cannot tell the stow symlink apart from an enablement symlink and
deletes `~/.config/systemd/user/<unit>` itself. Recover with
`stow systemd` + `daemon-reload` + `enable`. To move a unit between targets:
`enable` the new target and `rm` the old `*.target.wants/` symlink manually.

**Stow folding trap:** stow folds a package dir into one symlink when the
target path is new. If `~/.config/systemd/user` ever becomes a single
symlink into the repo, `systemctl enable` will write absolute symlinks into
the repo. Fix: `stow -D systemd`, `mkdir -p ~/.config/systemd/user`,
`stow systemd` (per-file symlinks), then enable again.

A stow-symlinked unit that has not been enabled reports state `linked` with
an empty `FragmentPath` — normal (`nextcloud-sync@.service` looks the same),
not a broken symlink.

## Two-phase startup

No in-`rc.lua` autostart of system services; two phases:

- **Infra** (picom, clipcatd, xremap): user units
  `WantedBy=graphical-session.target`, pulled in via the
  `graphical-login.target` wrapper from `~/.xprofile` (stow package
  `xprofile`, sourced by SDDM Xsession before the WM). Stock
  `graphical-session.target` has `RefuseManualStart=yes`: it can only be
  activated as a dependency (`Requires=` in the wrapper), never via
  `systemctl start` directly.
- **GUI apps** (throne, telegram, discord, steam, superproductivity,
  firefox, obsidian, menu): units `WantedBy=graphical-apps.target`, started
  by a hook at the end of `rc.lua` (package `awesome`) so they never race
  WM init (cursor theme, EWMH, tray).

## Restart policy

All app units use `Restart=always` + `StartLimitIntervalSec=0` — a closed
window comes back; stop for real with `systemctl --user stop <name>`.
`StartLimitIntervalSec=0` means a unit that dies at startup would otherwise
crash-loop at the GUI rate and burn a core on compositor/input/clipboard
respawns.

`RestartSec` by class:

- `100ms` — GUI app units (`graphical-apps.target`), a closed window is back
  essentially instantly;
- `500ms` — throne (it re-creates a TUN device, `100ms` races the teardown);
- `1s` — infra units (`graphical-session.target`: picom, clipcat, xremap).

## throne

- Must run fully elevated (`ExecStart=sudo -n ...`): unprivileged it tries to
  raise the core itself (`chown root:root` + `chmod u+s` on `ThroneCore`),
  then the core goes silent — no `Core Has Successfully Connected` handshake,
  no `throne-tun`. Don't drop sudo.
- The tree is therefore uid 0 and `systemctl --user` cannot signal it
  (`EPERM`, `Failed to kill control group`), so it cannot clean up after
  itself: the unit reaps its own leftovers with
  `sudo -n pkill -9 -x -f <exact path>` in `ExecStartPre`/`ExecStopPost`,
  allowed by `/etc/sudoers.d/throne-restart` (exact args — a trailing `*`
  would let root kill any process).
- The existing `NOPASSWD` rule for the Throne binary and its
  `Defaults!.../Throne env_keep+="XCURSOR_THEME XCURSOR_SIZE"` must stay:
  `ExecStart` and the cursor theme need them.
- Traps: `config/logs/throne.log` is buffered and only flushes on exit —
  never judge startup by tailing it; `throne-tun` exists only while Tun Mode
  is enabled in the app's UI, which is what `discord.service`'s
  `ExecStartPre` gates on.
- discord additionally waits for `throne-tun` via `ExecStartPre` +
  `Wants=throne.service` (start ordering only, no stop propagation). The gate
  polls (`timeout 60` + 0.5s loop): `throne-tun` goes `connected` ~2s after
  `throne.service` starts, so a one-shot check fails the boot race and
  floods the journal with `Failed to start Discord` while `RestartSec`
  retries.

## Other unit notes

- Electron units (`discord`, `obsidian`) need `KillSignal=SIGINT`: on
  SIGTERM Discord ignores it (full `TimeoutStopSec`, then SIGKILL +
  `Failed with result 'timeout'` + cores), Obsidian dumps a SIGTRAP core
  (`Failed with result 'core-dump'`). Both stop cleanly in <1s via SIGINT.
  SuperProductivity (Electron too) is fine as-is — the `snap run` wrapper
  handles the signal.
- `clipcat.service` cleans its pid file in `ExecStopPost` to avoid stale-pid
  wait loops after unclean stops.
- Graphical-session-bound services (`clipcat`, `xremap`) are pulled in via
  the `graphical-login.target` wrapper (see Two-phase startup).
- steam — expected `journalctl -p err` line, one per boot:
  `steam-runtime-steam-remote: E: Steam is not running: No such device or
  address`. `bin_steam.sh` first probes whether Steam is *already* open by
  writing its command line into `~/.steam/steam.pipe` — a FIFO Steam never
  deletes, so the probe fires every launch. At boot no Steam is holding the
  reading end yet, so the write fails with `ENXIO`. That message *is* the
  correct answer ("not running"); the script then starts Steam normally.
  err-priority only because the runtime logs straight to journald, bypassing
  the script's `2>/dev/null`. Not a fault.
- steam also logs `Looks like steam didn't shutdown cleanly` next boot —
  `KillMode=control-group` SIGTERMs the client on stop/logout, so Steam
  schedules an update check on the next start. Benign.
- Latent steam hazard: if Steam is somehow already running when the unit
  starts, `bin_steam.sh` forwards the command line and exits 0, and
  `Restart=always` + `RestartSec=100ms` + no rate limit re-probes the pipe
  ~10x/s. Safe only because nothing else launches Steam here.

## Logout

Logout is the `logout` fish alias (package `fish`): stops the target, then
`awesome-client 'awesome.quit()'` for a graceful WM shutdown. Invoked
directly and from the `tv power` Logout action via `fish -c` — no
per-service `start`/`restart` calls anywhere, no helper scripts, and no bare
`awesome.quit` keybinding.

Rejected alternatives: `loginctl terminate-session` (the harsh SIGKILL made
Discord dump a ~10 GB core, freezing the machine under systemd-coredump);
`systemctl --user exit` (only quits the user manager, leaving Awesome/X
running).
