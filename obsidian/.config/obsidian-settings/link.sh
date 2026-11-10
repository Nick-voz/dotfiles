#!/bin/sh
# Link shared Obsidian settings into a vault's .obsidian directory.
# Usage: link.sh <vault-dir> [<vault-dir> ...]
# Canonical settings live next to this script (~/.config/obsidian-settings).
# Everything NOT linked here stays local to each vault
# (workspace.json, bookmarks.json, graph.json, types.json, caches).
set -eu

CANON="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SHARED="app.json appearance.json backlink.json community-plugins.json
core-plugins.json core-plugins-migration.json daily-notes.json hotkeys.json
note-composer.json page-preview.json templates.json zk-prefixer.json
snippets themes"

# Plugins keeping per-vault state files in their data dir: these get a real
# dir in the vault with per-file symlinks to the canon, skipping state files
# (they are regenerated locally; do not link them or two vaults fight over one file).
PLUGINS_LOCAL="obsidian-quiet-outline"
PLUGINS_LOCAL_SKIP_GLOBS='markdown-states*'

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

    # plugins/: whole-dir symlink by default, per-file for PLUGINS_LOCAL ones
    if [ -L "$conf/plugins" ]; then rm "$conf/plugins"; fi
    mkdir -p "$conf/plugins"
    for pd in "$CANON"/plugins/*/; do
        [ -d "$pd" ] || continue
        pname="$(basename "$pd")"
        target="$conf/plugins/$pname"
        case " $PLUGINS_LOCAL " in *" $pname "*)
            if [ -L "$target" ]; then rm "$target"; fi
            mkdir -p "$target"
            for f in "$pd"/*; do
                [ -e "$f" ] || continue
                fname="$(basename "$f")"
                case "$fname" in $PLUGINS_LOCAL_SKIP_GLOBS) continue ;; esac
                if [ -L "$target/$fname" ]; then
                    ln -sfn "${pd%/}/$fname" "$target/$fname"
                elif [ ! -e "$target/$fname" ]; then
                    ln -s "${pd%/}/$fname" "$target/$fname"
                fi
            done
            ;;
        *)
            if [ -e "$target" ] && [ ! -L "$target" ]; then
                echo "link.sh: $target exists as a real dir, not touching" >&2
            else
                ln -sfn "${pd%/}" "$target"
            fi
            ;;
        esac
    done
done
