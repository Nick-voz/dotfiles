#!/usr/bin/env bash
# Insert an empty clip and edit it in $EDITOR (the saved text lands in
# the clipboard; quitting the editor without changes leaves the empty clip).
#
# NOTE: run by the clipboard channel's ctrl-n (execute mode), so the editor
# takes over the menu window and the window hides again when it exits.
# Clip ids are content hashes, so re-inserting "" can reuse an existing id
# and the diff finds nothing — the fallback to the newest entry covers it.

before=$(clipcatctl list 2>/dev/null | cut -d: -f1)
clipcatctl insert "" >/dev/null 2>&1
id=$(clipcatctl list 2>/dev/null | cut -d: -f1 | grep -vxF -f <(printf "%s\n" "$before") | head -1)
[ -z "$id" ] && id=$(clipcatctl list 2>/dev/null | head -1 | cut -d: -f1)
[ -n "$id" ] && exec clipcatctl edit --editor "${EDITOR:-nvim}" "$id"

exit 0
