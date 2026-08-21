# zsh

Deploys the zsh configuration, adapted from
[radleylewis/zsh](https://github.com/radleylewis/zsh).

Installing zsh and making it the login shell is the [`shell`](../shell) role's
job. This role only configures it.

## XDG layout

Everything lives under `~/.config`. A global zshenv (`/etc/zsh/zshenv` on Arch,
`/etc/zshenv` on macOS) exports `XDG_CONFIG_HOME` and points `ZDOTDIR` at
`~/.config/zsh`, so zsh reads its startup files from there instead of `$HOME`:

| Path | Contents |
| --- | --- |
| `~/.config/zsh/` | `ZDOTDIR` — all config files |
| `~/.config/zsh/plugins/` | plugins, cloned on first shell launch |
| `~/.local/state/zsh/history` | history file |
| `~/.cache/zsh/zcompdump` | completion cache |

The global zshenv is written with `blockinfile` behind a marker, so an existing
file is appended to rather than replaced.

## Files

| File | Purpose |
| --- | --- |
| `.zshenv` | XDG paths, `EDITOR`, `MANPAGER`, `GPG_TTY`, `PATH` |
| `.zshrc` | history, completion, fzf sourcing, loads the modules below |
| `aliases.zsh` | eza/bat/ripgrep aliases, git log helpers |
| `bindings.zsh` | keybindings, registered via `zvm_after_init` |
| `fzf.zsh` | fzf defaults and the Ctrl+F picker |
| `plugins.zsh` | minimal plugin loader and `zplugin-update` |
| `prompt.zsh` | starship init |
| `starship.toml` | prompt theme (needs a Nerd Font) |

`local.zsh` is sourced if present but never deployed — use it for
machine-local overrides you do not want in this repo.

## Plugins

Cloned into `$ZDOTDIR/plugins` on first launch, no plugin manager involved:
`zsh-autosuggestions`, `zsh-history-substring-search`, `zsh-vi-mode`,
`fast-syntax-highlighting`. Update them all with `zplugin-update`.

## Dependencies

This role installs `starship`, `zoxide`, `fzf` and `eza` because its config
sources them directly. `bat`, `fd`, `neovim` and `ripgrep` come from the
[`cli`](../cli) role, and the Nerd Font from [`font`](../font).
