# =========================================================
# Listing
# =========================================================

alias ls='eza --icons'
alias l='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias tree='eza --tree --icons'

# Reuse ls completions for eza
compdef eza=ls

alias cat='bat'

# =========================================================
# Core utilities
# =========================================================

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

# =========================================================
# Navigation
# =========================================================

# -- prevents - being parsed as a flag; cd - jumps to the previous directory
alias -- -='cd -'

# =========================================================
# Editor
# =========================================================

alias vim='nvim'

# =========================================================
# Git
# =========================================================

# -F quits if output fits one screen, -X leaves the screen contents on exit
alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'
