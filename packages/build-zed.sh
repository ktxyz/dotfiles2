#!/usr/bin/env bash
# Build + install the personal Zed fork (zed-personal-git).
#
# The PKGBUILD (tracked in packages/zed-personal-git/PKGBUILD) builds
# https://github.com/ktxyz/zed — branch: personal — selection word count
# in the status bar, update-polling disabled.
#
# Adds/refreshes:
#   1. ~/.aur/zed-personal-git     -> PKGBUILD home (copied from this repo)
#   2. ~/Projects/tools/zed        -> work clone (optional, skipped if present)
#   3. package built via makepkg, installed with pacman
#
# Full first build is heavy (cargo, tens of minutes to an hour).

set -euo pipefail
DOTDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd -P)"
FORK_URL="https://github.com/ktxyz/zed.git"
AUR_DIR="$HOME/.aur"
PKG_BUILD_DIR="$AUR_DIR/zed-personal-git"

ask() {
	local reply
	read -r -p "$1 [y/N] " reply </dev/tty || reply=""
	[[ "$reply" =~ ^[Yy](es)?$ ]]
}

# 1. PKGBUILD home ------------------------------------------------------------
mkdir -p "$AUR_DIR"
if [[ ! -f "$PKG_BUILD_DIR/PKGBUILD" ]]; then
	mkdir -p "$PKG_BUILD_DIR"
	cp "$DOTDIR/packages/zed-personal-git/PKGBUILD" "$PKG_BUILD_DIR/PKGBUILD"
	echo "Installed PKGBUILD into $PKG_BUILD_DIR"
else
	if ! cmp -s "$DOTDIR/packages/zed-personal-git/PKGBUILD" "$PKG_BUILD_DIR/PKGBUILD"; then
		if ask "Existing PKGBUILD differs from repo copy — overwrite with repo copy (repo edit takes precedence)?"; then
			cp "$DOTDIR/packages/zed-personal-git/PKGBUILD" "$PKG_BUILD_DIR/PKGBUILD"
		fi
	fi
fi

# 2. optional work clone --------------------------------------------------------
if [[ ! -d "$HOME/Projects/tools/zed" ]]; then
	if ask "Clone the fork to ~/Projects/tools/zed for development?"; then
		git clone git@github.com:ktxyz/zed.git "$HOME/Projects/tools/zed"
	fi
fi

# 3. build + install -------------------------------------------------------------
if command -v zed >/dev/null 2>&1 && ! ask "Zed is already installed — rebuild and replace it with a fresh fork build?"; then
	echo "Nothing to do."
	exit 0
fi

cd "$PKG_BUILD_DIR"
echo "makepkg -srf: building zed (make sure Zed is closed before install)..."
makepkg -srf

pkgfile=$(ls -1 *.pkg.tar.zst 2>/dev/null | sort | tail -1)
[[ -n "$pkgfile" ]] || { echo "No package file produced."; exit 1; }
sudo pacman -U --noconfirm --needed "$pkgfile"
echo "Installed: $pkgfile"
