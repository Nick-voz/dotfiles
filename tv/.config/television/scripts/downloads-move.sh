#!/usr/bin/env bash
# usage: downloads-move.sh <path>
# Target dir is picked with a nested `tv dirs-favorites`; the name is edited
# with a readline one-liner pre-filled with the original minus a duplicate
# " (N)" suffix. Collisions never overwrite: the prompt reopens with an
# auto-bumped suggestion. Any cancel path refreshes the list.

path=${1:-}
case "$path" in "$HOME/Downloads/"*) ;; *) exit 0 ;; esac
[ -e "$path" ] || exit 0

name=${path##*/}

reopen() {
  if [ -t 1 ]; then exec tv downloads; fi
  exit 0
}

target=$(tv dirs-favorites)
[ -d "$target" ] || reopen

clean=$(printf '%s\n' "$name" | sed -E 's/ \([0-9]+\)(\.[^.]*)?$/\1/')

bump() { # smallest " (N)" suffix free in the target dir
  local n=$1 i=1
  while [ -e "$target/$n" ]; do
    case $1 in
      *.*) n="${1%.*} ($i).${1##*.}" ;;
      *) n="$1 ($i)" ;;
    esac
    i=$((i + 1))
  done
  printf '%s\n' "$n"
}

trap 'aborted=1' INT
# xremap injects raw ESC-w/ESC-u into the menu window (AGENTS.md); teach
# readline that, like translate.sh/web-search.sh do.
bind '"\ew": backward-kill-word' '"\eu": backward-kill-line' 2>/dev/null
while :; do
  suggest=$(bump "$clean")
  REPLY=
  read -r -e -i "$suggest" \
    -p "New name (Enter keeps it, Ctrl-U clears to retype, empty keeps '$name', Ctrl-C cancels): " || aborted=1
  [ "${aborted:-}" = 1 ] && reopen
  new=$REPLY
  [ -n "$new" ] || new=$name
  case $new in
    */* | . | ..) printf 'not a name: %s\n' "$new" >&2; continue ;;
  esac
  [ -e "$target/$new" ] || break
  clean=$new
done

mv -- "$path" "$target/$new"
notify-send "Moved" "$new → ${target#"$HOME"/}" >/dev/null 2>&1 || true
reopen
