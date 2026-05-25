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
│   ├── base/                  # baseline packages, package updates, time sync, timezone, shell
│   ├── font/                  # fonts (JetBrainsMono Nerd Font)
│   ├── foot/                  # foot terminal emulator config
│   ├── git/                   # per-host git identity and configs
│   ├── cli/                   # shared CLI tools: bat, fd, inetutils, tmux
│   ├── tmux/                  # tmux config, TPM, powerkit, localremote plugin
│   ├── dev/                   # cloud and IaC tools: gh, kubectl, k9s, aws, gcp, azure, terraform, tofu
│   ├── dev_go/                # Go language toolchain
│   ├── apps/                  # personal and work GUI applications
│   └── common/                # shared install helpers (pacman, AUR, Flatpak, Homebrew)
├── scripts/
│   ├── bwunlock.sh
│   └── vaultpass.sh
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
| `cli` | Children: `desktop`, `vm`. Receives fish, tmux, and CLI helpers. |
| `dev_go` | Children: `personal`, `work`. Receives the Go toolchain. |
| `dev` | Children: `personal`, `work`. Receives cloud/k8s/IaC tools. |

Current hosts:

| Host | Groups |
| --- | --- |
| `icewind` | `personal`, `desktop`, `cli`, `dev_go`, `dev` |
| `mithril` | `work`, `desktop`, `cli`, `dev_go`, `dev` |

Add temporary dev machines under `vm.hosts` — they get `base`, `font`, `git`, and `cli`, but not GUI apps. Add under `dev_go` or `dev` when the tooling is needed.

## Package Management

Each role declares its own package lists in `defaults/main.yml`:

```yaml
packages:
  archlinux:
    - some-package
  archlinux_aur:
    - aur-only-package
  flatpak:
    - org.example.App
  darwin:
    - homebrew-package
```

`common/tasks/install.yml` dispatches to the right installer. AUR installs use `yay` (bootstrapped automatically if absent). Flatpak installs ensure the Flathub remote is registered first.

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
