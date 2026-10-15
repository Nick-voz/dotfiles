#!/usr/bin/env bash
# Edit the most recent clipcat entry in $EDITOR (writes back on save).
#
# NOTE: launched from tv menu, so it runs in the prewarmed menu window and the
# window is hidden again once nvim exits.

before=$(clipcatctl list 2>/dev/null | cut -d: -f1)
clipcatctl insert "" >/dev/null 2>&1
id=$(clipcatctl list 2>/dev/null | cut -d: -f1 | grep -vxF -f <(printf "%s\n" "$before") | head -1)
[ -z "$id" ] && id=$(clipcatctl list 2>/dev/null | head -1 | cut -d: -f1)
[ -n "$id" ] && exec clipcatctl edit --editor "${EDITOR:-nvim}" "$id"

exit 0