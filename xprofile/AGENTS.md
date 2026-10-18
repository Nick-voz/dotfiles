# xprofile — X session startup

`.xprofile` is sourced by SDDM's Xsession before the WM. It runs the
`graphical-login.target` wrapper that pulls in the infra units
(`graphical-session.target`). `.Xresources` holds X resources.

Unit details: `systemd/AGENTS.md`.
