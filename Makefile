#! /usr/bin/make
#
# Gnu Make needed to run te "pull" command
#
# Site update script, mostly needed for custom php email forwarder
# configuration after static site setup
#
# Jordan Hrycaj <jordan@teddy-net.com>
#
# $Id$
#

# ---------------------------------------------------------------------------
# Setup: change SCRIPTS and CONFIG variables maually unless Gnu Make is used
# ---------------------------------------------------------------------------

THEME   = $(shell sed -e 's/=/ = /' -e 's/["'\'']//g' $(CONFIG) |\
		awk '$$1=="theme"{print$$3;exit}')

# SCRIPTS = ./themes/<theme>/scripts or ./scripts
SCRIPTS = ./$(if $(strip $(THEME)),themes/$(THEME)/)scripts

# CONFIG = config.toml or theme.toml
CONFIG  = $(if $(strip $(wildcard config.toml)),config.toml,theme.toml)

# ---------------------------------------------------------------------------
# End setup
# ---------------------------------------------------------------------------

SETUP_PFWD = $(SHELL) $(SCRIPTS)/setup-email-form.sh
TEST_PFWD  = $(SHELL) $(SCRIPTS)/send-test-email.sh

.PHONY: help
help:
	@echo
	@echo "Usage: $(MAKE) <target>"
	@echo
	@echo "<target>: site            -- create production site"
	@echo "          server          -- run hugo server for testing"
	@echo "          test-mail       -- send email test message"
	@echo "          pull            -- update from git repositories"
	@echo "          clean           -- clean up"
	@echo "          distclean       -- full clean up"
	@echo
	@echo "          howto-site      -- mail server setup info"
	@echo "          howto-test-mail -- mail server test info"
	@echo

# ---------------------------------------------------------------------------
# Create site
# ---------------------------------------------------------------------------

.site-built:
	$(SETUP_PFWD) "$(CONFIG)"
	touch "$@"

.PHONY: site howto-site
site:
	rm -f .site-built
	hugo --config=$(CONFIG)
	$(MAKE) .site-built

howto-site:
	$(SETUP_PFWD) --help

# ---------------------------------------------------------------------------
# Reinstall site and run test server
# ---------------------------------------------------------------------------

.PHONY: server
server:
	rm -f .site-built
	hugo server --config=$(CONFIG) --watch=true

# ---------------------------------------------------------------------------
# Send a test mail
# ---------------------------------------------------------------------------

.PHONY: test-mail howto-test-mail
test-mail: .site-built
	$(TEST_PFWD) "$(CONFIG)"

howto-test-mail:
	$(TEST_PFWD) --help

# ---------------------------------------------------------------------------
# Clean up
# ---------------------------------------------------------------------------

.PHONY: clean distclean
clean distclean::
	rm -f .site-built
	rm -rf public

distclean::
	rm -f *~ */*~ */*/*~

# ---------------------------------------------------------------------------
# The pull command needs GNU make
# ---------------------------------------------------------------------------

git_rxconf  = git config -f .gitmodules --get-regexp
get_config  = $(shell $(git_rxconf) '^submodule\.$(1)$$'|cut -f2 -d\ )
get_url     = $(call get_config,$(notdir $(1))\.url)
pull_submod = cd $(shell pwd)/\$$path && git pull origin master

SUBMODULES = $(call get_config,.*\.path)
BRANCH     = $(shell git status -bs|awk '{print$$2;exit}')

$(SUBMODULES):
	cd themes && git clone $(call get_url,$(notdir $@))

.PHONY: pull
pull: $(SUBMODULES)
	git submodule foreach "$(pull_submod)"
	git pull origin $(BRANCH)

# ---------------------------------------------------------------------------
# End
# ---------------------------------------------------------------------------
