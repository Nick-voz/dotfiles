# scripts — standalone helper commands

bash, not fish functions, so they work from any shell, script or
service. Stowed per-file into `~/.local/bin`; that dir must stay a
real directory (mkdir before first `stow scripts`, else stow folds it
into a symlink into the repo — same trap as `systemd/AGENTS.md`).

- `topdf FILE [key=value ...] [-- raw-args]`: markdown → PDF via
  pandoc/eisvogel/xelatex.
- Default mode detaches: the script re-executes itself under
  `setsid -f` (`_TOPDF_WORKER=1`), so the conversion outlives the
  terminal; launch itself is silent, progress/result arrive as
  notify-send notifications (awesome). pandoc output goes to a
  `mktemp` log; the error popup names it (latest: `ls -t
  /tmp/topdf.*.log | head -1`).
- `-F`: synchronous, no notifications, pandoc's exit code propagates
  — the scripting interface.
- Bare `key=value` args become `-M` metadata (`--` switches to raw
  pandoc args); `author='Возисов Н.С.'` applies unless `author=` given.
- PATH (Linux only): plain `set -gx` in `fish/config.fish` (deliberately
  not `fish_add_path` — see `fish/AGENTS.md`); for the GUI session
  `~/.profile` (package `xdg`) prepends it.
