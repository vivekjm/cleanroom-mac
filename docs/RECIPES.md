# Recipes

Common `cleanroom` workflows.

## Start Here

```sh
cleanroom overview
cleanroom map
cleanroom scan
cleanroom system-data
cleanroom plan
cleanroom large
cleanroom duplicates
cleanroom downloads
cleanroom installers
cleanroom nodes
cleanroom venvs
cleanroom apps
cleanroom appdata
cleanroom libraries
cleanroom cloud
cleanroom personal
cleanroom communications
cleanroom browsers
cleanroom leftovers adobe
cleanroom backups
cleanroom xcode
cleanroom startup
cleanroom trash
cleanroom caches
cleanroom diagnostics
cleanroom packages
cleanroom homebrew
cleanroom toolchains
cleanroom containers
cleanroom snapshots
cleanroom doctor
cleanroom protect
cleanroom guard ~/Library/Application\ Support/Google/Chrome
cleanroom categories
cleanroom rules
cleanroom init-config
cleanroom clean
```

`cleanroom clean` is a dry-run. Add `--apply` only after reviewing the preview.

## Automation / Reporting

```sh
cleanroom overview --json
cleanroom map --json
cleanroom review --json
cleanroom scan --json
cleanroom system-data --json
cleanroom plan --json
cleanroom large --json ~/Documents
cleanroom duplicates --json ~/Documents
cleanroom documents --json ~/Documents
cleanroom desktop --json
cleanroom screenshots --json ~/Desktop
cleanroom archives --json ~/Downloads
cleanroom downloads --json
cleanroom installers --json
cleanroom nodes --json ~/Documents
cleanroom venvs --json ~/Documents
cleanroom apps --json
cleanroom appdata --json
cleanroom libraries --json
cleanroom cloud --json
cleanroom personal --json
cleanroom communications --json
cleanroom browsers --json
cleanroom leftovers adobe --json
cleanroom backups --json
cleanroom xcode --json
cleanroom android --json
cleanroom startup --json
cleanroom trash --json
cleanroom caches --json
cleanroom diagnostics --json
cleanroom packages --json
cleanroom homebrew --json
cleanroom toolchains --json
cleanroom containers --json
cleanroom snapshots --json
cleanroom doctor --json
cleanroom protect --json
cleanroom guard --json ~/Library/Application\ Support/Google/Chrome
cleanroom rules --json
cleanroom report --output cleanroom-report.md
```

`overview --json` emits a compact dashboard with disk state, summary counts, and top cleanup recommendations.

`map --json` emits a read-only focused storage bucket map with paths, safety category, size, next command, and description. Buckets can overlap when a smaller folder is also part of a larger parent.

`review --json` emits a read-only checklist of personal storage hotspots with estimates, counts, descriptions, and next commands.

`scan --json` emits disk and candidate sizes as JSON for wrappers, dashboards, or future GUI frontends.

`system-data --json` emits grouped System Data buckets with sizes, safety categories, and next-step commands.

`plan --json` emits ranked cleanup recommendations with estimated reclaim size, preview commands, and explicit apply commands.

`large --json [PATH]` emits large files above `--min-mb` for review. It is intentionally review-only and does not delete anything.

`duplicates --json [PATH]` emits exact duplicate groups with SHA-256 hashes, paths, and estimated possible reclaim. It is intentionally review-only and does not delete anything.

`documents --json [PATH]` emits top-level file/folder sizes with kind, guard status, and follow-up commands. It is intentionally review-only and helps explain a large Documents storage category before deleting anything.

`desktop --json` emits the same guarded top-level inventory for `~/Desktop`. It is intentionally review-only and useful for screenshot/export/project clutter.

`screenshots --json [PATH]` emits screenshot and screen recording files with age, modified date, size, and Finder reveal command. It is intentionally review-only because screenshots can contain sensitive data.

