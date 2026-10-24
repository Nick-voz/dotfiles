#!/usr/bin/env bash
# usage: downloads-list.sh
# Rows: path<TAB>name<TAB>size<TAB>date, newest first. First-level entries of
# ~/Downloads only (files and dirs); dotfiles are skipped, so in-progress
# .part/.crdownload never appear. Dirs print '-' instead of a du'd size.

dir="$HOME/Downloads"
[ -d "$dir" ] || exit 0

find "$dir" -mindepth 1 -maxdepth 1 ! -name '.*' -printf '%T@\t%s\t%TY-%Tm-%Td %TH:%TM\t%p\n' 2>/dev/null |
  sort -rn |
  while IFS=$'\t' read -r _ size date path; do
    if [ -d "$path" ]; then size='-'; else size=$(numfmt --to=iec -- "$size"); fi
    printf '%s\t%s\t%s\t%s\n' "$path" "${path##*/}" "$size" "$date"
  done
