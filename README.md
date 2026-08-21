# dots

Personal machines, work development machines, and temporary dev VMs managed with Ansible.

## Layout

```text
.
├── ansible.cfg
├── inventory/
│   └── hosts.yml              # group structure (committed)
├── group_vars/all.yml
├── host_vars/<host>/
│   ├── main.yml               # public host settings
│   └── vault.yml              # encrypted per-host secrets
├── roles/
│   ├── base/                  # baseline packages, package updates, time sync, timezone
│   ├── font/                  # fonts (JetBrainsMono Nerd Font)
│   ├── foot/                  # foot terminal emulator config
│   ├── git/                   # per-host git identity and configs
│   ├── cli/                   # shared CLI tools: bat, fd, neovim, ripgrep, tmux
│   ├── shell/                 # installs zsh, sets it as the login shell
│   ├── zsh/                   # zsh config under ~/.config/zsh (ZDOTDIR)
│   ├── tmux/                  # tmux config, TPM, powerkit, localremote plugin
│   ├── dev/                   # cloud and IaC tools: gh, kubectl, k9s, aws, gcp, azure, terraform, tofu
│   ├── dev_go/                # Go language toolchain
│   └── apps/                  # personal and work GUI applications
├── scripts/
│   ├── bwunlock.sh
│   └── vaultpass.sh
├── requirements.yml
├── site.yml
└── Makefile
```

## Inventory Model

Host grouping lives in `inventory/hosts.yml`. Connection details for each host live in `host_vars/<host>/vault.yml` (gitignored).

| Group | Purpose |
| --- | --- |
| `all` | Every managed host. Receives `base`, `font`, `foot`, and `git`. |
| `personal` | Personal machines. Receives personal GUI apps. |
| `work` | Work machines. Receives work GUI apps. |
| `vm` | Temporary dev VMs. Gets CLI setup, but no GUI apps. |
| `desktop` | Children: `personal`, `work`. GUI-capable machines. |
| `cli` | Children: `desktop`, `vm`. Receives zsh, tmux, and CLI helpers. |
| `dev_go` | Children: `personal`, `work`. Receives the Go toolchain. |
| `dev` | Children: `personal`, `work`. Receives cloud/k8s/IaC tools. |

Current hosts:

| Host | Groups |
| --- | --- |
| `icewind` | `personal`, `desktop`, `cli`, `dev_go`, `dev` |
| `mithril` | `work`, `desktop`, `cli`, `dev_go`, `dev` |

Add temporary dev machines under `vm.hosts` — they get `base`, `font`, `git`, and `cli`, but not GUI apps. Add under `dev_go` or `dev` when the tooling is needed.

## Package Management

Each role's `tasks/main.yml` includes `tasks/install/{{ ansible_facts['distribution'] }}.yml`, so `install/Archlinux.yml` and `install/MacOSX.yml` hold the OS-specific install steps — package lists included, declared inline on the install task. The file names match the `distribution` fact verbatim, so no ternary or case conversion is needed. `base` follows the same pattern for its `update/` step.

```yaml
# roles/<role>/tasks/install/Archlinux.yml
- name: Install packages via pacman
  become: true
  community.general.pacman:
    name:
      - some-package
    state: present
```

```yaml
# roles/<role>/tasks/install/MacOSX.yml
- name: Install packages via Homebrew
  community.general.homebrew:
    name:
      - homebrew-package
    state: present
```

To add a package, edit the list in the relevant role's `install/Archlinux.yml` or `install/MacOSX.yml`. Only the `apps` role handles AUR and Flatpak; the other roles install through `pacman` or Homebrew only.

The `apps` role serves both personal and work machines from one play, with each task gated on `group_names` (`when: "'personal' in group_names"`), so a host installs only the apps for the groups it belongs to.

