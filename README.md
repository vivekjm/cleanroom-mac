# cleanroom

`cleanroom` is a safe-by-default macOS storage cleaner for developers and power users.

It scans the places that commonly bloat macOS storage, then cleans only rebuildable cache/artifact data unless you explicitly opt into heavier categories.

## Why

macOS Storage often labels hidden user folders as **Documents** or **System Data**. In real machines this can include:

- Xcode and simulator artifacts
- Android SDK NDK/system images
- npm, Yarn, pnpm, Gradle, CocoaPods stores
- old `node_modules`
- AI-agent recordings, scratch data, local memory, and generated workspaces
- local AI model downloads and backends
- Chrome/VS Code/Cursor cache folders

`cleanroom` makes those visible and gives you a cautious way to clean them.

## Safety Model

By default, `cleanroom` does **not** delete:

- browser profiles
- saved password databases
- Keychains
- bookmarks, cookies, or full app profile folders
- Photos libraries
- Mail
- iCloud Drive
- arbitrary files in Documents/Desktop/Downloads

The default `clean` action is also a dry-run. You must pass `--apply` to delete.

For safer applied runs, pass `--trash` to move cleanroom-managed path removals into `~/.Trash/cleanroom-*` instead of deleting them immediately. Applied runs also write an audit log under `~/.local/state/cleanroom/runs/` by default.

Trash-mode runs can be inspected with `cleanroom history` and restored with `cleanroom restore --log PATH`.

## Install

From this repo:

```sh
./install.sh
```

This installs the `cleanroom` command, a `cleanroom(1)` man page, and zsh completions under `/usr/local` by default. Override `PREFIX` if you want a different location:

```sh
PREFIX="$HOME/.local" ./install.sh
```

Or run directly:

```sh
./bin/cleanroom scan
```

From a release archive:

```sh
tar -xzf cleanroom-*.tar.gz
cd cleanroom-*
./install.sh
```

Homebrew formula metadata is generated for releases. After a GitHub release exists:

```sh
make homebrew-formula
brew install ./dist/Formula/cleanroom.rb
```

Uninstall:

```sh
./uninstall.sh
```

## Development

Run the smoke tests:

```sh
make test
```

Build a release archive:

```sh
make package
```

Build release archive plus Homebrew formula:

```sh
make homebrew-formula
```

Build the lightweight macOS app wrapper:

```sh
make macos-app
open dist/Cleanroom.app
```

The app wrapper is ad-hoc signed for local builds. It is not Developer ID notarized unless a maintainer signs and notarizes a release build.

## Usage

Scan:

```sh
cleanroom scan
```

Get ranked cleanup recommendations:

```sh
cleanroom plan
cleanroom plan --json
```

Find large files for manual review:

```sh
cleanroom large
cleanroom large ~/Documents --min-mb 250 --limit 30
cleanroom large --json ~/Downloads
```

Find exact duplicate files for manual review:

```sh
cleanroom duplicates
cleanroom duplicates ~/Documents --min-mb 100 --limit 20
cleanroom duplicates --json ~/Downloads
```

Machine-readable scan:

```sh
cleanroom scan --json
```

Create a Markdown report for sharing, audits, or GitHub issues:

```sh
cleanroom report --output cleanroom-report.md
```

Check environment and safety assumptions:

```sh
cleanroom doctor
```

Audit protected personal data and app profile paths:

```sh
cleanroom protect
cleanroom protect --json
```

Check whether a specific path is blocked by cleanroom's safety guard:

```sh
cleanroom guard ~/Library/Application\ Support/Google/Chrome
cleanroom guard --json ~/Library/Application\ Support/Google/Chrome/Default/Login\ Data
```

See cleanup categories:

```sh
cleanroom categories
```

Inspect the cleanup rule catalog:

```sh
cleanroom rules
cleanroom rules --json
```

Create a config file:

```sh
cleanroom init-config
```

Use a guided prompt:

```sh
cleanroom interactive
```

Preview safe cleanup:

```sh
cleanroom clean
```

Apply safe cleanup:

```sh
cleanroom clean --apply
```

Apply cleanup by moving cleanroom-managed removals to Trash:

