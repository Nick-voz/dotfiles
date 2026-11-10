# obsidian — shared settings canon

Stows `~/.config/obsidian-settings` → this package dir. It is the single
source of truth for Obsidian settings shared across vaults (and machines).

## What lives here

Shared (symlinked into every vault's `.obsidian`): `app.json`,
`appearance.json`, `backlink.json`, community/core plugins lists,
`daily-notes.json`, `hotkeys.json`, `note-composer.json`,
`page-preview.json`, `templates.json`, `zk-prefixer.json`, `plugins/`
(one symlink per plugin; `data.json` shared — vault skeletons are
identical, so paths resolve in every vault), `snippets/`, `themes/`.

`PLUGINS_LOCAL` in link.sh (currently `obsidian-quiet-outline`) gets a
real dir with per-file links; its `markdown-states*` stay per-vault —
never let two vaults share mutable per-file state.

Local per vault (never shared): `workspace.json`, `bookmarks.json`,
`graph.json`, `types.json`, caches.

## Vaults

Same folder skeleton in each: `base/ attachments/ daily/ weekly/
Templates/` — settings reference it with relative paths, keep it intact.

- `~/obsidian` — IT/study vault (Nextcloud `/obsidian`).
- `~/obsidian-dnd` — D&D/Aveon vault (Nextcloud `/obsidian-dnd`).

## Linking a vault

```sh
~/.config/obsidian-settings/link.sh <vault-dir>...
```

Idempotent: creates/refreshes `.obsidian` symlinks, leaves real files
alone (prints a warning). On a fresh machine: `stow obsidian`, sync the
vaults, run `link.sh` on each vault dir.

## Notes

- `.obsidian` is excluded by nextcloudcmd (see `systemd` package,
  `nextcloud-sync@.service`) — settings never travel through Nextcloud;
  dotfiles is the transport.
- `plugins/obsidian-enhancing-export/data.json` has per-OS export dirs
  (linux/darwin) — fine to share as-is.
- Homepage plugin opens `base/Home page` in every vault; each vault has
  its own file at that path.

## macOS migration — DONE 2026-11-10

Context: 2026-11-10 the Linux `~/obsidian` was split into
`~/obsidian` (IT/study) + `~/obsidian-dnd` (D&D). Linux and the Mac are
both done: `~/obsidian` + `~/obsidian-dnd` exist on the Mac, vaults
opened, sync verified against `/obsidian` (109 files) and
`/obsidian-dnd` (237) — sets match exactly, no `.obsidian` in cloud.

Final Mac state:

- Sync: launchd `com.nikitavozisow.nextcloud-update` (60 s interval),
  three `nextcloudcmd` runs: `~/obsidian` ↔ `/obsidian`,
  `~/obsidian-dnd` ↔ `/obsidian-dnd`, `~/Documents` ↔ `/Documents`.
  Credentials inline in the plist (per-machine, not in this repo).
- Excludes: this nextcloudcmd's `--exclude` patterns silently match
  nothing — the plist uses `--exclude-anchored` with
  `~/.config/nextcloud_ignore` (`.obsidian` variants + `.DS_Store`).
- Gotcha: a `.sync_*.db` journal that once tracked `.obsidian` can
  resurrect empty `.obsidian/` collections on the server; reset the
  local journal after excluding if the server had config entries.
- Canon de-conflicted: old Mac settings kept OUTSIDE the sync tree at
  `~/obsidian-pre-canon-2026-11-10/`; vault `.obsidian` dirs hold only
  `link.sh` symlinks + per-vault real files (workspace, bookmarks...).
- Server config pollution (`.obsidian` uploaded from old Mac setup) was
  purged via WebDAV; rollback source of truth remains Linux
  `~/obsidian-backup-2026-11-10/`.

Pending human calls (ask, never autonomous): after ~a week of burn-in,
delete Linux `~/obsidian-backup-2026-11-10/`, Mac
`~/obsidian-pre-canon-2026-11-10/`, and `vault-split-plan.md` in the
main vault root. Visual smoke (dataview renders, wikilinks, one
`attachments/` image) was verified as far as headless checks allow —
screenshots blocked by screen-recording permission; confirm in the app.

Rules: never move files between vault folders or rename skeleton dirs
(relative links + settings depend on them); never share mutable
per-file plugin state between vaults (`link.sh` PLUGINS_LOCAL is the
tool); no secrets in this package — credentials live in per-machine
stores (`~/.config/nextcloudcmd/credentials.env`, macOS keychain).
