PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1
ZSH_COMPLETION_DIR ?= $(PREFIX)/share/zsh/site-functions
DATADIR ?= $(PREFIX)/share/cleanroom

.PHONY: install uninstall test lint smoke package dist clean-dist check-version homebrew-formula macos-app

install:
	install -d "$(BINDIR)"
	install -m 0755 bin/cleanroom "$(BINDIR)/cleanroom"
	install -d "$(MANDIR)"
	install -m 0644 man/cleanroom.1 "$(MANDIR)/cleanroom.1"
	install -d "$(ZSH_COMPLETION_DIR)"
	install -m 0644 completions/_cleanroom "$(ZSH_COMPLETION_DIR)/_cleanroom"
	install -d "$(DATADIR)/data"
	install -m 0644 data/cleanup-rules.tsv "$(DATADIR)/data/cleanup-rules.tsv"
	install -m 0644 data/protected-paths.tsv "$(DATADIR)/data/protected-paths.tsv"

uninstall:
	rm -f "$(BINDIR)/cleanroom"
	rm -f "$(MANDIR)/cleanroom.1"
	rm -f "$(ZSH_COMPLETION_DIR)/_cleanroom"
	rm -f "$(DATADIR)/data/cleanup-rules.tsv"
	rm -f "$(DATADIR)/data/protected-paths.tsv"
	rmdir "$(DATADIR)/data" "$(DATADIR)" 2>/dev/null || true

lint:
	bash -n bin/cleanroom
	bash -n install.sh
	bash -n uninstall.sh
	bash -n test/smoke.sh
	bash -n scripts/check-version.sh
	bash -n scripts/check-rules.sh
	bash -n scripts/package.sh
	bash -n scripts/render-homebrew-formula.sh
	bash -n scripts/build-macos-app.sh
	./scripts/check-version.sh
	./scripts/check-rules.sh
	swiftc test/AppSanitizerTests.swift macos/CleanroomApp/CleanroomViews.swift macos/CleanroomApp/DesignSystem.swift -o /tmp/cleanroom-app-sanitizer-tests
	/tmp/cleanroom-app-sanitizer-tests

smoke test: lint
	./test/smoke.sh

package dist: test
	./scripts/package.sh

homebrew-formula: package
	./scripts/render-homebrew-formula.sh

macos-app: test
	./scripts/build-macos-app.sh

clean-dist:
	rm -rf dist

check-version:
	./scripts/check-version.sh
