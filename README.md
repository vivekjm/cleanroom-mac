# cleanroom

`cleanroom` is a safe-by-default macOS storage cleaner for developers and power users.

It scans the places that commonly bloat macOS storage, then cleans only rebuildable cache/artifact data unless you explicitly opt into heavier categories.

## Why

macOS Storage often labels hidden user folders as **Documents** or **System Data**. In real machines this can include:

- Xcode and simulator artifacts
- Xcode Archives and DeviceSupport
- Android SDK NDK/system images
- npm, Yarn, pnpm, Gradle, CocoaPods stores
- Homebrew caches, Cellar, Caskroom, logs, and service data
- Go, Python, SwiftPM, Maven, Composer, Ruby, uv, and Poetry toolchain caches
- iCloud Drive, CloudStorage, Dropbox, Google Drive, OneDrive, Box, and Syncthing footprint
- Mail, Messages, Contacts, Calendars, Notes, Reminders, and Voice Memos footprint
- Docker Desktop, Colima, Lima, and Podman container storage
- old `node_modules`
- stale Python virtualenv folders
- AI-agent recordings, scratch data, local memory, and generated workspaces
- local AI model downloads and backends
- Chrome/VS Code/Cursor cache folders
- browser profile and cache footprint
- large app support, container, and group-container folders
- Photos, Music, TV, iMovie, GarageBand, and Logic library footprint
- app leftovers after manual uninstalls
- old logs, crash reports, and diagnostic reports
- old downloaded installer files
- local iPhone and iPad backups

`cleanroom` makes those visible and gives you a cautious way to clean them.

## Safety Model

By default, `cleanroom` does **not** delete:

- browser profiles
- saved password databases
- Keychains
- bookmarks, cookies, or full app profile folders
- Photos libraries
- Music, TV, iMovie, GarageBand, and Logic libraries
- Mail
- Messages, Contacts, Calendars, Notes, Reminders, Voice Memos, or call history
- iCloud Drive
- cloud-sync folders such as Dropbox, Google Drive, OneDrive, Box, and Syncthing
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

Get a read-only dashboard:

```sh
cleanroom overview
cleanroom overview --json
```

Scan:

```sh
cleanroom scan
```

Break down common System Data folders:

```sh
cleanroom system-data
cleanroom system-data --json
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

Review old Downloads files:

```sh
cleanroom downloads
cleanroom downloads --days 30 --limit 50
cleanroom downloads --json
```

Review old downloaded installers:

```sh
cleanroom installers
cleanroom installers --days 30 --limit 50
cleanroom installers --json
```

Review stale `node_modules` folders:

```sh
cleanroom nodes
cleanroom nodes ~/Documents --days 45 --limit 30
cleanroom nodes --json
```

Review stale Python virtualenv folders:

```sh
cleanroom venvs
cleanroom venvs ~/Documents --days 45 --limit 30
cleanroom venvs --json
```

List large installed apps for manual review:

```sh
cleanroom apps
cleanroom apps --json /Applications
cleanroom apps ~/Applications --limit 20
```

Review large app data folders:

```sh
cleanroom appdata
cleanroom appdata --limit 30
cleanroom appdata --json
```

Review protected media and creative libraries:

```sh
cleanroom libraries
cleanroom libraries --json
```

Review protected cloud-sync storage:

```sh
cleanroom cloud
cleanroom cloud --json
```

Review protected personal app data:

```sh
cleanroom personal
cleanroom personal --json
```

Review Homebrew storage:

```sh
cleanroom homebrew
cleanroom homebrew --json
```

Review browser profile and cache footprint without touching profiles:

```sh
cleanroom browsers
cleanroom browsers --json
```

Find app leftovers by app or vendor name:

```sh
cleanroom leftovers adobe
cleanroom leftovers adobe --apply --trash
cleanroom leftovers zoom --json
```

Review local iPhone/iPad backups:

```sh
cleanroom backups
cleanroom backups --json
```

Review Xcode and simulator storage:

```sh
cleanroom xcode
cleanroom xcode --json
```

Review startup and background launch items:

```sh
cleanroom startup
cleanroom startup --json
```

Review current Trash:

```sh
cleanroom trash
cleanroom trash --json
```

Inventory safe and opt-in cache buckets:

```sh
cleanroom caches
cleanroom caches --json
```

Inventory logs and diagnostic reports:

```sh
cleanroom diagnostics
cleanroom diagnostics --json
```

Inventory package-manager caches and stores:

```sh
cleanroom packages
cleanroom packages --json
```

Inventory language/toolchain caches:

```sh
cleanroom toolchains
cleanroom toolchains --json
```

Inventory local container storage:

```sh
cleanroom containers
cleanroom containers --json
```

Review local Time Machine snapshots:

```sh
cleanroom snapshots
cleanroom snapshots --json
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
cleanroom doctor --json
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
dev   safe + app caches + package/toolchain stores + stale node_modules + stale virtualenvs
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

