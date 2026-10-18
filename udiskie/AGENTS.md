# udiskie — removable media

`udiskie` (in the CachyOS `extra` repo, not AUR; needs `python-docopt`)
automounts flash drives/cards/discs through udisks2. Driven by this package:
`~/.config/udiskie/config.yml`, `scripts/browse`, `scripts/eject`, plus
`udisksie.service` (unit in `systemd/AGENTS.md`, infra class).

`automount` and `notify` are on, `tray` is off (awesome has no tray
applets), and the only `device_config` rule is a catch-all
`options: [noatime]` — udisks2 mounts removable media `relatime`, which
still writes an inode access time on every read.

## Mount paths

Volumes are mounted under `/run/media/$USER/<label>`, and `~/Media` is a
machine-local symlink to that directory (created by hand, like the
`*.target.wants/` symlinks) for a stable short path.

- udisksd hardcodes `/run/media` — the only trace of it in the binary is
  the error string `Error creating directory /run/media: %m`; no env var,
  no config file, so a symlink is the only way to get a path of one's
  choosing without patching.
- udiskie resolves it fine: `Device.is_file()` compares paths with
  `os.path.samefile()`, so `udiskie-mount`/`udiskie-umount` accept
  `~/Media/<label>`.
- `/run` is a tmpfs, so after a reboot `~/Media` dangles until something
  is plugged in for the first time (udisks2 creates `/run/media/$USER`
  lazily, and `/run/media` is root-owned 0755 so it cannot be pre-created
  from a user unit — a root `/etc/tmpfiles.d` rule is the only way to make
  it permanent, and udisks2 would then skip its own creation and its ACL).
- `tv media` deliberately lists the canonical `/run/media/$USER` rather
  than `~/Media`, so that deleting the symlink cannot silently break it.

## Browse (file_manager)

`file_manager` (the target of the mount notification's "Browse directory"
button) is passed in the unit, not in `config.yml`, because it needs `%h`
and only systemd expands specifiers in `ExecStart`; it points at
`scripts/browse`, which puts the volume into the prewarmed menu window with
yazi (`require('menu').open(..., 'hold')`, `hold` because yazi owns the
window until it exits) instead of the `xdg-open` default, which would
resolve `inode/directory` through `mimeapps.list`.

## Traps

1. With `--eject --detach` the exit code of `udiskie-umount` is the
   *detach* one, because a flash drive is detachable but not ejectable,
   and a busy mount point fails in ways the code alone does not
   distinguish — `scripts/eject` therefore asks the mount point itself
   (`mountpoint -q`) and reports through `notify-send`, critical on
   failure.
2. A failed safe-remove produces no udiskie event — the events are
   mounted/unmounted/locked/unlocked/added/removed — so `scripts/eject`
   sends its own `notify-send`, critical on failure; it has to, because
   the menu window hides itself the moment the command it runs exits, so
   stdout is never read (udiskie's `job_failed` popup does cover failures
   of the automount itself).
3. The physical unplug is not udiskie's to handle: udisks2 drops the
   mount when the device disappears, and powering the drive off is only
   meaningful *before* unplugging, which is why "poweroff" lives in
   `tv media` → `ctrl-e` and not in a removal hook.
4. Nothing internal gets mounted, and that is udiskie's builtin rules,
   not ours: they drop non-external toplevel devices, the root filesystem,
   loop devices and the docker mapper symlinks, and a catch-all rule that
   only sets `options` cannot unignore them (verified against
   `udiskie.config.match_config`).
5. A stow-symlinked unit that has not been enabled reports state `linked`
   with an empty `FragmentPath` — that is normal
   (`nextcloud-sync@.service` looks the same), not a broken symlink.
