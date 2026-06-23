# Recipes

Common `cleanroom` workflows.

## Start Here

```sh
cleanroom dashboard
cleanroom overview
cleanroom map
cleanroom snapshot
cleanroom diff
cleanroom state
cleanroom permissions
cleanroom scan
cleanroom system-data
cleanroom plan
cleanroom large
cleanroom brokenlinks
cleanroom quarantine
cleanroom metadata
cleanroom quicklook
cleanroom quicklook-fast
cleanroom fontcaches
cleanroom fontcaches-fast
cleanroom webcaches
cleanroom webcaches-fast
cleanroom savedstate
cleanroom savedstate-fast
cleanroom projectcaches
cleanroom updaters
cleanroom updaters-fast
cleanroom browsercaches
cleanroom duplicates
cleanroom downloads
cleanroom installers
cleanroom nodes
cleanroom venvs
cleanroom apps
cleanroom uninstallers
cleanroom appreview adobe
cleanroom appdata
cleanroom libraries
cleanroom cloud
cleanroom cloudfiles
cleanroom personal
cleanroom communications
cleanroom browsers
cleanroom leftovers adobe
cleanroom backups
cleanroom xcode
cleanroom startup
cleanroom loginitems
cleanroom trash
cleanroom caches
cleanroom diagnostics
cleanroom packages
cleanroom pip-cache
cleanroom receipts
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
cleanroom clean --preset dev --preflight
```

`cleanroom clean` is a dry-run. Add `--apply` only after reviewing the preview.

## Automation / Reporting

```sh
cleanroom dashboard --json
cleanroom overview --json
cleanroom map --json
cleanroom snapshot --json
cleanroom diff before.json after.json --json
cleanroom state --json
cleanroom permissions --json
cleanroom review --json
cleanroom scan --json
cleanroom system-data --json
cleanroom plan --json
cleanroom large --json ~/Documents
cleanroom brokenlinks --json ~/Documents
cleanroom quarantine --json ~/Downloads
cleanroom metadata --json ~/Documents ~/Downloads
cleanroom quicklook --json
cleanroom quicklook-fast --json
cleanroom fontcaches --json
cleanroom fontcaches-fast --json
cleanroom webcaches --json
cleanroom webcaches-fast --json
cleanroom savedstate --json
cleanroom savedstate-fast --json
cleanroom projectcaches --json
cleanroom updaters --json
cleanroom updaters-fast --json
cleanroom browsercaches --json
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
cleanroom uninstallers --json
cleanroom appreview adobe --json
cleanroom appdata --json
cleanroom libraries --json
cleanroom cloud --json
cleanroom cloudfiles --json
cleanroom personal --json
cleanroom communications --json
cleanroom browsers --json
cleanroom leftovers adobe --json
cleanroom backups --json
cleanroom xcode --json
cleanroom android --json
cleanroom startup --json
cleanroom loginitems --json
cleanroom trash --json
cleanroom caches --json
cleanroom diagnostics --json
cleanroom packages --json
cleanroom receipts --json
cleanroom homebrew --json
cleanroom toolchains --json
cleanroom containers --json
cleanroom snapshots --json
cleanroom doctor --json
cleanroom protect --json
cleanroom guard --json ~/Library/Application\ Support/Google/Chrome
cleanroom rules --json
cleanroom report --output cleanroom-report.md
cleanroom report --redact --output cleanroom-report.md
cleanroom snapshot --output cleanroom-before.json
cleanroom diff cleanroom-before.json cleanroom-after.json
cleanroom state --json
cleanroom permissions --json
```

`dashboard --json` emits a fast app-friendly summary with disk state and safety status. It avoids deep size walks and is the preferred source for desktop refreshes.

`overview --json` emits a deeper dashboard with disk state, summary counts, and top cleanup recommendations.

`map --json` emits a read-only focused storage bucket map with paths, safety category, size, next command, and description. Buckets can overlap when a smaller folder is also part of a larger parent.