Remove stale Python virtualenv folders older than 45 days:

```sh
cleanroom venvs --days 45
cleanroom clean --apply --trash --include-venv-stale --days 45
```

Clean old downloaded installers:

```sh
cleanroom installers
cleanroom clean --include-installers --days 30
cleanroom clean --apply --trash --include-installers --days 30
```

Empty current user Trash:

```sh
cleanroom trash
cleanroom clean --include-user-trash
cleanroom clean --include-user-trash --apply
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
cleanroom containers
cleanroom clean --apply --include-containers
```

This can remove containers, images, and local volumes.

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

Protected personal-state paths are cataloged in [data/protected-paths.tsv](data/protected-paths.tsv). `cleanroom protect --json` exposes detected browser profile, credential, Photos, Mail, Messages, Contacts, Calendars, Notes, cloud-sync, iCloud, and related paths that cleanroom will not remove wholesale.

`cleanroom guard PATH...` uses the same central guard as applied cleanup. It refuses broad dangerous paths, protected catalog paths, and any ancestor folder that would contain protected catalog entries.

Config files use simple `key=value` lines and are never executed as shell.

`--include-dev-heavy` can remove simulator app state and Android SDK components that may need to be reinstalled later.

`--include-ai-workspaces` removes generated AI-agent state such as recordings, scratch folders, local brain/memory data, implicit data, and local conversation caches where known.

`--include-ai-models` removes downloaded local model files and backend extensions from known stores such as LM Studio, Ollama, Hugging Face cache, and similar caches. These can usually be downloaded again later, but they may be large.

`--include-containers` removes local container VM disks and image stores for known runtimes such as Docker Desktop, Colima, Lima, and Podman. This can remove local containers, images, and volumes.

`--trash` applies to paths that `cleanroom` removes directly. System commands delegated to macOS or developer tools, such as Time Machine snapshot thinning or simulator reset, may still be irreversible.

`restore` only restores entries that were moved by `--trash` and still exist in the cleanroom Trash folder. It skips destinations that already exist.

`overview` summarizes disk state, top recommendations, package-store size, toolchain-cache size, container storage size, diagnostic-report size, protected-data presence, snapshots, app bundle count, and useful next commands without deleting anything.

`system-data` breaks common macOS System Data locations into focused buckets such as Application Support, caches, Developer data, container storage, diagnostics, MobileSync backups, Group Containers, HTTPStorages, and saved app state. It is review-only and points to the safest next command for each bucket.

`caches --json` emits safe and opt-in cache bucket sizes with the matching preview and apply commands.

`diagnostics` inventories user logs, diagnostic reports, and CrashReporter data. Default cleanup already removes old log files; diagnostic report cleanup is opt-in with `cleanroom clean --include-diagnostics --days N`.

`doctor --json` emits platform, config, disk, dependency, and safety-catalog diagnostics for wrappers and support reports.

`plan` estimates cleanup opportunities and prints copyable dry-run commands plus explicit apply commands. It does not delete anything.

`large` lists large files for review and never deletes them. Use it when macOS reports high Documents storage and you need to find videos, archives, disk images, datasets, or project artifacts manually.

