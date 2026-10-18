# clipcat — clipboard daemon

`clipcatd.toml` (daemon: `pid_file = /run/user/1000/clipcatd.pid`,
history settings) and `clipcatctl.toml`. The unit is `clipcat.service` in
`systemd/AGENTS.md` (infra class; `ExecStopPost` cleans the pid file).
Driven from the launcher via `tv clipboard` (see `tv/AGENTS.md`); the
`scrot` alias in fish also pipes into `clipcatctl load`.
