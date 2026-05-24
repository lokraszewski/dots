# dots

Personal machines, work development machines, and temporary dev VMs managed with Ansible.

This repo is organized around intent rather than operating system. The inventory decides which hosts receive each slice of configuration, and each role owns one narrow area: baseline system state, git identity, shared CLI setup, development tools, or GUI apps.

## Layout

```text
.
├── ansible.cfg
├── inventory/hosts.yml
├── group_vars/all.yml
├── secrets/secrets.yml    # encrypted secrets and per-host identities
├── roles/
│   ├── base/              # baseline packages, package updates, shell default
│   ├── font/              # terminal fonts
│   ├── git/               # per-host git identity
│   ├── cli/               # shared shell, tmux, neovim, CLI helpers
│   ├── dev/               # general developer tools and IDE-related packages
│   ├── dev_go/            # Go language toolchain
│   ├── apps/              # personal and work GUI applications
│   └── common/            # shared role helpers
├── scripts/
│   ├── bwunlock.sh
│   └── vaultpass.sh
├── site.yml
└── Makefile
```

## Inventory Model

Host grouping lives in `inventory/hosts.yml`.

| Group | Purpose |
| --- | --- |
| `all` | Every managed host. Receives `base`, `font`, and `git`. |
| `personal` | Personal machines. Receives personal GUI apps. |
| `work` | Work machines. Receives work GUI apps and keeps work-specific targeting separate from personal config. |
| `vm` | Temporary dev VMs. Gets CLI and general dev setup, but no GUI apps by default. |
| `cli` | Hosts that should share fish/tmux/neovim and CLI helper behavior. |
| `dev` | Machines that should receive developer tools and IDE support. |
| `desktop` | Personal and work desktop/laptop machines. Useful for future GUI-wide targeting. |
| `dev_go` | Hosts that should receive Go-specific development tools. |

The current hosts are:

| Host | Groups |
| --- | --- |
| `icewind` | `personal`, `desktop`, `dev`, `cli`, `dev_go` |
| `mithril` | `work`, `desktop`, `dev`, `cli`, `dev_go` |

Add temporary dev machines under `vm.hosts`. They will get `base`, `git`, `cli`, and `dev`, but not GUI apps. Add a VM under `dev_go` too when it needs the Go toolchain.

## Roles

`base` configures baseline system state: core packages, package updates, time sync, timezone, and the default shell. Keep this role boring and universal.

`font` installs terminal fonts. It currently installs JetBrains Mono Nerd Font, writes `.terminal-font` as a small reminder for terminal profile setup, and configures VS Code to use the font.

`git` configures `user.name` and `user.email` from the encrypted `git_identities` map in `secrets/secrets.yml`.

`cli` is for the shared terminal environment you want everywhere: fish, tmux, neovim, prompt tools, and small CLI helpers.

`dev` is for developer workstations: compilers, language tooling, containers, SDKs, editors, IDE support, and other tools you do not necessarily want on a remote shell.

`dev_go` is for Go-specific development. Use the same pattern for other languages, such as `dev_rust`, `dev_python`, or `dev_node`, when they deserve their own package list or setup tasks.

`apps` installs GUI applications. The `personal` play passes `personal_apps`; the `work` play passes `work_apps`. Keep the lists separate in `roles/apps/defaults/main.yml` or override them from group vars if a package list needs to stay private.

`common` holds shared helper tasks. Right now it resolves package names through `package_name_map`, so roles can use friendly package names while OS-specific mappings stay centralized.

## Secrets And Identity

Shared secrets and host-specific git identities live in `secrets/secrets.yml` and should stay encrypted with Ansible Vault.

Git identities should use this shape:

```yaml
git_identities:
  icewind:
    name: "Personal Name"
    email: "personal@example.com"
    signing_key: ""
  mithril:
    name: "Work Name"
    email: "work@example.com"
    signing_key: ""
```

The repo is configured to use `scripts/vaultpass.sh` through `ansible.cfg`, so normal Ansible and Make targets can unlock vault data through your Bitwarden-backed workflow.

First-time Bitwarden setup:

```sh
bw login
bw unlock
export BW_SESSION="your-session-token"
```

Useful vault commands:

```sh
make vault-edit
make vault-view
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
make dev
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

Run against the current machine over a local connection:

```sh
make local LIMIT=icewind
```

Pass extra Ansible controls when needed:

```sh
make run LIMIT=icewind V=vv
make run TAGS=cli LIMIT=vm
make run SKIP_TAGS=update
make run EXTRA_VARS='upgrade_system=false'
```

## Adding A Host

1. Add the host to `inventory/hosts.yml` under the right groups.
2. Add the host's git identity to `git_identities` in `secrets/secrets.yml`.
3. Run `make syntax`, then `make check LIMIT=<host>`, then `make run LIMIT=<host>`.

## Package Names

Role defaults declare package intent in `packages`. If a package has different names across platforms, add the translation to `package_name_map` in `group_vars/all.yml`.

Example:

```yaml
package_name_map:
  darwin:
    fd: fd
  archlinux:
    fd: fd
```