`duplicates` hashes files above `--min-mb`, groups exact matches, estimates possible reclaim, and never deletes anything.

`downloads` lists old files in `~/Downloads` for manual review and never deletes them.

`installers` lists old `.dmg`, `.pkg`, `.mpkg`, `.xip`, `.ipsw`, and `.iso` files in `~/Downloads`. Cleanup is opt-in with `--include-installers`.

`nodes` lists stale `node_modules` folders before you decide whether to run `cleanroom clean --include-node-stale --apply`.

`venvs` lists stale Python virtualenv folders before you decide whether to run `cleanroom clean --include-venv-stale --apply`. It only treats folders with `pyvenv.cfg` as virtualenv cleanup candidates.

`apps` lists `.app` bundle sizes from `/Applications` and `~/Applications`, or a path you provide. It never uninstalls apps.

`appdata` ranks top-level Application Support, Containers, Group Containers, HTTPStorages, WebKit, and saved-state folders. It is review-only and includes the central guard status so protected profiles and personal data stand out before you investigate with `leftovers APPNAME`.

`libraries` inventories protected media and creative libraries such as Photos, Photo Booth, Music, iTunes, TV, iMovie, GarageBand, Logic, and Audio Music Apps. It is review-only and helps explain large Documents or media storage without deleting personal projects.

`cloud` inventories protected cloud-sync folders such as iCloud Drive, File Provider CloudStorage, Dropbox, Google Drive, OneDrive, Box, and Sync. It is review-only because local deletes can affect remote cloud or peer data.

`personal` inventories protected app data such as Mail, Messages, Contacts, Calendars, Notes, Reminders, Voice Memos, and call history. It is review-only and helps explain large personal app storage without deleting account data.

`browsers` separates safe browser cache candidates from protected profile storage. It reports Chrome, Brave, Edge, Arc, Firefox, and Safari profile sizes, but cleanup commands still remove only cache folders and never profiles, passwords, cookies, bookmarks, or sessions.

`leftovers` searches common support, cache, preference, container, WebKit, log, and launch-item locations for an app or vendor name. By default it previews only. If you explicitly pass `--apply --trash`, matches move into a cleanroom Trash folder and are recorded in the apply log so `cleanroom restore --log PATH --apply` can put them back. Protected browser profiles, Keychains, device backups, Photos, Mail, iCloud Drive, and broad Library folders are still refused.

`backups` inventories local iPhone and iPad backups under MobileSync. It is review-only and protected because those backups may be the only copy of device data.

`xcode` inventories DerivedData, simulator caches, DeviceSupport, simulator devices, and Xcode Archives. It separates rebuildable caches from review-only archives and high-impact simulator data.

`startup` lists LaunchAgents and LaunchDaemons for review. It never unloads, disables, or removes startup items.

`trash` inventories current `~/.Trash` contents. `--include-user-trash` empties Trash only when explicitly requested, and it is intentionally not included in presets.

`packages` inventories npm, Yarn, pnpm, Gradle, CocoaPods, Cargo, and Homebrew stores with preview/apply commands for matching cleanup categories.

`homebrew` inventories Homebrew cache, logs, Cellar, Caskroom, and service/runtime folders. It is review-only and points to `brew cleanup -n` for Homebrew-native dry-run detail.

`toolchains` inventories rebuildable language/toolchain caches for Go, pip, uv, Poetry, SwiftPM, Maven, Composer, RubyGems, and Bundler. Cleanup is opt-in with `cleanroom clean --include-toolchains`, and `--trash` keeps removals restorable through the normal apply log.

`containers` inventories local container VM disks and image stores for Docker Desktop, Colima, Lima, and Podman. Cleanup is high-impact and opt-in with `cleanroom clean --include-containers`.

`snapshots` lists local Time Machine snapshots before you decide whether to run `cleanroom clean --include-snapshots --apply`.

The project also ships `make install`, `make uninstall`, `make lint`, `make test`, `make package`, `make homebrew-formula`, and `make macos-app` targets for maintainers and package managers.

Release packaging is documented in [docs/RELEASE.md](docs/RELEASE.md).

## License

MIT
