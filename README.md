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

## Pi coding agent

Pi (1.5+, `pi.dev`) is installed via the official installer and configured
here.

- **Stow package** `pi/` — links `~/.pi/agent/{settings.json,AGENTS.md}` and
  `~/.pi/agent/skills/pi-skills` (git submodule) into the managed agent dir.
  The agent dir itself stays real: it hosts pi's managed runtime (`bin/`,
  `install/`), sessions, and credentials — never stowed wholesale.
- **Credentials** — untracked `~/.zshrc.local` exports
  `OPENROUTER_API_KEY`; pi reads provider env vars natively, no `auth.json`.
- **Providers**: OpenRouter only. Claude's subscription OAuth is banned for
  third-party harnesses since 2026-04 (Anthropic ToS) — deliberate choice,
  do not "fix" it back into auth by reconnecting a Pro/Max subscription.
  The opencode-go account does not expose API keys.
- **Models** (verified via `pi --list-models`, 2026-11-08):
  - default/cheap: `openrouter/z-ai/glm-latest`, thinking `medium`
  - Sonnet: `openrouter/anthropic/claude-sonnet-5.5`, thinking `medium`
  - Opus: `openrouter/anthropic/claude-opus-5`, thinking `high`
  - cycle (Ctrl+P) adds `google/gemini-3*` and `x-ai/grok-4.6`
- **Packages** (declared + pinned in `settings.json`, auto-installed by pi):
  seatbelt (approvals), lens, pi-usage, powerline-footer, web-search,
  ask-user-question, plannotator, subagents, context-prune, memory,
  pi-skills (submodule), and the à-la-carte archimedes set
  (`core`, `diff`, `session-name`, `notify`, `image-paste`, `todo`).
- **Trial-tier, deliberately off**: `billion-context`, `context-mode`
  (heavier compression/proxy approaches — try with `pi -e npm:<name>`
  only for marathon sessions).
- **Shell sugar** (in `zsh/`): `pc` continue, `pn` one-shot, `pirev` (diff
  review via stdin pipe).
- **Runtime support**: `qmd` (npm user-prefix, powers `memory_search`) and
  `fd` (pacman) are required by extensions; pi auto-vendored `fd` into
  `~/.pi/agent/bin/` once — prefer the system package.
- **Seatbelt** config (tracked): `pi/.pi/agent/seatbelt/config.json` —
  classifier on cheap `z-ai/glm-flash-latest`, mode `auto` (learns your
  approve/reject pattern; cycle modes with `alt+s`). Notes: classifier calls
  bill to the OpenRouter wallet; a `rm`-class chain can take a couple of
  seconds to label.
- **pi-memory**: exit summaries are LLM-called on every quit — pinned to the
  cheap default via env in `~/.zshrc.local`
  (`PI_MEMORY_EXIT_SUMMARY_MODEL`, `PI_MEMORY_EXIT_SUMMARY_REASONING_EFFORT=low`).
- **Keybindings** (tracked): `pi/.pi/agent/keybindings.json` releases
  `ctrl+v` to archimedes image-paste (the documented unbind of
  `app.clipboard.pasteImage`).
- **Prompt templates**: `/review-diff` and `/research` in `pi/.pi/prompts/`.
- **Security**: `defaultProjectTrust: "ask"`; podman-isolated runs are a
  future round for unattended/hostile code.
- **Update**: `pi update` (self), `pi update --extensions` (packages),
  `pi update --models` (catalog). To bump pinned package versions: edit
  `packages` in `pi/.pi/agent/settings.json`, run `pi update --extensions`.

## Later rounds

Plasma ricing (kwin/kdeglobals), gaming stack (MangoHud, vkBasalt,
easyeffects) — not tracked yet by design.
