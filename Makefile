
# Default playbook
PLAYBOOK ?= site.yml

# Host targeting (optional)
LIMIT ?=

# Local mode (true/false)
LOCAL ?= false

# Verbosity (empty, v, vv, vvv, vvvv)
V ?=

# Build extra args dynamically
EXTRA_VARS = local=$(LOCAL)

# Host limit handling
LIMIT_FLAG = $(if $(LIMIT),--limit $(LIMIT),)

# Verbosity handling
VERBOSE = $(if $(V),-$(V),)

# Default run
run:
	ansible-playbook $(PLAYBOOK) \
		$(LIMIT_FLAG) \

		--extra-vars "$(EXTRA_VARS)" \
		$(VERBOSE)


local:
	ansible-playbook $(PLAYBOOK) \
		$(LIMIT_FLAG) \
		--connection local --ask-become-pass \
		--extra-vars "local=true" \
		$(VERBOSE)