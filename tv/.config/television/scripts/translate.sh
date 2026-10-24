#!/usr/bin/env bash
# usage: translate.sh [query]  — no arg: prompt (empty = latest clip);
# TRANSLATE_TEST=1 prints rows instead of opening tv.
set -uo pipefail

UA='Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0'
WEB='https://translate.googleapis.com/translate_a/single'
REST='https://translation.googleapis.com/language/translate/v2'
KEY="${GOOGLE_TRANSLATE_KEY:-AIzaSyBOti4mM-6x9WDnZIjIeyEU21OpBXqWBgw}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/tv-translate"

# a client that answered non-200 is skipped for 15 min (blocks lasted 45+);
# blocked files hold the epoch of the last refusal
blocked()       { [ -f "$CACHE/$1" ] && [ "$(date +%s)" -lt $(("$(cat "$CACHE/$1")" + 900)) ]; }
mark_blocked()  { mkdir -p "$CACHE"; date +%s >"$CACHE/$1"; }
clear_blocked() { rm -f "$CACHE/$1"; }

latest_clip() {
  local id json
  id=$(clipcatctl list 2>/dev/null | head -1 | cut -d: -f1)
  [ -n "$id" ] || return 1
  json=$(busctl --user --json=short call org.clipcat.clipcat /org/clipcat/clipcat/manager \
    org.clipcat.clipcat.Manager Get t "0x$id" 2>/dev/null) || return 1
  [[ "$(jq -r '.data[3]' <<<"$json")" == text/* ]] || return 1
  python3 -c 'import json,sys; sys.stdout.buffer.write(bytes(json.load(sys.stdin)["data"][1]))' <<<"$json"
}

# both yield the same shape: [ [segments], [dictionary], detected ]
fetch_web() { # $1 = client, $2 = tl; prints json, marks the client blocked on refusal
  local code body
  body=$(curl -sS -m 5 -A "$UA" -w $'\n%{http_code}' --get "$WEB" \
    --data-urlencode "client=$1" --data-urlencode 'sl=auto' --data-urlencode "tl=$2" \
    --data-urlencode 'dt=t' --data-urlencode 'dt=bd' --data-urlencode "q=$query" 2>/dev/null) \
    || return 1 # transport error: not a refusal, keep the client unmarked
  code=${body##*$'\n'} body=${body%$'\n'*}
  if printf '%s' "$body" | jq -ec 2>/dev/null \
      'if type == "array" and ((.[0] // []) | length) > 0 then . else error end'; then
    clear_blocked "blocked-$1"
  else
    [ "$code" = 200 ] || mark_blocked "blocked-$1" # 429 / anti-bot HTML
    return 1
  fi
}

fetch_rest() {
  curl -fsS -m 5 --get "$REST" \
    --data-urlencode "key=$KEY" --data-urlencode "target=$1" --data-urlencode "q=$query" 2>/dev/null |
  jq -ec 'if ((.data.translations // []) | length) > 0
          then [[.data.translations[] | [.translatedText, .input]], null,
               .data.translations[0].detectedSourceLanguage]
          else error end'
}

translate_fetch() { # $1 = target lang; sets resp, fails if all endpoints do
  blocked blocked-at    || { resp=$(fetch_web at "$1")    && [ -n "$resp" ] && return 0; }
  blocked blocked-tw-ob || { resp=$(fetch_web tw-ob "$1") && [ -n "$resp" ] && return 0; }
  resp=$(fetch_rest "$1") && [ -n "$resp" ] && return 0
  return 1
}

# word variants when translate_a is throttled; $1 = target code (en|ru), $2 = word
wiki_variants() {
  local wiki
  [ "$1" = ru ] && wiki='en.wiktionary.org' || wiki='ru.wiktionary.org'
  curl -fsS -m 8 -A "$UA" --get "https://$wiki/w/api.php" \
    --data-urlencode 'action=parse' --data-urlencode "page=$2" \
    --data-urlencode 'prop=wikitext' --data-urlencode 'format=json' 2>/dev/null |
  jq -er '.parse.wikitext["*"]' 2>/dev/null | {
    if [ "$1" = ru ]; then
      grep -oE "\{\{t\+?\|[[:space:]]*ru[[:space:]]*\|[^}|[]+" | awk -F'|' '{print $3}'
    else
      awk '/^=== *Перевод/,/^==[^=]/' | grep -oE "\|[[:space:]]*en[[:space:]]*=[^}]*" | cut -d= -f2- | tr ',' '\n'
    fi
  } | sed 's/\[\[//g; s/\]\]//g; s/{{[^}]*//g' | tr -d '\314\201' \
     | sed 's/^ *//; s/ *$//' | grep -v '^$' | awk '!seen[$0]++' | head -12
}

browser_fallback() {
  local url
  url="https://translate.google.com/?sl=auto&tl=$tl&op=translate&text=$(jq -rn --arg s "$query" '$s | @uri')"
  printf 'Google API unreachable, opening browser: %s\n' "$url"
  (trap '' HUP; setsid firefox --new-tab "$url" </dev/null >>/tmp/translate.log 2>&1 &)
  sleep 1
}

query="${1:-}"
if [ -z "$query" ]; then
  printf 'Translate: '
  IFS= read -r query || exit 0
  [ -n "${query//[[:space:]]/}" ] || query=$(latest_clip) || { printf 'no text on clipboard\n'; exit 0; }
fi
query=$(printf '%s' "$query" | tr '\n\r\t' '   ' | sed 's/^ *//; s/ \+/ /g; s/ $//')
[ -n "$query" ] || exit 0

if [[ "$query" =~ [А-Яа-яЁё] ]]; then tl=en; else tl=ru; fi

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
rows="$work/rows"

wpid='' flipped=0
if [ -n "${TRANSLATE_FIXTURE:-}" ]; then # saved web json; skips the network for testing
  resp="$(cat "$TRANSLATE_FIXTURE")"
  det="$(jq -r '.[2] // empty' <<<"$resp")"
else
  # the wiki call is the slowest and only serves single words without a
  # dictionary: start it speculatively and only consume it when needed
  [[ $query != *[[:space:]]* ]] && { wiki_variants "$tl" "$query" >"$work/wiki" & wpid=$!; }
  translate_fetch "$tl" || { browser_fallback; exit 0; }
  det=$(jq -r '.[2] // empty' <<<"$resp")
  if [ -n "$det" ] && [ "$det" = "$tl" ]; then # heuristic missed: input already in target language
    other=ru; [ "$tl" = ru ] && other=en
    if translate_fetch "$other"; then
      tl="$other" flipped=1
      det=$(jq -r '.[2] // empty' <<<"$resp")
    fi
  fi
fi

src="${det:-}"
[ -n "$src" ] || { [[ $query =~ [А-Яа-яЁё] ]] && src=ru || src=en; }
hdr="${src^} → ${tl^}"

# word: dictionary entries sorted by confidence, capped; fallback: single
# word + no dict (throttled) -> wiktionary variants; text: row per segment
dict=$(jq -r '.[1] // [] | .[] | . as [$pos, $t, $e] | ($e // [])[]
  | [(.[3] // 0), .[0], $pos, ((.[1] // [])[0:4] | join(", "))] | @tsv' <<<"$resp" 2>/dev/null)
if [ -n "$dict" ]; then
  printf '%s\n' "$dict" | LC_ALL=C sort -t $'\t' -k1,1gr | cut -f2- | head -12 >"$rows"
else
  wv='' main=''
  if [[ $query != *[[:space:]]* ]] && { [ "$det" = en ] || [ "$det" = ru ]; }; then
    main=$(jq -r '[.[0][][0]] | join("")' <<<"$resp")
    if [ -n "$wpid" ]; then
      wait "$wpid"
      wv=$(cat "$work/wiki")
      # speculative run used the pre-flip target language: redo if it changed
      [ "$flipped" = 1 ] && wv=$(wiki_variants "$tl" "$query")
    else
      wv=$(wiki_variants "$tl" "$query")
    fi
    [ -z "$wv" ] || [ -z "$main" ] || wv=$(printf '%s\n' "$wv" | grep -vxF "$main" || true)
  fi
  if [ -n "$wv" ]; then
    { [ -z "$main" ] || printf '%s\t\t\n' "$main"
      printf '%s\n' "$wv" | sed $'s/$/\t\t/'; } >"$rows"
  else
    jq -r '.[0][] | [(.[0] // ""), (.[1] // ""), ""] | @tsv' <<<"$resp" >"$rows"
  fi
fi
[ -s "$rows" ] || { browser_fallback; exit 0; }

if [ -n "${TRANSLATE_TEST:-}" ]; then
  sed $'s/\t/  |  /g' "$rows"
  exit 0
fi

TRANSLATE_ROWS="$rows" tv translate --input-header "$hdr"