`snapshot --json` emits disk state plus the focused storage-map buckets in one timestamped JSON object. Plain `snapshot` writes the same data to `~/.local/state/cleanroom/snapshots/`; use `--output PATH` to choose the file.

`diff --json BEFORE AFTER` emits before/after storage bucket deltas from two snapshot files. Plain `diff` with no paths compares the latest two saved snapshots.

`state --json` emits Cleanroom-created run-log, snapshot, and recoverable Trash-folder counts and sizes. Use `clean --include-cleanroom-state --days N` to preview pruning old Cleanroom-created state, and add `--apply` only after confirming old recovery folders are no longer needed.

`permissions --json` emits existence/readability/listability status for common macOS privacy-sensitive storage locations. Use it when results seem incomplete or show unexpected 0B sizes.

`review --json` emits a read-only checklist of personal storage hotspots with estimates, counts, descriptions, and next commands.

`scan --json` emits disk and candidate sizes as JSON for wrappers, dashboards, or future GUI frontends.

`system-data --json` emits grouped System Data buckets with sizes, safety categories, and next-step commands.

`plan --json` emits ranked cleanup recommendations with estimated reclaim size, preview commands, and explicit apply commands.

`clean --preflight --json` emits selected cleanup categories, safety levels, recovery limits, and warnings without scanning or deleting files. Use it to build GUI confirmations or review risky opt-in flags before `--apply`.

`large --json [PATH]` emits large files above `--min-mb` for review. It is intentionally review-only and does not delete anything.

`cloudfiles --json [PATH]` emits large local files inside cloud-sync roots with provider, root, size, modified date, and Finder reveal command. It is intentionally review-only and does not delete files or evict local copies.

`brokenlinks --json [PATH]` emits dangling symlinks with link path, stored target, parent folder, modified date, and Finder reveal command. It is intentionally review-only and does not delete links.

`quarantine --json [PATH]` emits files and apps carrying macOS quarantine metadata with path, size, modified date, raw quarantine value, and Finder reveal command. It is intentionally review-only and does not delete files or clear attributes.

`metadata --json [PATH...]` emits removable filesystem metadata clutter such as `.DS_Store`, AppleDouble `._*` files, `__MACOSX`, `Thumbs.db`, and `Desktop.ini` with guard status and matching apply command. Direct apply mode requires `--trash`.

`quicklook --json` emits rebuildable Quick Look thumbnail and preview cache buckets with path, size, existence, and matching cleanup commands.

`quicklook-fast --json` emits the same known locations without deep sizing. Use it for desktop or automation refreshes where responsiveness matters more than exact byte counts.

`fontcaches --json` emits rebuildable user font cache database buckets with path, size, existence, and matching cleanup commands. Actual font files are never targeted.

`fontcaches-fast --json` emits the same known locations without deep sizing.

`webcaches --json` emits Safari and WebKit cache buckets with path, size, existence, and matching cleanup commands. Browser history, cookies, bookmarks, passwords, website data, and profiles are never targeted.

`webcaches-fast --json` emits the same known locations without deep sizing.

`savedstate --json` emits saved application window/session state with path, size, existence, and matching cleanup commands. Documents and app profiles are never targeted.

`savedstate-fast --json` emits the same known locations without deep sizing.

`projectcaches --json` emits known rebuildable project cache artifacts such as `__pycache__`, pytest, mypy, ruff, tox, nox, and coverage caches. Source, `.git`, `node_modules`, and virtualenv folders are pruned.

`duplicates --json [PATH]` emits exact duplicate groups with SHA-256 hashes, paths, and estimated possible reclaim. It is intentionally review-only and does not delete anything.

`documents --json [PATH]` emits top-level file/folder sizes with kind, guard status, and follow-up commands. It is intentionally review-only and helps explain a large Documents storage category before deleting anything.