```sh
cleanroom clean --apply --trash --preset dev
```

Use presets:

```sh
cleanroom clean --preset safe
cleanroom clean --preset dev
cleanroom clean --preset deep
```

Preset meanings:

```text
safe  default rebuildable caches
dev   safe + app caches + package stores + stale node_modules
deep  dev + heavy SDKs + snapshots + AI workspace data
```

Clean safe app cache folders without deleting browser profiles:

```sh
cleanroom clean --apply --include-app-caches
```

Clean heavier developer artifacts:

```sh
cleanroom clean --apply --include-dev-heavy
```

Remove stale `node_modules` older than 45 days:

```sh
cleanroom clean --apply --include-node-stale --days 45
```

Clean rebuildable package-manager stores:

```sh
cleanroom clean --apply --include-package-stores
```

Clean generated AI-agent workspace data:

```sh
cleanroom clean --apply --include-ai-workspaces
```

Clean downloaded local AI models/backends:

```sh
cleanroom clean --apply --include-ai-models
```

Clean local container VM disks:

```sh
cleanroom clean --apply --include-containers
```

This can remove containers and local volumes.

Backward-compatible aliases:

```sh
cleanroom clean --apply --include-gemini
cleanroom clean --apply --include-lmstudio
```

Combine categories:

```sh
cleanroom clean --apply --include-app-caches --include-dev-heavy --include-node-stale --days 30
```

Use a config file and protect custom paths:

```sh
cleanroom clean --config ~/.config/cleanroom/config --exclude ~/Desktop/important-project
```

Write an apply log to a specific path:

```sh
cleanroom clean --apply --trash --log ~/Desktop/cleanroom-run.log
```

List recent cleanup runs:

```sh
cleanroom history
```

Preview or apply restore from a Trash-mode run:

```sh
cleanroom restore --log ~/Desktop/cleanroom-run.log
cleanroom restore --log ~/Desktop/cleanroom-run.log --apply
```

## Notes

More examples are in [docs/RECIPES.md](docs/RECIPES.md).

Cleanup rules are cataloged in [data/cleanup-rules.tsv](data/cleanup-rules.tsv). `cleanroom rules --json` exposes the same catalog for wrappers and audits.

Protected personal-state paths are cataloged in [data/protected-paths.tsv](data/protected-paths.tsv). `cleanroom protect --json` exposes detected browser profile, credential, Photos, Mail, iCloud, Messages, and Contacts paths that cleanroom will not remove wholesale.

`cleanroom guard PATH...` uses the same central guard as applied cleanup. It refuses broad dangerous paths, protected catalog paths, and any ancestor folder that would contain protected catalog entries.

Config files use simple `key=value` lines and are never executed as shell.

`--include-dev-heavy` can remove simulator app state and Android SDK components that may need to be reinstalled later.

`--include-ai-workspaces` removes generated AI-agent state such as recordings, scratch folders, local brain/memory data, implicit data, and local conversation caches where known.

`--include-ai-models` removes downloaded local model files and backend extensions from known stores such as LM Studio, Ollama, Hugging Face cache, and similar caches. These can usually be downloaded again later, but they may be large.

`--include-containers` removes local container VM disks for known runtimes such as Colima/Lima and Docker Desktop. This can remove local containers and volumes.

`--trash` applies to paths that `cleanroom` removes directly. System commands delegated to macOS or developer tools, such as Time Machine snapshot thinning or simulator reset, may still be irreversible.

`restore` only restores entries that were moved by `--trash` and still exist in the cleanroom Trash folder. It skips destinations that already exist.

`plan` estimates cleanup opportunities and prints copyable dry-run commands plus explicit apply commands. It does not delete anything.

`large` lists large files for review and never deletes them. Use it when macOS reports high Documents storage and you need to find videos, archives, disk images, datasets, or project artifacts manually.

`duplicates` hashes files above `--min-mb`, groups exact matches, estimates possible reclaim, and never deletes anything.

The project also ships `make install`, `make uninstall`, `make lint`, `make test`, `make package`, `make homebrew-formula`, and `make macos-app` targets for maintainers and package managers.

Release packaging is documented in [docs/RELEASE.md](docs/RELEASE.md).

## License

MIT
