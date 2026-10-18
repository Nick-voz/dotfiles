#!/usr/bin/env bash
# usage: clipboard-preview.sh <clip-id>
# Renders a clipcat entry for the tv preview panel (see AGENTS.md).
set -uo pipefail

json=$(busctl --user --json=short call org.clipcat.clipcat \
  /org/clipcat/clipcat/manager org.clipcat.clipcat.Manager \
  Get t "0x${1:?usage: clipboard-preview.sh <clip-id>}" 2>/dev/null) || exit 0
jq -e '.data[1] | length > 0' >/dev/null <<<"$json" || {
  echo "clip not found"
  exit 0
}

case "$(jq -r '.data[3]' <<<"$json")" in
text/*)
  python3 -c 'import json, sys; sys.stdout.buffer.write(bytes(json.load(sys.stdin)["data"][1]))' \
    <<<"$json" | bat --style=plain --color=always --wrap=never
  ;;
*)
  jq -r '"no preview: \(.data[3])"' <<<"$json"
  ;;
esac