# shell

Installs zsh and makes it the login shell.

This role owns *which* shell the system uses: it installs zsh, registers it in
`/etc/shells`, and sets it as the default shell for the connecting user. The
zsh configuration itself lives in the [`zsh`](../zsh) role.
