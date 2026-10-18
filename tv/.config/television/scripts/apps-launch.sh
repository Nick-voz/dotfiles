#!/usr/bin/env bash
# usage: apps-launch.sh <desktop-entry> — launches the app detached from tv.
file=${1:?usage: apps-launch.sh <desktop-entry>}
if [ "$(grep -m1 '^Terminal=' "$file" | cut -d= -f2-)" = true ] &&
  grep -q -m1 '^Exec=' "$file"; then
  exec_line=$(grep -m1 '^Exec=' "$file" | cut -d= -f2- |
    sed -e 's/ %[fFuUdDnNickvm]//g' -e 's/%[fFuUdDnNickvm]//g')
  dir=$(grep -m1 '^Path=' "$file" | cut -d= -f2-)
  export TV_APP_EXEC="$exec_line" TV_APP_DIR="${dir:-$HOME}"
  (trap '' HUP; setsid "${TERMINAL:-kitty}" -e bash -c 'cd "$TV_APP_DIR" && set -f && eval "exec $TV_APP_EXEC"' </dev/null >/dev/null 2>&1 &)
else
  (trap '' HUP; setsid gio launch "$file" </dev/null >/dev/null 2>&1 &)
fi
