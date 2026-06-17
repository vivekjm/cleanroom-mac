PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1
ZSH_COMPLETION_DIR ?= $(PREFIX)/share/zsh/site-functions

.PHONY: install uninstall test lint smoke package dist clean-dist check-version homebrew-formula

install:
	install -d "$(BINDIR)"
	install -m 0755 bin/cleanroom "$(BINDIR)/cleanroom"
	install -d "$(MANDIR)"
	install -m 0644 man/cleanroom.1 "$(MANDIR)/cleanroom.1"
	install -d "$(ZSH_COMPLETION_DIR)"
	install -m 0644 completions/_cleanroom "$(ZSH_COMPLETION_DIR)/_cleanroom"

uninstall:
	rm -f "$(BINDIR)/cleanroom"
	rm -f "$(MANDIR)/cleanroom.1"
	rm -f "$(ZSH_COMPLETION_DIR)/_cleanroom"

lint:
	bash -n bin/cleanroom
	bash -n install.sh
	bash -n uninstall.sh
	bash -n test/smoke.sh
	bash -n scripts/check-version.sh
	bash -n scripts/package.sh
	bash -n scripts/render-homebrew-formula.sh
	./scripts/check-version.sh

smoke test: lint
	./test/smoke.sh

package dist: test
	./scripts/package.sh

homebrew-formula: package
	./scripts/render-homebrew-formula.sh

clean-dist:
	rm -rf dist

check-version:
	./scripts/check-version.sh
