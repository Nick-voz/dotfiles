#!/usr/bin/env bash
# usage: stow-target.sh <path>
# Prints where stow deployed <path> (only paths inside the dotfiles repo are
# mapped), or <path> unchanged when there is no single unambiguous target.

set -u

picked=${1:-}
if [[ -z $picked ]]; then
	printf 'usage: %s <path>\n' "${0##*/}" >&2
	exit 1
fi

picked=${picked%/}
canon=$(readlink -f -- "$picked") || canon=
repo=$(readlink -f -- "${DOTFILES_DIR:-$HOME/dotfiles}")

if [[ -z $canon || $canon != "$repo"/* ]]; then
	printf '%s\n' "$picked"
	exit 0
fi

pkg=${canon#"$repo"/}
pkgdir=$repo/${pkg%%/*}
rest=${canon#"$pkgdir"}

# $HOME and the XDG roots mix links from several packages, never a target themselves.
shared() {
	case $1 in
	"$HOME" | "$HOME/.config" | "$HOME/.local" | "$HOME/.local/share" | \
		"$HOME/.local/bin" | "$HOME/.local/state" | "$HOME/.ssh") ;;
	*) return 1 ;;
	esac
}

# Is $2 a deployed location of $1? A symlinked dir, or a dir holding links into it.
deployed() {
	local pick=$1 cand=$2 link target
	[[ -e $cand ]] || return 1
	[[ $(readlink -f -- "$cand") == "$pick" ]] && return 0
	[[ -d $cand ]] || return 1
	for link in "$cand"/*; do
		[[ -L $link ]] || continue
		target=$(readlink -f -- "$link")
		[[ $target == "$pick" || $target == "$pick"/* ]] && return 0
	done
	return 1
}

if [[ -n $rest ]] && ! shared "$HOME$rest" && deployed "$canon" "$HOME$rest"; then
	printf '%s\n' "$HOME$rest"
	exit 0
fi

found=()
level=
while IFS=$'\t' read -r depth dir; do
	if [[ $depth != "$level" ]]; then
		((${#found[@]})) && break
		level=$depth
	fi
	cand=$HOME${dir#"$pkgdir"}
	shared "$cand" && continue
	deployed "$dir" "$cand" && found+=("$cand")
done < <(find "$pkgdir" -mindepth 1 -maxdepth 4 -type d -printf '%d\t%p\n' 2>/dev/null | sort -k1,1n -k2,2)

if ((${#found[@]} == 1)); then
	printf '%s\n' "${found[0]}"
else
	printf '%s\n' "$picked"
fi