`archives --json [PATH]` emits archive and disk image files with type, age, modified date, size, and Finder reveal command. It is intentionally review-only because archives can be backups, deliverables, or installer sources.

`downloads --json` emits old files in `~/Downloads` with age, modified date, path, and size. It is intentionally review-only and does not delete anything.

`installers --json` emits old downloaded installer files in `~/Downloads` with age, modified date, path, size, and matching preview/apply commands.

`nodes --json [PATH]` emits stale `node_modules` folders with age, size, and the matching preview/apply commands.

`venvs --json [PATH]` emits stale Python virtualenv folders with age, size, `pyvenv.cfg` marker path, and the matching preview/apply commands.

`apps --json [PATH]` emits app bundle sizes for `/Applications`, `~/Applications`, or a provided path. It is intentionally review-only and does not uninstall anything.

`appdata --json` emits large top-level app support/container folders with size and guard status. It is intentionally review-only and does not remove app state.

`libraries --json` emits protected Photos, Music, TV, iMovie, GarageBand, Logic, and related creative library sizes. It is intentionally review-only and does not delete personal media or projects.

`cloud --json` emits protected iCloud Drive, File Provider CloudStorage, Dropbox, Google Drive, OneDrive, Box, and Sync sizes. It is intentionally review-only and does not delete synced data.

`personal --json` emits protected Mail, Messages, Contacts, Calendars, Notes, Reminders, Voice Memos, and call history sizes. It is intentionally review-only and does not delete account or app data.

`communications --json` emits protected Mail, Mail Downloads, Messages, and Messages Attachments sizes. It is intentionally review-only and does not delete account, chat, or attachment data.

`browsers --json` emits browser profile size, cache size, protected status, and matching preview/apply commands. It is intentionally review-only and does not delete profiles, passwords, cookies, bookmarks, or sessions.

`leftovers --json QUERY...` emits matching app support, cache, preference, container, WebKit, log, and launch-item paths with guard status plus matching preview/apply commands. Normal text mode previews by default; `--apply --trash` moves matches into a recoverable cleanroom Trash folder and writes an apply log.

`backups --json` emits local iPhone and iPad backup sizes and device metadata when available. It is intentionally review-only and protected.

`xcode --json` emits Xcode storage buckets such as DerivedData, simulator caches, DeviceSupport, simulator devices, and Xcode Archives with safety labels and matching cleanup guidance.

`android --json` emits Android SDK, NDK, system image, emulator, AVD, platform, build-tool, command-line tool, and Android Studio cache buckets with safety labels and matching cleanup guidance.

`startup --json` emits LaunchAgents and LaunchDaemons with scope, type, status, label, program, and path. It is intentionally review-only and does not unload, disable, or remove anything.

`trash --json` emits current `~/.Trash` size and top-level items. Emptying Trash requires `cleanroom clean --include-user-trash --apply`.

`caches --json` emits safe and opt-in cache bucket sizes with the matching preview and apply commands.

`diagnostics --json` emits user log, diagnostic report, and CrashReporter sizes with matching preview/apply commands.

`packages --json` emits package-manager store sizes and matching preview/apply commands.

`homebrew --json` emits Homebrew cache, log, Cellar, Caskroom, and service/runtime bucket sizes plus installed formula/cask counts when `brew` is available.

`toolchains --json` emits rebuildable language/toolchain cache sizes with matching preview/apply commands.

`containers --json` emits local container VM disk and image-store sizes with high-impact cleanup guidance.

`snapshots --json` emits local Time Machine snapshot identifiers when macOS reports any. It is intentionally review-only and does not thin snapshots.

`doctor --json` emits platform, config, disk, dependency, and safety-catalog diagnostics for wrappers and support reports.

`protect --json` emits protected personal-state paths and whether they are present. This is useful for GUI wrappers and safety reviews before trying new cleanup rules.

