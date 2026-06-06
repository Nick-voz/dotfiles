#!/usr/bin/env bash
TERMINAL="kitty -e"
EDITOR="nvim"

options="Search\nClear\nSwitch primary\nEdit"

selection=$(echo -e "$options" | rofi -dmenu -i -p "Clipboard history")

case "$selection" in
"Search")
  resp=$(greenclip print | rofi -dmenu -p "Search Clipboard")
  if [ -n "$resp" ]; then
    echo "$resp" | xclip -selection clipboard
    xdotool type --delay 0 "$resp"
  fi
  ;;

"Clear")
  greenclip clear
  ;;

"Edit")
  original_content=$(greenclip print | rofi -dmenu -p "Select item to edit")

  if [ -n "$original_content" ]; then
    tmp_file="/tmp/clip_edit"
    echo -n "$original_content" >"$tmp_file"

    $TERMINAL $EDITOR $tmp_file

    edited_content=$(cat "$tmp_file")

    if [ -n "$edited_content" ]; then
      echo -n "$edited_content" | xclip -selection clipboard
    fi

    rm "$tmp_file"
  fi
  ;;

"Switch primary")
  rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
  ;;
esac