`desktop --json` emits the same guarded top-level inventory for `~/Desktop`. It is intentionally review-only and useful for screenshot/export/project clutter.

`screenshots --json [PATH]` emits screenshot and screen recording files with age, modified date, size, Finder reveal command, and matching preview/apply commands. Cleanup is opt-in because screenshots can contain sensitive data.

`archives --json [PATH]` emits archive and disk image files with type, age, modified date, size, and Finder reveal command. It is intentionally review-only because archives can be backups, deliverables, or installer sources.

`downloads --json` emits old files in `~/Downloads` with age, modified date, path, size, artifact cleanup eligibility, and matching preview/apply commands. Cleanup remains opt-in and only targets installer, disk image, and archive-style files directly under Downloads.

`installers --json` emits old downloaded installer files in `~/Downloads` with age, modified date, path, size, and matching preview/apply commands.

`nodes --json [PATH]` emits stale `node_modules` folders with age, size, and the matching preview/apply commands.

`venvs --json [PATH]` emits stale Python virtualenv folders with age, size, `pyvenv.cfg` marker path, and the matching preview/apply commands.

`apps --json [PATH]` emits app bundle sizes for `/Applications`, `~/Applications`, or a provided path. It is intentionally review-only and does not uninstall anything.

`uninstallers --json [PATH]` emits likely vendor uninstallers, remover apps, packages, and scripts with path, size, modified date, and launch/reveal command. It is intentionally review-only and does not run or remove these tools.

`appreview --json QUERY...` emits matching app bundles, vendor uninstallers, package receipts, and leftover candidates in one read-only object. Use it before removing apps so official uninstallers and package records are visible before leftover cleanup.

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

`loginitems --json` emits user Login Items reported by macOS System Events, including hidden status, path, present flag, and size when available. It is intentionally review-only and does not disable, remove, or change Login Items.

`trash --json` emits current `~/.Trash` size and top-level items. Emptying Trash requires `cleanroom clean --include-user-trash --apply`.

`caches --json` emits safe and opt-in cache bucket sizes with the matching preview and apply commands.

`diagnostics --json` emits user log, diagnostic report, and CrashReporter sizes with matching preview/apply commands.

`packages --json` emits package-manager store sizes and matching preview/apply commands.

`npm-cache --json` emits the command, exit code, apply mode, and output from npm's native cache verifier. Use `--apply --yes` to run `npm cache clean --force`.

`yarn-cache --json` emits the command, exit code, apply mode, and output from Yarn's native cache-location command. Use `--apply --yes` to run `yarn cache clean`.

`pnpm-store --json` emits the command, exit code, apply mode, and output from pnpm's native store status check. Use `--apply --yes` to run `pnpm store prune`.

`cocoapods-cache --json` emits the command, exit code, apply mode, and output from CocoaPods' native cache list command. Use `--apply --yes` to run `pod cache clean --all`.

`pip-cache --json` emits the command, exit code, apply mode, and output from pip's native cache info command. Use `--apply --yes` to run `pip cache purge`.

`receipts --json` emits readable macOS package installer receipt files with package IDs, receipt kind, path, size, modified date, and a matching `cleanroom leftovers <package-id>` review command. Receipts are install records and are never cleanup targets.

`homebrew --json` emits Homebrew cache, log, Cellar, Caskroom, and service/runtime bucket sizes plus installed formula/cask counts when `brew` is available.

`homebrew-cleanup --json` emits the command, exit code, apply mode, and output from Homebrew's native cleanup dry-run. Use `--apply --yes` to run `brew cleanup`.

`toolchains --json` emits rebuildable language/toolchain cache sizes with matching preview/apply commands.

`containers --json` emits local container VM disk and image-store sizes with high-impact cleanup guidance.

`snapshots --json` emits local Time Machine snapshot identifiers when macOS reports any. It is intentionally review-only and does not thin snapshots.

`doctor --json` emits platform, config, disk, dependency, and safety-catalog diagnostics for wrappers and support reports.