`guard --json PATH...` emits the central safety decision for paths you pass in: allowed, excluded, refused as dangerous, or refused as protected.

`rules --json` emits cleanup rule metadata, including safety level, default status, opt-in flag, paths, and description.

`report` writes a Markdown summary with disk state, cleanup candidates, largest known cleanup locations, large-file hints from Spotlight, protected personal-data paths, and safety notes. It is useful before asking for help because people can inspect what is taking space without deleting anything.

## Developer Laptop

```sh
cleanroom clean --preset dev
cleanroom clean --preset dev --apply
cleanroom clean --preset dev --apply --trash
```

Good for package stores, stale `node_modules`, stale Python virtualenvs, and safe app caches.

Inspect stale `node_modules` first:

```sh
cleanroom nodes
cleanroom nodes ~/Documents --days 45 --limit 30
```

Inspect stale Python virtualenvs first:

```sh
cleanroom venvs
cleanroom venvs ~/Documents --days 45 --limit 30
cleanroom clean --include-venv-stale --days 45
cleanroom clean --apply --trash --include-venv-stale --days 45
```

Inspect cache buckets first:

```sh
cleanroom caches
```

Inspect diagnostics first:

```sh
cleanroom diagnostics
cleanroom clean --include-diagnostics --days 30
cleanroom clean --apply --trash --include-diagnostics --days 30
```

Inspect package stores first:

```sh
cleanroom packages
cleanroom homebrew
cleanroom clean --include-package-stores
```

Inspect language/toolchain caches first:

```sh
cleanroom toolchains
cleanroom clean --include-toolchains
cleanroom clean --apply --trash --include-toolchains
```

Inspect Xcode storage first:

```sh
cleanroom xcode
cleanroom xcode --json
```

Inspect Android SDK and emulator storage first:

```sh
cleanroom android
cleanroom android --json
```

## Documents Storage

```sh
cleanroom large ~/Documents --min-mb 250 --limit 50
cleanroom large ~/Downloads --min-mb 100 --limit 50
cleanroom duplicates ~/Documents --min-mb 100 --limit 20
cleanroom documents ~/Documents --limit 40
cleanroom desktop --limit 40
cleanroom screenshots ~/Desktop --days 7 --limit 50
cleanroom archives ~/Downloads --days 7 --limit 50
cleanroom downloads --days 30 --limit 50
cleanroom installers --days 30 --limit 50
cleanroom nodes ~/Documents --days 45 --limit 30
cleanroom venvs ~/Documents --days 45 --limit 30
cleanroom appdata --limit 30
cleanroom libraries
cleanroom cloud
cleanroom personal
```

Use this when macOS Storage reports a large Documents category. Review the output manually; cleanroom will not delete arbitrary personal files, protected media libraries, cloud-sync folders, or personal app databases.

## Old Installers

```sh
cleanroom installers
cleanroom clean --include-installers --days 30
cleanroom clean --apply --trash --include-installers --days 30
```

Use this for old `.dmg`, `.pkg`, `.mpkg`, `.xip`, `.ipsw`, and `.iso` files in `~/Downloads`. The inventory is review-only; cleanup requires the explicit `--include-installers` flag.

## Applications Storage

```sh
cleanroom apps --limit 30
cleanroom apps --json /Applications
```

Review large app bundles manually. cleanroom does not uninstall apps because app removal can require vendor uninstallers, launch agents, helper tools, login items, and account-specific data.

## App Leftovers

```sh
cleanroom leftovers adobe
cleanroom leftovers "creative cloud" --limit 50
cleanroom leftovers adobe --apply --trash
cleanroom leftovers zoom --json
```

Use this after uninstalling or removing a large app. It searches common macOS support, cache, preference, container, saved-state, WebKit, log, and launch-item locations by name. Plain `leftovers` is a preview. Applied cleanup requires `--trash`, writes the normal cleanroom apply log, and can be restored with `cleanroom restore --log PATH --apply`. Use the vendor uninstaller when one exists, especially for apps with helper services or account-specific data.