The `base` role installs the tooling the other roles rely on: `flatpak`, and `yay` bootstrapped from the AUR. AUR installs then go through the [`mnussbaum.ansible_yay`](https://github.com/mnussbaum/ansible-yay) collection, and Flatpak installs register the Flathub remote before installing.

### AUR sudo password

`yay` shells out to `sudo` for the pacman transaction, which needs a password that Ansible's own become channel cannot supply. Rather than writing the password to the host, `roles/apps/templates/sudopass.sh.j2` is rendered onto the target as a sudo askpass helper — it contains no secret, only a `bw get password` lookup, so the password is fetched from Bitwarden at prompt time and never written to disk.

The item name is per-host, rendered as `ansible-sudo-{{ inventory_hostname }}`. Each Arch host therefore needs its own Bitwarden item holding that host's sudo password:

| Host | Bitwarden item |
| --- | --- |
| `icewind` | `ansible-sudo-icewind` |
| `mithril` | `ansible-sudo-mithril` |

`BW_SESSION` must be exported (the AUR task asserts this up front). During the AUR task only, a `Defaults env_keep += "BW_SESSION"` drop-in and a `/etc/sudo.conf` askpass line are added; both are removed in an `always` block, along with the helper script.

## Shell

The [`shell`](roles/shell) role installs zsh, registers it in `/etc/shells`, and sets it as the login shell. The [`zsh`](roles/zsh) role deploys the configuration — adapted from [radleylewis/zsh](https://github.com/radleylewis/zsh) — with everything under `~/.config`:

| Path | Contents |
| --- | --- |
| `~/.config/zsh/` | `ZDOTDIR` — all zsh config files |
| `~/.config/zsh/plugins/` | plugins, cloned on first shell launch |
| `~/.local/state/zsh/history` | history file |
| `~/.cache/zsh/zcompdump` | completion cache |

A global zshenv (`/etc/zsh/zshenv` on Arch, `/etc/zshenv` on macOS) exports `XDG_CONFIG_HOME` and points `ZDOTDIR` at `~/.config/zsh`, so no zsh dotfiles land in `$HOME`. It is written behind a `blockinfile` marker, so an existing file is appended to rather than replaced.

Plugins install themselves on first launch; `zplugin-update` updates them. `~/.config/zsh/local.zsh` is sourced if present and is never deployed, so use it for machine-local overrides.

## Prerequisites

Install the collection dependencies before the first run:

```sh
make deps
```

Nothing else is needed on the target. The `base` role installs `flatpak` and bootstraps `yay` on Arch hosts: if `yay` is absent it clones `yay-bin`, builds it with `makepkg` as your unprivileged user, and installs the resulting package with `become: true`. That split means the bootstrap needs no askpass helper — Ansible's own become supplies the password.

## Secrets and Identity

Per-host secrets live in `host_vars/<host>/vault.yml` (vault-encrypted, committed). This includes the become password and git identity (name, email, signing key).

Connection details (`ansible_host`, `ansible_user`, `ansible_ssh_private_key_file`) live in `host_vars/<host>/private.yml` (gitignored). Copy `host_vars/<host>/private.yml.example` as a starting point.

`host_vars/<host>/vault.yml` shape:

```yaml
ansible_become_password: "sudo-password"

git_identity:
  name: "Your Name"
  email: "your@example.com"
  signing_key: "~/.ssh/id_ed25519.pub"
```

Git commits are signed with SSH. The role configures `gpg.format = ssh`, sets `commit.gpgsign` and `tag.gpgsign` to true, and writes `~/.ssh/allowed_signers` from the public key so `git log --show-signature` works locally.

The repo uses `scripts/vaultpass.sh` (via `ansible.cfg`) to unlock vault data through Bitwarden:

```sh
bw login
bw unlock
export BW_SESSION="your-session-token"
```

Useful vault commands:

```sh
ansible-vault edit host_vars/<host>/vault.yml
ansible-vault create host_vars/<host>/vault.yml
```

## Common Commands

```sh
make help
make syntax
make list-hosts
make check
make diff
make run
```

Run a specific slice:

```sh
make base
make update
make fonts
make git
make cli
make dev-go
make apps
make personal-apps
make work-apps
```

Target a machine or group:

```sh
make run LIMIT=icewind
make personal
make work
make vm
```

Pass extra Ansible controls when needed:

```sh
make run LIMIT=icewind V=vv
make run TAGS=cli LIMIT=vm
make run SKIP_TAGS=update
make run EXTRA_VARS='upgrade_system=false'
```

## Adding a Host

1. Add the host to the right groups in `inventory/hosts.yml`.
2. Create `host_vars/<host>/{main,vault}.yml` with at minimum `system_timezone`.
3. Run `make syntax`, then `make check LIMIT=<host>`, then `make run LIMIT=<host>`.
