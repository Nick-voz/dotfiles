#!/usr/bin/env bash
# Pick a file/dir in a tv channel and open it in $EDITOR in its own window.
#
# usage: edit-file.sh <channel>
#
# NOTE: launched from tv menu via `menu --send`, so the *picker* runs in the
# prewarmed menu window and that window is hidden again as soon as this script
# exits (it cannot open the editor itself: a follow-up queued with --send would
# be run by the same menu window, right after the picker).
#
# The editor gets a plain kitty window (no --class) because the menu window's
# WM_CLASS=menu is in xremap's "TV - word/line ops" (Alt-w, Ctrl-BackSpace) and
# "Win+C/V/X/Z -> Ctrl+C/V/X/Z" rules, which would apply to nvim as well; a
# normal kitty window matches /kitty/ and is left alone.

set -u

channel=${1:-}
if [[ -z $channel ]]; then
	printf 'usage: %s <channel>\n' "${0##*/}" >&2
	exit 1
fi

# These channels pass the path on in the *secondary* selection (their enter
# action pipes it to xsel), not on stdout: a channel that binds enter to an
# execute-mode action prints nothing at all.
#
# The selection is cleared first, because tv exits 0 on Esc just like it does
# on enter - without this a cancelled picker would reopen the last selection.
printf '' | xsel --secondary --input

tv "$channel"

selected=$(xclip -selection secondary -out 2>/dev/null) || selected=

# Nothing to edit means just letting the menu window close (exit 0), which is
# not only an empty selection: when the source yields nothing (an empty obsidian
# vault, a source command that fails) tv offers the placeholder "Command produced
# no output on stdout, checking stderr..." as selectable rows, so enter does run
# the action and the selection comes back as that text instead of being empty.
# A path that does not exist catches that, a cancelled picker and a query that
# filters every entry out (tv exits 0 there too) alike. `-e` covers both
# channels: dirs-config picks directories, files-obsidian files.
[ -n "$selected" ] && [ -e "$selected" ] || exit 0

# The path is handed over as "$1" instead of being interpolated, so spaces and
# quotes in a filename need no escaping.
(trap '' HUP; setsid ${TERMINAL:-kitty} -e bash -c 'exec "${EDITOR:-nvim}" "$1"' \
	_ "$selected" </dev/null >/dev/null 2>&1 &)