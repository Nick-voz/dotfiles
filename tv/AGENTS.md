# tv — television launcher

Television terminal viewer with extensive channel configs under
`.config/television/cable/`, scripts under `.config/television/scripts/`.

## Channels and the menu window

Everything menu-like opens in the prewarmed menu window (mechanics in
`awesome/AGENTS.md`), not a fresh kitty. Brightness, clipboard (clipcat via
`tv clipboard`), power and wifi live in tv channels. Firefox bookmarks are
`tv bookmarks` (foxmarks + xdg-open), launched from `tv menu`. Web search is
the `web-search.sh` helper, launched from `tv menu`.

The channels that run *in* the menu window — `menu`, `apps`, `bookmarks`
and `power` (the `Mod4` hotkeys go through `menu.open`), plus the steps
`menu` chains into it with `--send` and the ones the helper scripts run
there (`brightness`, `clipboard`, `media`, `web-search`, `dirs-config`,
`files-obsidian`) — all set `[ui.status_bar] hidden = true`, because that
bottom line is nothing but hints (`CHANNEL menu | Remote Control: ctrl-t •
Actions: ctrl-x • Help: ctrl-h | v0.15.9`) and `hidden` is the only way to
drop it: `StatusBarConfig` carries `hidden` and the two separators and
nothing else, so the hint spans cannot be removed while keeping the rest of
the line. Every other channel keeps the status bar.

`tv media` deliberately lists the canonical `/run/media/$USER` rather than
`~/Media`, so that deleting the symlink cannot silently break it (see
`udiskie/AGENTS.md`); "poweroff" of a drive is `tv media` → `ctrl-e`.

## Clipboard preview

`tv clipboard` renders the selected entry with
`scripts/clipboard-preview.sh <clip-id>`. The id comes from the row
(`{split:\::0}` — ids are hex without colons, preview text may contain any
punctuation).

- The preview command is run through the user's shell **from the current
  working directory**, not from the television config dir, so a relative
  `scripts/...` path dies with `fish: Unknown command` (the whole reason the
  channel spells it `"$HOME/.config/television/scripts/clipboard-preview.sh"`,
  like `menu.toml` and `dirs-config.toml` do).

- Raw bytes come from clipcat's **D-Bus** `Manager.Get`
  (`busctl --user --json=short … Get t 0x$id`, field `data[1]`, mime in
  `data[3]`): `clipcatctl get` is unusable here because it prints
  `preview_information`, where `\n \r \t` are replaced by two-character
  escapes (verified byte-wise).
- Dispatch is by mime only: `text/*` → `bat --style=plain --color=always
  --wrap=never` (real newlines/tabs; word wrap is the preview panel's
  `word_wrap = true`, hence `--wrap=never` to avoid double wrapping),
  anything else → `no preview: <mime>`. Images are deliberately not
  rendered (chafa tried and dropped: its auto-detect probes for kitty and
  emits APC graphics sequences that tv's ANSI parser strips, leaving base64
  garbage, and plain symbols were unwanted too).
- Bytes go through a one-liner of python3, **not** `jq 'implode'`: `implode`
  reads the byte array as code points and re-encodes them as UTF-8, so
  `Класс` comes out as mojibake (verified; tabs and ASCII look fine, which
  is what makes it misleading).
- File-manager copies need no special case: clipcat normalizes
  `text/uri-list` to `text/plain` on capture (verified via `clipcatctl
  load`), so they land in the plain text branch.
- Dependencies: busctl (systemd), jq, python3, bat.

## Edit config / Edit obsidian

The flow is split: the picker stays in the menu window
(`scripts/edit-file.sh <channel>` runs `tv dirs-config` /
`tv files-obsidian`, opens the path and exits, so the menu hides again) and
the editor is spawned from inside that script into a *separate* plain kitty
window — a follow-up queued with `--send` could not do it, since the menu
server runs it in the same window right after the picker.

### Where the path comes from

The path comes from the **secondary selection**, not stdout: both channels
bind `enter` to an `execute`-mode action (`printf '%s' '{}' | xsel
--secondary --input`), and a channel with an action bound prints *nothing*
on stdout (verified with tv 0.15.9 under a pty with stdout redirected to a
file — same for both, Enter and Esc). tv also exits **0 on Esc**, so the
script clears the selection before the picker
(`printf '' | xsel --secondary --input`, which makes `xclip -out` fail
rather than hand back a stale path) — a cancelled picker must not reopen
the previous file.

"Nothing to edit" therefore has to be tested as *no such path*, not as an
empty string: when a source yields nothing (an empty obsidian vault, a
failing `fd`) tv makes the placeholder `Command produced no output on
stdout, checking stderr...` selectable, so Enter still runs the action and
the secondary selection comes back as that text — `[ -e "$selected" ] ||
exit 0` then closes the menu window instead of handing the placeholder to
the editor as a filename.

### The editor window

No `--class` on it: `WM_CLASS=menu` is in the xremap "TV — word/line ops"
(`Alt-w`, `Ctrl-BackSpace`) and "Win→Ctrl" rules, which would hit nvim too,
while `/kitty/` matches a plain window and leaves its copy/paste and keys
alone (see `xremap/AGENTS.md`). The path is handed over as
`bash -c 'exec "$EDITOR" "$1"' _ <path>` so spaces and quotes need no
escaping, and the window closes when the editor exits.

## stow-target.sh

A picked path inside the repo is run through `scripts/stow-target.sh`,
which prints where **stow** deployed it: `fd -t d` never lists the stowed
symlinks (only `~/dotfiles/nvim`, never `~/.config/nvim`), so the row as
picked edits nothing the app reads.

- The mapping is stow's own `$HOME`-relative one
  (`<repo>/<pkg>/<rest>` → `$HOME/<rest>`), never "look in `.config`",
  which is why the packages stow links elsewhere come out right too
  (`pandoc` → `~/.local/share/pandoc/templates`, `ssh` → `~/.ssh/config`,
  `bash`/`xprofile` → `~/.<rc>`).
- "Deployed" is verified, not `[ -e ]`: the candidate must resolve to the
  picked path (symlinked dir) or hold symlinks into it (per-file
  deployment: `~/.config/systemd/user/*.service`,
  `~/.config/xremap/config.yml`), because `~/.config/opencode` and
  `~/.config/systemd` are real dirs stow never touched; `$HOME` and the
  XDG roots are excluded, or the `~/.config/nvim` link would make
  `~/.config` the target for `~/dotfiles/nvim`.
- A package root has no `<rest>` of its own, so the package is walked
  level by level and the shallowest deployed level wins (`systemd` →
  `~/.config/systemd/user`); ambiguous (gtk → gtk-3.0 *and* gtk-4.0) and
  undeployed (bash, xprofile, karabiner) packages print the picked path
  unchanged, and `dirs-config`'s preview runs the same script, so the row
  shows what Enter will open.

The scripts under `.config/television/scripts/` carry a usage line and
nothing else — the reasoning belongs here, not in the code.
