#!/usr/bin/env bash

options="Search\nClear\nSwitch primary\nEdit"

selection=$(printf '%b' "$options" | rofi -dmenu -i -p "Clipboard history")

case "$selection" in
"Search")
  rofi -modi "clipboard:greenclip print" \
    -show clipboard \
    -p "Search Clipboard"
  ;;

"Clear")
  greenclip clear
  ;;

"Switch primary")
  rofi -modi "clipboard:greenclip print" \
    -show clipboard
  ;;

"Edit")
  original_content=$(
    greenclip print |
      rofi -dmenu -p "Select item to edit"
  )

  if [ -n "$original_content" ]; then
    tmp_file=$(mktemp)

    printf '%s' "$original_content" >"$tmp_file"

    kitty -e nvim "$tmp_file"

    edited_content=$(cat "$tmp_file")

    if [ -n "$edited_content" ]; then
      printf '%s' "$edited_content" |
        xclip -selection clipboard -in
    fi

    rm -f "$tmp_file"
  fi
  ;;
esac
