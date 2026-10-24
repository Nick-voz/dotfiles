# tv — television launcher

Television terminal viewer with extensive channel configs under
`.config/television/cable/`, scripts under `.config/television/scripts/`.

`stow tv` deployed this package folded: `~/.config/television` is one
symlink onto the package dir (the trap from `systemd/AGENTS.md`), so repo
edits are the live config — nothing to re-stow, and `stow -u tv` would
take the whole directory with it.

## Channels and the menu window

Everything menu-like opens in the prewarmed menu window (mechanics in
`awesome/AGENTS.md`), not a fresh kitty. Brightness, clipboard (clipcat via
`tv clipboard`), power and wifi live in tv channels. Firefox bookmarks are
`tv bookmarks` (foxmarks + xdg-open), launched from `tv menu`. Web search is
the `web-search.sh` helper, launched from `tv menu`. Translate is the
`translate.sh` helper, launched from `tv menu` (see Translate below).

The channels that run *in* the menu window — `menu`, `apps`, `bookmarks`
and `power` (the `Mod4` hotkeys go through `menu.open`), plus the steps
`menu` chains into it with `--send` and the ones the helper scripts run
there (`brightness`, `clipboard`, `media`, `web-search`, `translate`,
`dirs-config`, `files-obsidian`) — all set
`[ui.status_bar] hidden = true`, because that
bottom line is nothing but hints (`CHANNEL menu | Remote Control: ctrl-t •
Actions: ctrl-x • Help: ctrl-h | v0.15.9`) and `hidden` is the only way to
drop it: `StatusBarConfig` carries `hidden` and the two separators and
nothing else, so the hint spans cannot be removed while keeping the rest of
the line. Every other channel keeps the status bar.

`tv media` deliberately lists the canonical `/run/media/$USER` rather than
`~/Media`, so that deleting the symlink cannot silently break it (see
`udiskie/AGENTS.md`); "poweroff" of a drive is `tv media` → `ctrl-d`.


## Channel commands are templates

Every `command` in a channel (`source`, `preview`, actions) is parsed as a
template, and a `{` anywhere in it — not just a placeholder — makes the
parse fail, so tv falls back to the raw string and **no** placeholder is
substituted. That is why the `apps` preview showed nothing: its inline awk
`awk '/^\[/{m=($0=="[Desktop Entry]")} m'` carries a brace block, so
`file='{split:\t:1}'` reached the shell verbatim. Verified: `display`
templates with `\t` are fine, and a bare `{split:\t:1}` in a `'''` block
substitutes correctly — a second brace anywhere kills the whole command.

- Keep shell logic in `scripts/` and let the channel hold a single line:
  `apps` is now `apps-list.sh` / `apps-preview.sh` / `apps-launch.sh`, so
  its launch action is
  `"$HOME/.config/television/scripts/apps-launch.sh" '{split:\t:1}'`.
- `$HOME/...` (not `scripts/...`) is required: preview and action commands
  run from the user's cwd (see the clipboard preview below).

## Apps channel

`apps.toml` lists visible desktop entries (`Name<TAB>path`) and launches
the selection: `Terminal=true` entries run their `Exec` line (field codes
stripped) inside `$TERMINAL` with `Path=` as cwd, everything else goes
through `gio launch`. Both detach with `setsid` and are `execute`-mode, so
tv gives the terminal back.

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

## Translate

`tv menu` → Translate → `scripts/translate.sh` runs in the menu window:
prompts for a query (empty Enter = latest clipcat entry), translates via
Google and reopens the result as `tv translate` there; Enter copies the
selected row (`xsel`), Esc closes without copying.

- One request serves both modes: `translate_a` with `dt=t&dt=bd` yields a
  word's dictionary (`.[1]`: POS groups, per-word confidence,
  back-translations) and a text's segment translations (`.[0]`).
  The web client `gtx` gets the anti-bot "Sorry" HTML from this IP and
  `tw-ob`/most other clients answer 429 under hammering; `client=at`
  served the same rich dictionary payload until ~15 rapid calls blocked it
  for a long window (no `Retry-After` header; see throttles below).
- Fallback chain: `at` → `tw-ob` (both `translate_a`, dictionary-capable) →
  v2 REST (`translation.googleapis.com`) with the public web-frontend key
  (override `GOOGLE_TRANSLATE_KEY`, `.env`-able) → open
  `translate.google.com?text=…` in firefox as last resort (the old flow).
- `translate_a` throttles are not quick: after a burst of ~15 calls the
  clients stayed 429 (or HTML-block) for 45+ min, while REST never blocked.
  So REST alone is the common degraded path for words — hence
  `wiki_variants()`: a single-word query with empty dictionary pulls
  variants from Wiktionary (`*-wiktionary.org` `action=parse&prop=wikitext`,
  never rate-limited): `{{t+|ru|word}}` lines on the en wiki, `|en=[[..]]`
  lines under `=== Перевод ===` on the ru wiki. The combined-grave accent
  (U+0301) in lemma entries is stripped as raw bytes `tr -d '\314\201'`.
  Rows are plain words (Google's translation first, then variants), fields
  1–2 left empty — the UI carries no `main`/`wikt` labels by design.
  Gotcha: the JSON value lives at `.parse.wikitext["*"]`, not `.value`.
- Speed (warm ~1.2–1.5 s per query, cold-chain probe ~3 s once per 15 min):
  a `translate_a` client answering non-200 is memoized in
  `${XDG_CACHE_HOME:-~/.cache}/tv-translate/blocked-<client>` (holds the
  epoch; skipped inside the 15-min cooldown, cleared on success, *not*
  marked on transport errors). `wiki_variants` for a single-word query
  starts in the background on the heuristic `tl` and runs concurrently
  with the endpoint chain; it is only consumed when the dictionary comes
  back empty — a direction flip re-asks it serially for the other side.
  No `-4`: A/B'd warm, IPv4 and IPv6 paths measure the same (the early
  0.3 s gap was just a cold AAAA cache), so forcing it buys nothing and
  would cut off an IPv6-only network.
