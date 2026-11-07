#!/usr/bin/env bash
# Install everything from the curated manifests:
#   packages-repo.txt -> pacman, packages-aur.txt -> yay
# Only --needed: packages already present are skipped.
set -euo pipefail
cd "$(dirname "$0")"

list() { grep -v -e '^\s*#' -e '^\s*$' "$1" 2>/dev/null || true; }

repo=$(list packages-repo.txt)
aur=$(list packages-aur.txt)

if [[ -n "$repo" ]]; then
	echo "Installing repo packages with pacman..."
	echo "$repo" | sudo pacman -S --needed -
fi

if [[ -n "$aur" ]]; then
	command -v yay >/dev/null || { echo "yay not found"; exit 1; }
	# shellcheck disable=SC2086
	yay -S --needed $aur
fi
