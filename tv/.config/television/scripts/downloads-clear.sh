#!/usr/bin/env bash
# usage: downloads-clear.sh
# Removes every first-level entry (hidden partials included) after a typed
# confirmation. On "yes" the menu window closes — nothing left to browse.

dir="$HOME/Downloads"
[ -d "$dir" ] || exit 0
count=$(find "$dir" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l)
[ "$count" -gt 0 ] || exit 0

printf 'Delete ALL %s entries in ~/Downloads? [y/N] ' "$count" >&2
REPLY=
read -r REPLY || REPLY=n
case "$REPLY" in
  y | Y)
    find "$dir" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +
    notify-send "Downloads" "Emptied ($count entries)" >/dev/null 2>&1 || true
    ;;
  *)
    if [ -t 1 ]; then exec tv downloads; fi
    ;;
esac
