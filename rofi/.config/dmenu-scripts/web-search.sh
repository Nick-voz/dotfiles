#!/usr/bin/env bash
set -euo pipefail
BROWSER="firefox --new-tab "
MENU="rofi -dmenu -i"

declare -A websearch=(
  # [bing]="https://www.bing.com/search?q="
  # [brave]="https://search.brave.com/search?q="
  # [duckduckgo]="https://duckduckgo.com/?q="
  [google]="https://www.google.com/search?q="
  # [qwant]="https://www.qwant.com/?q="
  # [swisscows]="https://swisscows.com/web?query="
  [yandex]="https://yandex.com/search/?text="
  # [wikipedia]="https://en.wikipedia.org/w/index.php?search="
  # [wiktionary]="https://en.wiktionary.org/w/index.php?search="
  [reddit]="https://www.reddit.com/search/?q="
  [youtube]="https://www.youtube.com/results?search_query="
  [github]="https://github.com/search?q="
  [gitlab]="https://gitlab.com/search?search="
  [stackoverflow]="https://stackoverflow.com/search?q="
  # [amazon]="https://www.amazon.com/s?k="
  # [ebay]="https://www.ebay.com/sch/i.html?&_nkw="
  [archwiki]="https://wiki.archlinux.org/index.php?search="
  [archaur]="https://aur.archlinux.org/packages/?O=0&K="
)

# URL encode function
urlencode() {
  local str="$1"
  local length="${#str}"
  local i char out=""

  for (( i=0; i<length; i++ )); do
    char="${str:i:1}"
    case "$char" in
      [a-zA-Z0-9.~_-]) out+="$char" ;;
      ' ') out+="+" ;;
      *) printf -v hex '%%%02X' "'$char"; out+="$hex" ;;
    esac
  done

  printf '%s\n' "$out"
}

main() {
  local engine query encoded url

  engine=$(
    printf '%s\n' "${!websearch[@]}" | sort | $MENU -p "Choose search engine"
  ) || exit 0

  [ -n "$engine" ] || exit 1

  query=$(
    printf '' | $MENU -p "Enter search query"
  ) || exit 0

  [ -n "$query" ] || exit 0

  encoded="$(urlencode "$query")"
  url="${websearch[$engine]}${encoded}"

  $BROWSER $url 2>/dev/null &
}

main "$@"
