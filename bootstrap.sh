#!/usr/bin/env bash
# One-shot bootstrap for a fresh machine (or re-apply on an existing one).
#
#   1. Checks for required tools, offers to install missing ones
#   2. Prompts you to create the untracked per-machine overlays:
#        ~/.zshrc.local, ~/.gitconfig.local   (from templates/)
#   3. Stows all packages into ~
#   4. Offers to install the curated package list
#
# Safe to re-run: every step is skipped or idempotent when already done.
# Flags: --dry (simulate stow), --no-packages (skip step 4)

set -euo pipefail
DOTDIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$DOTDIR"

STOW_PACKAGES=(zsh git starship ghostty zed btop tmux nvim fastfetch)

ask() {
	local reply
	read -r -p "$1 [y/N] " reply </dev/tty || reply=""
	[[ "$reply" =~ ^[Yy](es)?$ ]]
}

# --- 1. required tools ---------------------------------------------------------
printf '== Tools ==\n'
required=(stow zsh starship ghostty git tmux fzf eza bat ripgrep zoxide yazi fastfetch)
missing=()
for tool in "${required[@]}"; do
	command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
done

if ((${#missing[@]})); then
	printf 'Missing: %s\n' "${missing[*]}"
	if command -v yay >/dev/null 2>&1 && ask "Install missing tools with yay?"; then
		# shellcheck disable=SC2086
		sudo -v && yay -S --needed ${missing[@]}
	elif ask "Install repo tools with pacman?"; then
		# shellcheck disable=SC2086
		sudo -v && sudo pacman -S --needed ${missing[@]}
	else
		echo "Skipped — expect failures in later steps."
	fi
else
	echo "All tools present."
fi

# --- 2. untracked per-machine overlays -----------------------------------------
printf '\n== Editor ==\n'
pick_editor() {
	# Honor $EDITOR if set; otherwise ask and remember for this run.
	if [[ -n "${EDITOR:-}" ]]; then
		CHOSEN_EDITOR="$EDITOR"
	else
		local def="nvim" reply
		read -r -p "Editor for bootstrap prompts [nvim/nano/vi $def]: " reply </dev/tty || reply=""
		CHOSEN_EDITOR="${reply:-$def}"
	fi
	if ! command -v "$CHOSEN_EDITOR" >/dev/null 2>&1; then
		echo "'$CHOSEN_EDITOR' not found, falling back to nano."
		CHOSEN_EDITOR="nano"
	fi
	echo "Using editor: $CHOSEN_EDITOR"
}
pick_editor

printf '\n== Local overlay files (untracked, see .gitignore) ==\n'
create_overlay() {
	local src="$1" dst="$2"
	if [[ -f "$dst" ]]; then
		echo "exists: $dst"
	elif ask "Create $dst from $src and edit it now?"; then
		cp "$src" "$dst"
		"$CHOSEN_EDITOR" "$dst" </dev/tty || true
	fi
}
create_overlay templates/zshrc.local.example ~/.zshrc.local
create_overlay templates/gitconfig.local.example ~/.gitconfig.local

# Persist the choice so shells know it too
if [[ -f ~/.zshrc.local ]] && ! grep -q 'export EDITOR=' ~/.zshrc.local \
	&& ask "Store 'export EDITOR=$CHOSEN_EDITOR' in ~/.zshrc.local?"; then
	printf '\nexport EDITOR=%s\n' "$CHOSEN_EDITOR" >> ~/.zshrc.local
fi

# --- 3. stow -------------------------------------------------------------------
printf '\n== Stowing ==\n'
if [[ "${1:-}" == "--dry" ]]; then
	stow --simulate -t ~ ${STOW_PACKAGES[@]} && echo "Dry run OK — no changes made."
	exit 0
fi

if ! stow -t ~ ${STOW_PACKAGES[@]}; then
	echo
	echo "Stow reported conflicts (likely links/files already present)."
	echo "Review, or pass --adopt to fold existing files into the repo:"
	echo "  stow --adopt -t ~ zsh git starship ghostty zed btop tmux nvim fastfetch"
	exit 1
fi
echo "Stowed: ${STOW_PACKAGES[*]}"

# --- 4. optional package restore -------------------------------------------------
if [[ "${1:-}" == "--no-packages" ]]; then
	echo
	echo "Package restore skipped (--no-packages)."
	echo "Run later: $DOTDIR/packages/install-packages.sh"
else
	printf '\n== Packages ==\n'
	if ask "Install curated packages from packages/*.txt now?"; then
		"$DOTDIR/packages/install-packages.sh"
	else
		echo "Later: $DOTDIR/packages/install-packages.sh"
	fi
fi

# --- 5. personal zed fork (not on public AUR; needs its own build) ---------------
printf '\n== Zed (personal fork) ==\n'
if command -v zed >/dev/null 2>&1; then
	echo "zed present ($(zed --version 2>/dev/null | head -1))."
elif ask "Build and install the zed personal fork now? (heavy: one cargo build)"; then
	"$DOTDIR/packages/build-zed.sh"
else
	echo "Later: $DOTDIR/packages/build-zed.sh  (tracked PKGBUILD + fork setup)"
fi

echo
echo "Bootstrap complete. Open a new terminal."
