#!/usr/bin/env bash
# usage: downloads-open.sh <path>
# xdg-open detached, then refresh the list in the same window.

path=${1:-}
[ -n "$path" ] && [ -e "$path" ] || exit 0

(trap '' HUP; setsid xdg-open "$path" </dev/null >/dev/null 2>&1 &)

if [ -t 1 ]; then exec tv downloads; fi
