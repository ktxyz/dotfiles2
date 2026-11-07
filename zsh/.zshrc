# ~/.zshrc — interactive shell setup
# Machine-specific / personal settings belong in ~/.zshrc.local (untracked).

# Completion system
autoload -Uz compinit && compinit

# Command history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY      # share history between open terminals
setopt HIST_IGNORE_DUPS   # ignore duplicated entries

# Aliases (modern replacements)
alias ls='eza --icons'
alias ll='eza -la --icons'
alias cat='bat'

# GPU driver overrides (dual-GPU: force a specific Vulkan driver)
alias vk-intel='VK_DRIVER_FILES=/usr/share/vulkan/icd.d/intel_icd.json'
alias vk-amd='VK_DRIVER_FILES=/usr/share/vulkan/icd.d/radeon_icd.json'

# Prompt: Starship
eval "$(starship init zsh)"

# Smart directory jumping (use with: z Projects)
eval "$(zoxide init zsh)"

# yazi file manager — exits back into the directory you were browsing
function yazi() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX" --directory)"
	command yazi "$@" --cwd-file="$tmp"
	if [[ -s "$tmp" ]]; then
		builtin cd -- "$(cat "$tmp")" && { pwd > "$PWD"; } || true
	fi
	rm -f -- "$tmp"
}

# zsh plugins (ledger/system packages)
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# fzf key bindings and completion
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# SSH agent auto-start
if [ -z "$SSH_AUTH_SOCK" ]; then
	eval "$(ssh-agent -s)" >/dev/null
	ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# Ensure PATH is set up also in non-login shells (ghostty/konsole tabs)
source ~/.zprofile

# Untracked per-machine layer (env vars, exports, personal stuff)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Pi agent harness: session shortcuts
alias pc='pi --continue'
alias pn='pi -p'

# Pipe-review: send a diff through a one-shot pi session
pirev() {
	git diff "$@" | pi -p "Review this diff. Blocking/Suggested/Nit findings only, file:line refs, no praise."
}

# Navigation: Ctrl+Arrow jumps by words
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
bindkey '^[[5C' forward-word
bindkey '^[[5D' backward-word

# Home / End / Delete
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
