# Global instructions (all Pi sessions)

## Communication
- Terse. No preamble, no restating the task, no "great question".
- English everywhere, including code comments (machine is Polish-plumbed, output English).
- Prefer tables/bullets over prose for findings. One-line answers when possible.

## System
- Arch Linux (EndeavourOS), zsh, KDE Plasma Wayland. Assume eza/bat/rg/fzf exist.
- Toolchains: clang/llvm/lld, zig+zls, go, rust, cmake+ccache, podman (not docker).
- Dual-GPU hot-swap rig: NVIDIA/Intel/AMD stacks all present — never assume which.
- Wrong assumptions cost more than one clarifying `ls` or `grep` first.

## Code
- Match surrounding style; minimal diffs; no drive-by reformatting.
- Files are SSH-signed by git itself — do not run git config/user tricks.
- Run build/lint before claiming done; state what was verified and what wasn't.

## Safety posture
- `pi-seatbelt` handles approvals — treat blocked chains as final, don't retry silently.
- Unattended/file-touching scripts go to a scratch dir or podman, not $HOME.
