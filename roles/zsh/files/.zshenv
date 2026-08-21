# ~/.config/zsh/.zshenv
#
# Sourced for every zsh invocation, before .zshrc. ZDOTDIR and
# XDG_CONFIG_HOME are already set by the global zshenv managed by the
# `zsh` Ansible role.

# ---------- XDG base directories ----------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# ---------- Editor ----------
export EDITOR="nvim"
export VISUAL="nvim"

# ---------- Pager ----------
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
fi

# ---------- GPG ----------
# Needed for SSH-based commit signing to find the right terminal
export GPG_TTY=$(tty)

# ---------- Starship ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"

# ---------- PATH ----------
export PATH="$HOME/.local/bin:$PATH"