`protect --json` emits protected personal-state paths and whether they are present. This is useful for GUI wrappers and safety reviews before trying new cleanup rules.

`guard --json PATH...` emits the central safety decision for paths you pass in: allowed, excluded, refused as dangerous, or refused as protected.

`rules --json` emits cleanup rule metadata, including safety level, default status, opt-in flag, paths, and description.

`report` writes a Markdown summary with disk state, cleanup candidates, largest known cleanup locations, large-file hints from Spotlight, protected personal-data paths, and safety notes. Use `report --redact` before sharing the file publicly; it masks home, user, and temporary paths while preserving enough structure for storage triage.

## Developer Laptop

```sh
cleanroom clean --preset dev
cleanroom clean --preset dev --preflight
cleanroom clean --preset ai
cleanroom clean --preset ai --preflight
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
cleanroom receipts
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
cleanroom clean --include-screenshots --days 30
cleanroom clean --apply --trash --include-screenshots --days 30
cleanroom archives ~/Downloads --days 7 --limit 50
cleanroom downloads --days 30 --limit 50
cleanroom installers --days 30 --limit 50
cleanroom cloudfiles --min-mb 250 --limit 50
cleanroom nodes ~/Documents --days 45 --limit 30
cleanroom venvs ~/Documents --days 45 --limit 30
cleanroom appdata --limit 30
cleanroom libraries
cleanroom cloud
cleanroom personal
```

Use this when macOS Storage reports a large Documents category. Review the output manually; cleanroom will not delete arbitrary personal files, protected media libraries, cloud-sync folders, or personal app databases.

`--include-screenshots` targets only known screenshot and screen recording filenames under Desktop, Downloads, and Documents older than `--days`. Use `--trash` for a recoverable applied run.

## Old Installers

```sh
cleanroom installers
cleanroom clean --include-installers --days 30
cleanroom clean --apply --trash --include-installers --days 30
```

Use this for old `.dmg`, `.pkg`, `.mpkg`, `.xip`, `.ipsw`, and `.iso` files in `~/Downloads`. The inventory is review-only; cleanup requires the explicit `--include-installers` flag.

## Download Artifacts

```sh
cleanroom downloads
cleanroom clean --include-download-artifacts --days 30
cleanroom clean --apply --trash --include-download-artifacts --days 30
```

Use this for old installers, disk images, and archive files directly under `~/Downloads`. It is broader than `--include-installers`, but still does not target arbitrary documents, photos, folders, or nested files.

## Metadata Clutter

```sh
cleanroom metadata
cleanroom metadata ~/Documents ~/Downloads --limit 50
cleanroom metadata --apply --trash
cleanroom clean --include-metadata
cleanroom clean --apply --trash --include-metadata
```

Use this after unzipping archives, working with network shares, or copying files between macOS and Windows. It targets removable metadata clutter such as `.DS_Store`, AppleDouble `._*` files, `__MACOSX` folders, `Thumbs.db`, and `Desktop.ini`; direct `metadata --apply` requires Trash mode.

## Quick Look Caches

```sh
cleanroom quicklook
cleanroom quicklook --json
cleanroom quicklook-fast --json
cleanroom clean --include-quicklook
cleanroom clean --apply --trash --include-quicklook
```

Use this when System Data is large and Finder thumbnails/previews have accumulated. Quick Look caches are rebuildable; macOS recreates thumbnails and previews as files are browsed again.

## Font Caches

```sh
cleanroom fontcaches
cleanroom fontcaches --json
cleanroom fontcaches-fast --json
cleanroom clean --include-font-caches
cleanroom clean --apply --trash --include-font-caches
```

Use this when font menus, previews, or rendering feel stale after installing or removing fonts. Cleanroom removes rebuildable user font cache databases only; it does not remove fonts from user, shared, or system font folders.

## Safari / WebKit Caches

