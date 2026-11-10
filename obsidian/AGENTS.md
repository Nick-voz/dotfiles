# obsidian — shared settings canon

Stows `~/.config/obsidian-settings` → this package dir. It is the single
source of truth for Obsidian settings shared across vaults (and machines).

## What lives here

Shared (symlinked into every vault's `.obsidian`): `app.json`,
`appearance.json`, `backlink.json`, community/core plugins lists,
`daily-notes.json`, `hotkeys.json`, `note-composer.json`,
`page-preview.json`, `templates.json`, `zk-prefixer.json`, `plugins/`
(incl. `data.json` — vault skeletons are identical, so paths resolve in
every vault), `snippets/`, `themes/`.

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
