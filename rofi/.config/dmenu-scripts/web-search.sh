#!/usr/bin/env bash
set -euo pipefail

# NOTE: engine names must match tv/.config/television/cable/web-search.toml source
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

# URL encode function (byte-wise, UTF-8 safe)
urlencode() {
  local str="$1"
  local i char hex out=""

  for (( i=0; i<${#str}; i++ )); do
    char="${str:i:1}"
    case "$char" in
      [a-zA-Z0-9.~_-]) out+="$char" ;;
      ' ') out+="+" ;;
      *)
        # %XX for every byte of the char (handles multibyte UTF-8)
        hex="$(printf '%s' "$char" | od -An -tx1 | tr -d ' \n' | sed 's/../%&/g')"
        out+="$hex"
        ;;
    esac
  done

  printf '%s\n' "$out"
}

main() {
  local engine query encoded url
  local log="/tmp/web-search.log"

  # engine is picked in tv, passed back via secondary selection (like Edit config flow).
  # Runs inside kitty (see menu), so the query is read from the terminal, not rofi.
  printf '' | xsel --secondary --input
  tv web-search || exit 0

  engine="$(xclip -selection secondary -out)" || exit 0

  [ -n "$engine" ] || exit 0
  if [ -z "${websearch[$engine]:-}" ]; then
    printf 'Unknown engine: %s\nPress Enter to close...' "$engine"
    read -r _ || true
    exit 1
  fi

  printf 'Enter search query: '
  read -r query || exit 0

  [ -n "$query" ] || exit 0

  encoded="$(urlencode "$query")"
  url="${websearch[$engine]}${encoded}"

  printf 'Opening [%s]: %s\n' "$engine" "$url"
  if firefox --new-tab "$url" >>"$log" 2>&1 & then
    # brief confirmation so a slow browser start isn't mistaken for failure
    sleep 1
  else
    printf 'Failed to launch firefox (see %s). Press Enter to close...' "$log"
    read -r _ || true
    exit 1
  fi
}

main "$@"
