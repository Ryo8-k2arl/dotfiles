CHEZMOI ?= chezmoi
SOURCE_DIR := $(CURDIR)

.PHONY: init diff apply update check

init:
	$(CHEZMOI) init --source "$(SOURCE_DIR)"

diff:
	$(CHEZMOI) --source "$(SOURCE_DIR)" diff

apply:
	$(CHEZMOI) --source "$(SOURCE_DIR)" apply

update:
	$(CHEZMOI) update

check:
	./scripts/check.sh
