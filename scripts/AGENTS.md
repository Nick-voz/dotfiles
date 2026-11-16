# scripts — standalone helper commands

bash, not fish functions, so they work from any shell, script or
service. Stowed per-file into `~/.local/bin`; that dir must stay a
real directory (mkdir before first `stow scripts`, else stow folds it
into a symlink into the repo — same trap as `systemd/AGENTS.md`).

- `topdf FILE [key=value ...] [-- raw-args]`: markdown → PDF via
  pandoc/eisvogel/xelatex.
- `screenshot [-s]`: timestamped PNG into `~/Documents/screenshots` +
  clipboard; `sh` by design (invoked from Karabiner `shell_command` on
  the mac). Linux branch = `scrot`/`scrot -s` + `clipcatctl` (mirrors
  the fish `scrot` alias, the behavior being copied); mac branch =
  `screencapture`/`-i` + osascript `«class PNGf»` onto the pasteboard
  (`-c` alone would skip the file). No `-x`: both mac branches keep the
  native shutter sound — extra sounds are wrong (`-i` is the system
  capture UI itself, so an added chime just double-dings). `-i` cancel
  (Esc) exits 0 silently.
- Default mode detaches: the script re-executes itself under
  `setsid -f` (`_TOPDF_WORKER=1`), so the conversion outlives the
  terminal; launch itself is silent, progress/result arrive as
  notify-send notifications (awesome). pandoc output goes to a
  `mktemp` log; the error popup names it (latest: `ls -t
  /tmp/topdf.*.log | head -1`).
- `-F`: synchronous, no notifications, pandoc's exit code propagates
  — the scripting interface.
- Bare `key=value` args become `-M` metadata (`--` switches to raw
  pandoc args); defaults apply unless overridden: `author=` →
  `Возисов Н.С.`, `date=` → today in `dd.mm.yyyy`.
- PATH: plain `set -gx` in `fish/config.fish` on both Linux and the mac
  (deliberately not `fish_add_path` — see `fish/AGENTS.md`); for the
  Linux GUI session `~/.profile` (package `xdg`) prepends it too. On
  the mac, Karabiner calls helpers by absolute path, not PATH.