## Browser Storage

```sh
cleanroom browsers
cleanroom browsers --json
cleanroom clean --include-app-caches
cleanroom clean --apply --trash --include-app-caches
```

Use this when browser storage is large but you need profiles, passwords, bookmarks, cookies, and sessions preserved. `browsers` shows both protected profile size and cache size; the cleanup command only targets known cache folders.

## Device Backups

```sh
cleanroom backups
cleanroom backups --json
cleanroom guard ~/Library/Application\ Support/MobileSync/Backup
```

Use this when System Data is large and you suspect local iPhone or iPad backups. cleanroom treats MobileSync backups as protected personal data and does not delete them.

## Xcode Storage

```sh
cleanroom xcode
cleanroom clean
cleanroom clean --include-dev-heavy
```

Use this when Developer or System Data storage is large. DerivedData and simulator caches are rebuildable. DeviceSupport and simulator app data are opt-in. Xcode Archives are review-only because they can contain signed release archives and dSYMs.

## Slow Startup / Background Items

```sh
cleanroom startup
cleanroom startup --json
```

Review LaunchAgents and LaunchDaemons before removing vendor tools manually. cleanroom does not unload, disable, or remove startup items.

## Current Trash

```sh
cleanroom trash
cleanroom clean --include-user-trash
cleanroom clean --include-user-trash --apply
```

`--include-user-trash` empties `~/.Trash` and is irreversible. It is not included in presets.

## Config File

```sh
cleanroom init-config
cleanroom clean --config ~/.config/cleanroom/config
```

Protect important project folders:

```text
exclude=~/Desktop/important-project
exclude=~/Documents/client-work
trash=true
log_file=~/Desktop/cleanroom-run.log
```

Config files are plain `key=value` data and are not executed as shell.

## Safer Apply Runs

```sh
cleanroom clean --preset dev --apply --trash
```

Trash mode moves paths deleted directly by `cleanroom` into `~/.Trash/cleanroom-*`. This is useful when trying the tool on a new machine or before recommending a cleanup to someone else.

Every applied run writes an audit log:

```sh
ls ~/.local/state/cleanroom/runs
cleanroom history
```

Use `--log PATH` when you want the run log somewhere specific.

Preview a restore:

```sh
cleanroom restore --log ~/Desktop/cleanroom-run.log
```

Apply a restore:

```sh
cleanroom restore --log ~/Desktop/cleanroom-run.log --apply
```

Restore only works for entries moved by `--trash` that still exist in the cleanroom Trash folder. Existing destination paths are skipped.

## Interactive Mode

```sh
cleanroom interactive
cleanroom interactive --apply
```

This prompts for cleanup categories, then runs the same dry-run/apply flow.

## Xcode / Android Bloat

```sh
cleanroom clean --include-dev-heavy
cleanroom clean --include-dev-heavy --apply
```

This can remove simulator app state and SDK components that may need to be downloaded again.

## AI Tools

Generated AI-agent workspaces:

```sh
cleanroom clean --include-ai-workspaces
cleanroom clean --include-ai-workspaces --apply
```

Downloaded local models:

```sh
cleanroom clean --include-ai-models
cleanroom clean --include-ai-models --apply
```

Model cleanup is intentionally separate because model files are often large but intentionally installed.

## Containers

```sh
cleanroom containers
cleanroom containers --json
cleanroom clean --include-containers
cleanroom clean --include-containers --apply
```

This can remove local container VM disks, images, and volumes. Review `cleanroom containers` first.

## “System Data” Looks Wrong

```sh
cleanroom system-data
cleanroom scan
cleanroom snapshots
```

Then try:

```sh
cleanroom clean --include-snapshots
cleanroom clean --include-snapshots --apply
```

macOS Storage can lag after large deletes. Restarting often helps it recalculate.