```sh
cleanroom webcaches
cleanroom webcaches --json
cleanroom webcaches-fast --json
cleanroom clean --include-web-caches
cleanroom clean --apply --trash --include-web-caches
```

Use this when Safari or embedded web views have accumulated cache data. Cleanroom removes cache folders only; it does not remove Safari history, cookies, bookmarks, saved passwords, website data, Keychains, or browser profiles.

## Saved Application State

```sh
cleanroom savedstate
cleanroom savedstate --json
cleanroom savedstate-fast --json
cleanroom clean --include-saved-state
cleanroom clean --apply --trash --include-saved-state
```

Use this when apps keep restoring stale windows or when System Data includes saved app state. Cleanroom removes saved window/session state only; documents, app profiles, account data, and preferences stay protected.

## Project Caches

```sh
cleanroom projectcaches
cleanroom projectcaches ~/Documents --limit 50
cleanroom projectcaches --json
cleanroom clean --include-project-caches
cleanroom clean --apply --trash --include-project-caches
```

Review and clean app updater cache/staging data:

```sh
cleanroom updaters
cleanroom updaters --json
cleanroom updaters-fast --json
cleanroom clean --include-updater-caches
cleanroom clean --apply --trash --include-updater-caches
```

`updaters` targets rebuildable Sparkle and Squirrel updater cache/staging folders only. `updaters-fast` skips deep sizing for responsive app reviews. It does not remove apps, app profiles, browser profiles, passwords, cookies, bookmarks, or settings.

Review and clean Chromium/Firefox browser cache folders:

```sh
cleanroom browsercaches
cleanroom browsercaches --json
cleanroom clean --include-browser-caches
cleanroom clean --apply --trash --include-browser-caches
```

`browsercaches` targets rebuildable cache folders only. It does not remove browser profiles, password databases, cookies, bookmarks, sessions, extensions, or settings.

Use this for Python and test/tooling cache clutter inside local projects. Cleanroom targets known rebuildable cache artifacts only and prunes `.git`, `node_modules`, and virtualenv folders.

## Applications Storage

```sh
cleanroom apps --limit 30
cleanroom apps --json /Applications
```

Review large app bundles manually. cleanroom does not uninstall apps because app removal can require vendor uninstallers, launch agents, helper tools, login items, and account-specific data.

## App Leftovers

```sh
cleanroom appreview adobe
cleanroom leftovers adobe
cleanroom leftovers "creative cloud" --limit 50
cleanroom leftovers adobe --apply --trash
cleanroom leftovers zoom --json
```

Use `appreview` before uninstalling or removing a large app. It shows matching app bundles, official uninstallers, receipts, and leftovers in one place. Use `leftovers` after uninstalling; plain `leftovers` is a preview, while applied cleanup requires `--trash`, writes the normal cleanroom apply log, and can be restored with `cleanroom restore --log PATH --apply`.

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

Use this when System Data is large and you suspect local iPhone or iPad backups. cleanroom treats the MobileSync backup root as protected personal data.

After confirming another backup exists, old local device backups can be moved to the cleanroom Trash folder explicitly:

```sh
cleanroom clean --include-device-backups --days 90 --trash
cleanroom clean --include-device-backups --days 90 --apply --trash
```

This category is never enabled by presets and only targets direct MobileSync backup folders older than `--days`.

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
cleanroom state
cleanroom clean --include-cleanroom-state --days 30
cleanroom clean --apply --include-cleanroom-state --days 30
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

Review known AI tool storage first:

```sh
cleanroom aitools
cleanroom aitools --json
```

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

`--include-ai-workspaces` covers generated Gemini/Antigravity recordings, scratch folders, brain or memory data, implicit state, local conversation caches, and generated browser-profile rendering caches where known.

`--include-ai-models` covers downloaded model stores and backend extensions from LM Studio, Ollama, Hugging Face, ModelScope, torch hub, Whisper, llama.cpp, GPT4All, Jan, AnythingLLM, and similar known stores.

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