- The UI shows no engine/source annotations: only the compact direction
  lands in the tv input title (`--input-header "$hdr"`, `En → Ru`), built
  from `det` (heuristic as fallback) and `tl`.
- Direction: Cyrillic → `tl=en`, else `tl=ru`; `sl=auto` reports the real
  source at `.[2]` and a wrong heuristic (`det == tl`) is retried once
  against the other language.
- Script↔channel contract: three `\t` fields — word rows
  `target<TAB>pos<TAB>backtranslations` (top 12 by confidence), text rows
  `translation<TAB>source<TAB>`; the channel keeps `no_sort`, copy takes
  field 0. The preview panel is hidden (`[ui.preview_panel] hidden`): rows
  are the whole UI, so nothing gets formatted twice.
- Confidence sort needs `LC_ALL=C sort -g`: under the ru locale GNU sort
  expects comma decimals, parses `0.655816` as 0 and `-r` then silently
  *reverses* the untouched order (verified with the same fixture both ways).
- Results move via `$TRANSLATE_ROWS` (`mktemp -d`, removed on exit), so
  `tv translate` standalone is meaningless (`cat` of unset var → error
  row). Headless checks: `TRANSLATE_TEST=1` prints rows instead of opening
  tv, `TRANSLATE_FIXTURE=file.json` feeds
  saved web JSON (skips the network).
- Clipboard input goes through the same D-Bus `Manager.Get` as
  `clipboard-preview.sh` (newlines collapse to spaces before the request);
  `clipcatctl get` stays unusable here.

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

## Dirs favorites

`tv dirs-favorites` is standalone (not a menu step): its source is
`scripts/dirs-favorites.sh`, whose `PREFIXES` array is the whole
maintenance surface — one favorite prefix per line, missing ones are
skipped. Each prefix's immediate child dirs are listed
(`fd -t d --max-depth 1`), in prefix order (`no_sort`, `frecency = false`).

- No action is bound, so Enter prints the picked path to stdout — the
  channel composes: `cd "$(tv dirs-favorites)"`, hotkeys, scripts.
- It runs in a plain terminal, not the menu window, so it keeps the
  status bar (see Channels and the menu window above).

## Downloads channel

`tv downloads` lists the first-level entries (files and dirs) of
~/Downloads, newest first: `downloads-list.sh` prints
`path<TAB>name<TAB>size<TAB>date` and the channel's `display`/`output`
templates pick the fields — the path prefix never shows, actions get
`{split:\t:0}`. Dirs print `-` as size (a `du` would slow the listing);
dotfiles are skipped, so an in-progress `.part`/`.crdownload` never
appears. `downloads-preview.sh` dispatches by mime (bat/eza/unzip/tar/
7z/identify/ffprobe/pdftotext); tv's "no output" placeholder row
previews as one line, and every action script starts by rejecting a
path outside `$HOME/Downloads/`, so it can never touch anything.

- Keys: enter = `xdg-open`, ctrl-d = delete, ctrl-m = move, ctrl-y =
  copy path; ctrl-o stays tv's global `toggle_preview` (enter already
  opens). The channel's `ctrl-y` overrides the global
  `copy_entry_to_clipboard`, which would paste the raw tab-joined row
  instead of the path. `clear_all` is deliberately unbound — ctrl-x
  only.
- Delete is plain `rm -rf` (no trash flow, by design); a mutating
  action ends with `exec tv downloads` guarded by `[ -t 1 ]`, which
  takes over the same menu window (execute mode already gave the
  terminal back — the handoff media.toml uses for `yazi '{}'`), so
  delete → refreshed list → delete makes a cleanup session; the
  refreshed list is the feedback, plus a small notify-send.
- `clear_all` prompts `[y/N]` with the count of first-level entries
  **including** the hidden partials it also removes; "y" empties the
  dir and closes the menu window (nothing left to browse), anything
  else reopens the list.
- Move targets come from a nested `tv dirs-favorites` in the same
  window — its child dirs *are* the intended targets, the prefixes
  themselves are deliberately not offered (Esc there = exit 0 with
  empty stdout → cancel back to the list).
- Rename is a `read -e -i` one-liner pre-filled with the name minus a
  ` (N)` duplicate suffix. `read -e` does *not* select the pre-fill:
  typing appends to it, so the prompt spells out Enter / Ctrl-U /
  empty / Ctrl-C, and the script binds `ESC w`/`ESC u` like
  translate.sh (see the menu-window note above). An empty reply keeps
  the original name; a destination collision never overwrites — the
  loop re-prompts with an auto-bumped `name (N).ext`; `/`-containing,
  `.` and `..` names are rejected.

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
