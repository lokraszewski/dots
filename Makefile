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

help:
	@printf '%s\n' \
		'Targets:' \
		'  make run                 Run the full site playbook' \
		'  make local LIMIT=host      Run against a host over local connection' \
		'  make check                Dry-run the full playbook' \
		'  make diff                 Dry-run with diffs' \
		'  make syntax               Run ansible syntax check' \
		'  make list-hosts           Show targeted hosts' \
		'  make list-tasks           Show playbook task list' \
		'  make base                 Baseline packages and system settings' \
		'  make update               Baseline package updates only' \
		'  make fonts                Install terminal fonts' \
		'  make git                  Configure per-host git identity' \
		'  make cli                  Shared shell, tmux, neovim, and CLI helpers' \
		'  make dev-go               Go development tools' \
		'  make apps                 Personal and work GUI applications' \
		'  make personal-apps        Personal GUI applications' \
		'  make work-apps            Work GUI applications' \
		'  make personal             Run personal-machine slice' \
		'  make work                 Run work-machine slice' \
		'  make vm                   Run temporary VM slice'

run:
	$(ANSIBLE)

check:
	$(MAKE) run CHECK=1

diff:
	$(MAKE) run CHECK=1 DIFF=1

local:
	ansible-playbook $(ANSIBLE_ARGS) --connection local --ask-become-pass $(PLAYBOOK)

syntax:
	ansible-playbook -i $(INVENTORY) --syntax-check $(PLAYBOOK)

list-hosts:
	ansible-playbook -i $(INVENTORY) $(LIMIT_FLAG) --list-hosts $(PLAYBOOK)

list-tasks:
	ansible-playbook -i $(INVENTORY) $(LIMIT_FLAG) $(TAGS_FLAG) --list-tasks $(PLAYBOOK)

base:
	$(MAKE) run TAGS=base

update:
	$(MAKE) run TAGS=update

fonts:
	$(MAKE) run TAGS=fonts

git:
	$(MAKE) run TAGS=git

cli:
	$(MAKE) run TAGS=cli

dev-go:
	$(MAKE) run TAGS=dev-go

apps:
	$(MAKE) run TAGS=apps

personal-apps:
	$(MAKE) run TAGS=personal-apps

work-apps:
	$(MAKE) run TAGS=work-apps

personal:
	$(MAKE) run LIMIT=personal

work:
	$(MAKE) run LIMIT=work

vm:
	$(MAKE) run LIMIT=vm
