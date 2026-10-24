#!/usr/bin/env bash
# usage: downloads-preview.sh <path>
# Dispatch by mime only; a missing path (tv's empty-source placeholder row)
# prints one line instead of error spam.

path=${1:-}
[ -n "$path" ] && [ -e "$path" ] || { echo 'nothing to preview'; exit 0; }

if [ -d "$path" ]; then
  eza -la --color=always --group-directories-first "$path" | head -40
  exit 0
fi

mime=$(file --mime-type -b -- "$path")
printf '%s · %s · %s\n\n' "$(numfmt --to=iec -- "$(stat -c %s -- "$path")")" \
  "$(stat -c %y -- "$path" | cut -d. -f1)" "$mime"

case "$mime" in
  text/* | application/json | application/javascript | application/xml | application/x-sh | application/x-shellscript | application/x-python*)
    bat -p --color=always --wrap=never --line-range=1:200 -- "$path" 2>/dev/null
    ;;
  application/zip) unzip -l -- "$path" | head -40 ;;
  application/x-tar | application/gzip | application/x-bzip2 | application/x-xz)
    tar -tvf "$path" 2>/dev/null | head -40
    ;;
  application/x-7z-compressed | application/vnd.rar | application/x-rar-compressed*)
    7z l -- "$path" 2>/dev/null | sed -n '/^----/,$p' | head -40
    ;;
  image/*) identify -- "$path" | head -10 ;;
  video/* | audio/*)
    ffprobe -v error -show_entries format=duration,size,bit_rate \
      -show_entries stream=codec_type,codec_name,width,height \
      -of default=noprint_wrappers=1 -- "$path" 2>&1
    ;;
  application/pdf)
    if command -v pdftotext >/dev/null; then
      pdftotext "$path" - 2>/dev/null | head -30
    else
      file -b -- "$path"
    fi
    ;;
  *) file -b -- "$path" ;;
esac
