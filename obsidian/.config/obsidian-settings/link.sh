#!/bin/sh
# Link shared Obsidian settings into a vault's .obsidian directory.
# Usage: link.sh <vault-dir> [<vault-dir> ...]
# Canonical settings live next to this script (~/.config/obsidian-settings).
# Everything NOT listed below stays local to each vault
# (workspace.json, bookmarks.json, graph.json, types.json, caches).
set -eu

CANON="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SHARED="app.json appearance.json backlink.json community-plugins.json
core-plugins.json core-plugins-migration.json daily-notes.json hotkeys.json
note-composer.json page-preview.json templates.json zk-prefixer.json
plugins snippets themes"

for vault in "$@"; do
    conf="$vault/.obsidian"
    [ -d "$conf" ] || mkdir -p "$conf"
    for item in $SHARED; do
        [ -e "$CANON/$item" ] || continue
        if [ -L "$conf/$item" ]; then
            ln -sfn "$CANON/$item" "$conf/$item"
        elif [ -e "$conf/$item" ]; then
            echo "link.sh: $conf/$item exists as a real file, not touching" >&2
        else
            ln -s "$CANON/$item" "$conf/$item"
        fi
    done
done
