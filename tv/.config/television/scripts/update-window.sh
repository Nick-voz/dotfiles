#!/usr/bin/env bash
# usage: update-window.sh — open a plain kitty window and run fish there.
( trap '' HUP
  setsid "${TERMINAL:-kitty}" fish -C update </dev/null >/dev/null 2>&1 &
)
