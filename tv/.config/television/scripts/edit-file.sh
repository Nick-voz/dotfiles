#!/usr/bin/env bash
# usage: edit-file.sh <channel>
# Runs a tv picker in the menu window and opens the picked path in $EDITOR in its
# own kitty window. See AGENTS.md (menu window) for the selection protocol.

set -u

channel=${1:-}
if [[ -z $channel ]]; then
	printf 'usage: %s <channel>\n' "${0##*/}" >&2
	exit 1
fi

printf '' | xsel --secondary --input

tv "$channel"

selected=$(xclip -selection secondary -out 2>/dev/null) || selected=
[ -n "$selected" ] && [ -e "$selected" ] || exit 0
selected=$("$HOME/.config/television/scripts/stow-target.sh" "$selected")

(trap '' HUP; setsid ${TERMINAL:-kitty} -e bash -c 'exec "${EDITOR:-nvim}" "$1"' \
	_ "$selected" </dev/null >/dev/null 2>&1 &)