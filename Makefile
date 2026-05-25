PLAYBOOK ?= site.yml
INVENTORY ?= inventory/hosts.yml
export ANSIBLE_LOCAL_TEMP ?= /tmp/ansible-local
LIMIT ?=
TAGS ?=
SKIP_TAGS ?=
V ?=
CHECK ?=
DIFF ?=
EXTRA_VARS ?=
HOST ?=

LIMIT_FLAG = $(if $(LIMIT),--limit $(LIMIT),)
TAGS_FLAG = $(if $(TAGS),--tags $(TAGS),)
SKIP_TAGS_FLAG = $(if $(SKIP_TAGS),--skip-tags $(SKIP_TAGS),)
VERBOSE_FLAG = $(if $(V),-$(V),)
CHECK_FLAG = $(if $(CHECK),--check,)
DIFF_FLAG = $(if $(DIFF),--diff,)
EXTRA_VARS_FLAG = $(if $(EXTRA_VARS),--extra-vars "$(EXTRA_VARS)",)

ANSIBLE_ARGS = -i $(INVENTORY) \
	$(LIMIT_FLAG) \
	$(TAGS_FLAG) \
	$(SKIP_TAGS_FLAG) \
	$(CHECK_FLAG) \
	$(DIFF_FLAG) \
	$(EXTRA_VARS_FLAG) \
	$(VERBOSE_FLAG)

ANSIBLE = ansible-playbook $(ANSIBLE_ARGS) $(PLAYBOOK)

.PHONY: help run check diff local syntax list-hosts list-tasks base update fonts git cli dev-go apps personal-apps work-apps personal work vm

## Show this help
help:
	@awk '/^## /{desc=substr($$0,4); next} /^[a-zA-Z_-]+:/{if (desc!="") {printf "  %-20s %s\n", $$1, desc}; desc=""}' $(MAKEFILE_LIST)

## Run the full site playbook
run:
	$(ANSIBLE)

## Dry-run the full playbook
check:
	$(MAKE) run CHECK=1

## Dry-run with diffs
diff:
	$(MAKE) run CHECK=1 DIFF=1

## Run against a host over local connection (LIMIT=host)
local:
	ansible-playbook $(ANSIBLE_ARGS) --connection local --ask-become-pass $(PLAYBOOK)

## Run ansible syntax check
syntax:
	ansible-playbook -i $(INVENTORY) --syntax-check $(PLAYBOOK)

## Show targeted hosts
list-hosts:
	ansible-playbook -i $(INVENTORY) $(LIMIT_FLAG) --list-hosts $(PLAYBOOK)

## Show playbook task list
list-tasks:
	ansible-playbook -i $(INVENTORY) $(LIMIT_FLAG) $(TAGS_FLAG) --list-tasks $(PLAYBOOK)

## Baseline packages and system settings
base:
	$(MAKE) run TAGS=base

## Baseline package updates only
update:
	$(MAKE) run TAGS=update

## Install terminal fonts
fonts:
	$(MAKE) run TAGS=fonts

## Configure per-host git identity and signing
git:
	$(MAKE) run TAGS=git

## Shared shell, tmux, and CLI helpers
cli:
	$(MAKE) run TAGS=cli

## Go development tools
dev-go:
	$(MAKE) run TAGS=dev-go

## Personal and work GUI applications
apps:
	$(MAKE) run TAGS=apps

## Personal GUI applications
personal-apps:
	$(MAKE) run TAGS=personal-apps

## Work GUI applications
work-apps:
	$(MAKE) run TAGS=work-apps

## Run personal-machine slice
personal:
	$(MAKE) run LIMIT=personal

## Run work-machine slice
work:
	$(MAKE) run LIMIT=work

## Run temporary VM slice
vm:
	$(MAKE) run LIMIT=vm
