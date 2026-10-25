# opencode — config + skills

`stow opencode` links into `~/.config/opencode/`:

- `opencode.json` — server config: permission rules (git status/diff/log,
  ls/pwd are `allow`; git push/commit/add are `ask`).
- `skills/beamer/` — vendored Beamer LaTeX slide skill from
  <https://github.com/Noi1r/beamer-skill> (the `beamer/` dir). OpenCode
  auto-discovers skills at `~/.config/opencode/skills/<id>/SKILL.md`.

## cli.json — TUI settings, tracked but never stowed

- The live file is service-owned: the running service rewrites it on
  settings changes and replaces any symlink with a regular file.
- `.stowrc`'s `--ignore=cli\.json$` keeps it unlinked; the repo copy is
  a backup of intent only.
- After changing TUI settings, resync manually:
  `cp ~/.config/opencode/cli.json opencode/.config/opencode/`

## Untracked live files (machine-local by design)

- `package.json`, `package-lock.json`, `node_modules/` — plugin deps,
  auto-managed by OpenCode; its own `.gitignore` there excludes them.
- `service.json`; auth, session db and logs live under
  `~/.local/share/opencode/`.

## Updating the beamer skill

```sh
git clone --depth 1 https://github.com/Noi1r/beamer-skill /tmp/beamer-skill
rm -rf opencode/.config/opencode/skills/beamer
cp -r /tmp/beamer-skill/beamer opencode/.config/opencode/skills/
rm -rf /tmp/beamer-skill
stow -R opencode
```
