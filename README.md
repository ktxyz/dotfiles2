# dotfiles2 — Electric Bungaloo

GNU Stow–managed dotfiles for an EndeavourOS (Arch) + KDE Plasma machine.
Target is `~`; every directory here is one stow package.

## Structure

| Package   | What it stows                                  |
|-----------|------------------------------------------------|
| `zsh`     | `~/.zshrc`                                     |
| `git`     | `~/.gitconfig`, `~/.config/git/ignore`         |
| `starship`| `~/.config/starship.toml` (Nord powerline)     |
| `ghostty` | `~/.config/ghostty/config`                     |
| `zed`     | `~/.config/zed/` (settings + themes)           |
| `btop`    | `~/.config/btop/`                              |
| `tmux`    | `~/.tmux.conf` (Nord statusline)               |
| `nvim`    | `~/.config/nvim/init.lua` (kickstart-style)    |
| `fastfetch`| `~/.config/fastfetch.jsonc`                   |
| `packages`| curated package manifests + helper scripts     |
| `templates` | examples for untracked `~/.zshrc.local`, `~/.gitconfig.local` |

`bootstrap.sh` at the repo root automates the whole bootstrap (below).

## Bootstrap (fresh machine)

```bash
git clone git@github.com:ktxyz/dotfiles2.git ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh            # tools check, local overlays, stow, packages
```

Useful flags: `--dry` (simulate stow only), `--no-packages`.

Manual equivalent, if you prefer:

```bash
sudo pacman -S --needed stow zsh starship ghostty git tmux fzf \
	eza bat ripgrep zoxide yazi fastfetch
stow -t ~ zsh git starship ghostty zed btop tmux nvim fastfetch
packages/install-packages.sh          # optional: restore package set
```

## Personal, untracked overlays

Anything machine- or identity-specific stays out of the repo:

- `~/.gitconfig.local` — user name/email/signing key
- `~/.zshrc.local` — env vars, exports (sourced from `.zshrc` if present)

## Editor setups

- **Neovim** — kickstart-style single file (`~/.config/nvim/init.lua`);
  mostly stays out of the way.
- **Zed** — built from your **own fork**, with selection word count in the
  status bar and upstream update-polling disabled. It is NOT on the public
  AUR — the PKGBUILD is tracked at `packages/zed-personal-git/PKGBUILD`,
  and `packages/build-zed.sh` wires the whole thing up:
  - `~/.aur/zed-personal-git/` — copied known-good PKGBUILD (adjust only via
    this repo's copy so it stays traceable)
  - `~/Projects/tools/zed/` — development clone of `github.com/ktxyz/zed`
    (branch: `personal`), cloned only if missing
  - `makepkg -srf` in the PKGBUILD dir, then installs the .pkg with pacman
  - refuse default upstream `zed`; it conflicts and would overwrite your fork

## Packages

- `packages/packages-repo.txt` — repo packages (pacman), one per line
- `packages/packages-aur.txt` — AUR packages (yay)
- `packages/install-packages.sh` — install the manifests
- `packages/export-package-report.sh` — diff current install vs manifest

Curation state (2026-11-08): printers, X11 stack, EOS default cruft and
unused editors removed; `fzf` promoted to explicit. `zed` is a **personal
fork** — see "Editor setups" above for its dedicated bootstrap via
`packages/build-zed.sh`.

## Later rounds

Plasma ricing (kwin/kdeglobals), gaming stack (MangoHud, vkBasalt,
easyeffects) — not tracked yet by design.
