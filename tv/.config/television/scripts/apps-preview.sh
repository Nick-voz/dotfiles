#!/usr/bin/env bash
# usage: apps-preview.sh <desktop-entry> — prints its [Desktop Entry] fields.
file=${1:?usage: apps-preview.sh <desktop-entry>}
awk '/^\[/{m=($0=="[Desktop Entry]")} m' "$file" |
  grep -E '^(Name|GenericName|Comment|Exec|TryExec|Path|Categories|Keywords|Terminal|StartupWMClass)='
