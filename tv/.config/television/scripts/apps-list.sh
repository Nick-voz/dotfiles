#!/usr/bin/env bash
# usage: apps-list.sh — prints "Name<TAB>path" for every visible desktop entry.
TAB=$(printf '\t')
declare -A seen
files=()
for dir in "$HOME/.local/share/applications" "$HOME/.local/share/flatpak/exports/share/applications" /var/lib/flatpak/exports/share/applications /usr/local/share/applications /usr/share/applications; do
  [ -d "$dir" ] || continue
  for f in "$dir"/*.desktop; do
    [ -f "$f" ] || continue
    id=${f##*/}
    [ -n "${seen[$id]}" ] && continue
    seen[$id]=1
    files+=("$f")
  done
done
[ ${#files[@]} -gt 0 ] || exit 0

awk '
  FNR == 1 {
    if (NR > 1) dump()
    file = FILENAME; name = ""; skip = 0; in_main = 0
  }
  /^\[/ { in_main = ($0 == "[Desktop Entry]"); next }
  in_main && /^Type=/ { if (substr($0, 6) != "Application") skip = 1; next }
  in_main && ($0 == "NoDisplay=true" || $0 == "Hidden=true") { skip = 1; next }
  in_main && /^Name=/ && name == "" { name = substr($0, 6); next }
  END { dump() }
  function dump() {
    if (!skip && name != "")
      printf "%s\t%s\n", name, file
  }
' "${files[@]}" | while IFS= read -r line; do
  name=${line%%"$TAB"*}
  file=${line#*"$TAB"}
  [ -n "$name" ] && [ -n "$file" ] || continue
  tryexec=$(grep -m1 '^TryExec=' "$file" | cut -d= -f2-)
  if [ -n "$tryexec" ]; then
    command -v "$tryexec" >/dev/null 2>&1 || continue
  fi
  printf '%s\n' "$line"
done | sort -f
