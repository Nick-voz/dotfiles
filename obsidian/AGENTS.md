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

## macOS migration — agent runbook

Context: 2026-11-10 the Linux `~/obsidian` was split into
`~/obsidian` (IT/study) + `~/obsidian-dnd` (D&D). Linux is DONE (both
vaults opened, sync verified). Finish the same on the Mac.

Server state: `/obsidian` (IT only), `/obsidian-dnd` (new, synced from
Linux via `nextcloud-sync@obsidian-dnd.timer` at `:25`). `.obsidian`
must never travel through Nextcloud on any machine. Rollback source of
truth: Linux `~/obsidian-backup-2026-11-10/` (pre-split full vault).

1. `cd ~/dotfiles && git pull`.
2. `stow obsidian` ONLY (systemd package is Linux-specific).
3. Inspect first: find the vault path + sync mechanism on this Mac
   (`launchctl list | grep -i nextcloud`, client settings). Record
   local↔remote paths and whether `.obsidian` currently syncs; if it
   does, exclude it in the client — cloud `.obsidian` fights the canon.
4. Add sync for remote `/obsidian-dnd` (mirror Linux layout:
   `~/obsidian` + `~/obsidian-dnd`).
5. De-conflict old local settings: `mv ~/obsidian/.obsidian
   ~/obsidian/.obsidian.pre-canon; mkdir ~/obsidian/.obsidian`, then
   `~/.config/obsidian-settings/link.sh ~/obsidian ~/obsidian-dnd`.
   Verify shared items are symlinks, `workspace/bookmarks/graph/types`
   real files. `link.sh` warnings about real files = not done.
6. In Obsidian: add `~/obsidian-dnd` as vault; each vault opens its own
   `base/Home page` (shared settings, different files — intended).
7. Smoke checks, both vaults: homepage dataviews list notes; one wikilink
   resolves; one `attachments/` image renders; editing settings in one
   vault shows as a change in this repo (`git status`) — commit+push;
   Linux pulls. Settings travel ONLY via dotfiles git.
8. Confirm to the user; ask before deleting Linux backup (keep a week of
   burn-in, never autonomously) and `vault-split-plan.md` in the main
   vault root.

Rules: never move files between vault folders or rename skeleton dirs
(relative links + settings depend on them); never share mutable
per-file plugin state between vaults (`link.sh` PLUGINS_LOCAL is the
tool); no secrets in this package — credentials live in per-machine
stores (`~/.config/nextcloudcmd/credentials.env`, macOS keychain).
