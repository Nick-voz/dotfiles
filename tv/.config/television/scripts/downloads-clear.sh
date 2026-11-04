#!/usr/bin/env bash
# usage: downloads-clear.sh
# Removes every first-level entry (hidden partials included), no
# confirmation. The menu window closes on exit — nothing left to browse.

dir="$HOME/Downloads"
[ -d "$dir" ] || exit 0
count=$(find "$dir" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)
[ "$count" -gt 0 ] || exit 0

find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
notify-send "Downloads" "Emptied ($count entries)" >/dev/null 2>&1 || true
