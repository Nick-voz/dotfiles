#!/usr/bin/env bash
# usage: dirs-favorites.sh
# Prints the immediate child dirs of the favorite prefixes, in the order listed.

# Add or remove favorite prefixes here.
PREFIXES=(
  "$HOME/Projects"
  "$HOME/Documents"
  "$HOME/Documents/rgpu/"
)

for prefix in "${PREFIXES[@]}"; do
  [ -d "$prefix" ] && fd -t d --max-depth 1 . "$prefix"
done
