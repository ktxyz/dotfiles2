#!/usr/bin/env bash
# Export the *current* installed package state for reference/diffing.
# The curated manifests live in packages-repo.txt / packages-aur.txt
# and are maintained by hand.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p .generated
echo ".generated/" > .gitignore

pacman -Qqe | sort > .generated/installed-all.txt
pacman -Qqme | sort > .generated/installed-aur.txt
echo "Wrote .generated/installed-all.txt ($(wc -l < .generated/installed-all.txt) entries)"
echo "Wrote .generated/installed-aur.txt  ($(wc -l < .generated/installed-aur.txt) AUR entries)"

clean() { grep -v -e '^\s*#' -e '^\s*$' "$1" 2>/dev/null | sort || true; }

echo
echo "--- packages-repo.txt vs installed (only in manifest = already covered) ---"
comm -23 <(clean packages-repo.txt) <(cat .generated/installed-all.txt .generated/installed-aur.txt | sort -u) \
	| sed 's/^/missing: /'
echo "--- installed but NOT in manifest (candidates for removal / review) ---"
comm -13 <(clean packages-repo.txt) .generated/installed-all.txt \
	| sed 's/^/extra: /'
