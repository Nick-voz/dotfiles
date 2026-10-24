#!/usr/bin/env bash
# usage: downloads-delete.sh <path>
# Immediate rm (no trash), then refresh the list in the same window.

path=${1:-}
case "$path" in "$HOME/Downloads/"*) ;; *) exit 0 ;; esac
[ -e "$path" ] || exit 0

rm -rf -- "$path"
notify-send "Deleted" "${path##*/}" >/dev/null 2>&1 || true

if [ -t 1 ]; then exec tv downloads; fi
