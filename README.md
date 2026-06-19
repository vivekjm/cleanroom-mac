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
- Python/dev project caches such as `__pycache__`, pytest, mypy, ruff, tox, nox, and coverage artifacts
- AI-agent recordings, scratch data, local memory, and generated workspaces
- local AI model downloads and backends
- Chrome/VS Code/Cursor cache folders
- browser profile and cache footprint
- Quick Look thumbnail and preview caches
- large app support, container, and group-container folders
- Photos, Music, TV, iMovie, GarageBand, and Logic library footprint
- app leftovers after manual uninstalls
- old logs, crash reports, and diagnostic reports
- old downloaded installer files
- `.DS_Store`, AppleDouble, and cross-platform filesystem metadata clutter
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

Map major storage buckets:

```sh
cleanroom map
cleanroom map --json
```

Save a timestamped storage snapshot:

```sh
cleanroom snapshot
cleanroom snapshot --output ~/Desktop/cleanroom-before.json
cleanroom snapshot --json
cleanroom diff ~/Desktop/cleanroom-before.json ~/Desktop/cleanroom-after.json
cleanroom state
cleanroom clean --include-cleanroom-state --days 30
cleanroom clean --apply --include-cleanroom-state --days 30
cleanroom permissions
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

Review personal storage hotspots:

```sh
cleanroom review
cleanroom review --json
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

Find broken symlinks for manual review:

```sh
cleanroom brokenlinks
cleanroom brokenlinks ~/Documents --limit 50
cleanroom brokenlinks --json
```

Review downloaded files with macOS quarantine metadata:

```sh
cleanroom quarantine
cleanroom quarantine ~/Downloads --limit 50
cleanroom quarantine --json
```

Review removable filesystem metadata clutter:

```sh
cleanroom metadata
cleanroom metadata ~/Documents ~/Downloads --limit 50
cleanroom metadata --apply --trash
cleanroom metadata --json
```

Review Quick Look thumbnail and preview caches:

```sh
cleanroom quicklook
cleanroom quicklook --json
```

Review rebuildable user font cache databases:

```sh
cleanroom fontcaches
cleanroom fontcaches --json
```

Review Safari and WebKit browser cache folders:

```sh
cleanroom webcaches
cleanroom webcaches --json
```

Review saved app window/session state:

```sh
cleanroom savedstate
cleanroom savedstate --json
```

Review rebuildable project cache artifacts:

```sh
cleanroom projectcaches
cleanroom projectcaches ~/Documents --limit 50
cleanroom projectcaches --json
```

Review app updater cache/staging folders:

```sh
cleanroom updaters
cleanroom updaters --json
```

Review Chromium and Firefox browser cache folders:

```sh
cleanroom browsercaches
cleanroom browsercaches --json
```

Find exact duplicate files for manual review:

```sh
cleanroom duplicates
cleanroom duplicates ~/Documents --min-mb 100 --limit 20
cleanroom duplicates --json ~/Downloads
```

Break down Documents or any folder by top-level item:

```sh
cleanroom documents
cleanroom documents ~/Documents --limit 40
cleanroom documents --json
```

Break down Desktop clutter:

```sh
cleanroom desktop
cleanroom desktop --json
```

Review screenshot and screen recording clutter:

```sh
cleanroom screenshots
cleanroom screenshots ~/Desktop --days 7 --limit 50
cleanroom screenshots --json
cleanroom clean --include-screenshots --days 30
cleanroom clean --apply --trash --include-screenshots --days 30
```

Review archive and disk image clutter:

```sh
cleanroom archives
cleanroom archives ~/Downloads --days 7 --limit 50
cleanroom archives --json
```

Review old Downloads files:

```sh
cleanroom downloads
cleanroom downloads --days 30 --limit 50
cleanroom downloads --json
cleanroom clean --include-download-artifacts --days 30
cleanroom clean --apply --trash --include-download-artifacts --days 30
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

Find vendor uninstallers and remover tools:

```sh
cleanroom uninstallers
cleanroom uninstallers ~/Applications --limit 20
cleanroom uninstallers --json
```

Review an app before removal:

```sh
cleanroom appreview adobe
cleanroom appreview zoom --json
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
cleanroom cloudfiles
cleanroom cloudfiles ~/Library/CloudStorage --min-mb 250 --limit 50
cleanroom cloudfiles --json
```

Review protected personal app data:

```sh
cleanroom personal
cleanroom personal --json
```

Review protected Mail and Messages storage in detail:

```sh
cleanroom communications
cleanroom communications --json
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

Clean old local iPhone/iPad backups after review:

```sh
cleanroom backups
cleanroom clean --include-device-backups --days 90 --trash
cleanroom clean --include-device-backups --days 90 --apply --trash
```

Review Xcode and simulator storage:

```sh
cleanroom xcode
cleanroom xcode --json
```

Review Android SDK, emulator, and AVD storage:

```sh
cleanroom android
cleanroom android --json
```

Review startup and background launch items:

```sh
cleanroom startup
cleanroom startup --json
cleanroom loginitems
cleanroom loginitems --json
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

Inventory macOS package installer receipts:

```sh
cleanroom receipts
cleanroom receipts --limit 50
cleanroom receipts --json
```

`receipts` is read-only. It lists `.bom` and `.plist` installer receipt records from readable receipt folders, then points you to `cleanroom leftovers <package-id>` for app-specific review. Do not delete receipts to uninstall an app; use the vendor uninstaller first.

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
cleanroom report --redact --output cleanroom-report.md
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
cleanroom clean --preset dev --preflight
cleanroom clean --preset dev --preflight --json
```

`--preflight` summarizes selected cleanup categories, warnings, and recovery limits without scanning or deleting files. Use it before `--apply`, especially for opt-in categories such as containers, snapshots, AI models, SDKs, or current user Trash.

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
cleanroom clean --preset ai
cleanroom clean --preset deep
```

Preset meanings:

```text
safe  default rebuildable caches
dev   safe + app caches + package/toolchain stores + stale node_modules + stale virtualenvs
ai    generated AI workspace state + downloaded local AI models/backends
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

Clean filesystem metadata clutter:

```sh
cleanroom metadata
cleanroom metadata --apply --trash
cleanroom clean --include-metadata
cleanroom clean --apply --trash --include-metadata
```

Clean Quick Look thumbnail caches:

```sh
cleanroom quicklook
cleanroom clean --include-quicklook
cleanroom clean --apply --trash --include-quicklook
```

Clean user font cache databases:

```sh
cleanroom fontcaches
cleanroom clean --include-font-caches
cleanroom clean --apply --trash --include-font-caches
```

Clean Safari and WebKit cache folders:

```sh
cleanroom webcaches
cleanroom clean --include-web-caches
cleanroom clean --apply --trash --include-web-caches
```

Clean saved app window/session state:

```sh
cleanroom savedstate
cleanroom clean --include-saved-state
cleanroom clean --apply --trash --include-saved-state
```

Clean rebuildable project cache artifacts:

```sh
cleanroom projectcaches
cleanroom clean --include-project-caches
cleanroom clean --apply --trash --include-project-caches
```

Clean app updater cache/staging data:

```sh
cleanroom updaters
cleanroom clean --include-updater-caches
cleanroom clean --apply --trash --include-updater-caches
```

Clean Chromium and Firefox browser cache folders:

```sh
cleanroom browsercaches
cleanroom clean --include-browser-caches
cleanroom clean --apply --trash --include-browser-caches
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

`--include-metadata` removes filesystem metadata clutter such as `.DS_Store`, AppleDouble `._*` files, `__MACOSX` folders, `Thumbs.db`, `Desktop.ini`, and similar removable metadata from Desktop, Documents, and Downloads.

`--include-quicklook` removes rebuildable Quick Look thumbnail and preview caches. Finder and file dialogs may briefly regenerate previews afterward.

`--include-font-caches` removes rebuildable Apple Type Services and Font Registry user cache databases. It does not remove actual fonts from user, system, or shared font folders.

`--include-web-caches` removes Safari and WebKit cache folders only. It does not remove browsing history, cookies, saved passwords, bookmarks, website data, Keychains, or browser profiles.

`--include-saved-state` removes saved app window/session restoration state. Apps may reopen without previous windows, but documents, app profiles, and account data stay protected.

`--include-project-caches` removes known rebuildable project cache artifacts such as `__pycache__`, `.pytest_cache`, `.mypy_cache`, `.ruff_cache`, `.tox`, `.nox`, `htmlcov`, and `.coverage` under Desktop, Documents, and Downloads. It prunes `.git`, `node_modules`, and virtualenv folders.

`--include-updater-caches` removes rebuildable Sparkle and Squirrel app updater cache/staging data. Apps, app profiles, browser profiles, passwords, cookies, bookmarks, and settings are not targeted.

`--include-browser-caches` removes Chromium and Firefox browser cache folders only. Browser profiles, password databases, cookies, bookmarks, sessions, extensions, and settings are not targeted.

`--include-device-backups` moves local iPhone/iPad backups older than `--days` from MobileSync to the cleanroom Trash folder. It requires `--trash`, is never included in presets, and should only be used after confirming another backup exists.

`--include-screenshots` moves known screenshot and screen recording files older than `--days` from Desktop, Downloads, and Documents. It does not target arbitrary images or videos; use `--trash` for a recoverable applied run.

`--trash` applies to paths that `cleanroom` removes directly. System commands delegated to macOS or developer tools, such as Time Machine snapshot thinning or simulator reset, may still be irreversible.

`restore` only restores entries that were moved by `--trash` and still exist in the cleanroom Trash folder. It skips destinations that already exist.

`overview` summarizes disk state, top recommendations, package-store size, toolchain-cache size, container storage size, diagnostic-report size, protected-data presence, snapshots, app bundle count, and useful next commands without deleting anything.

`map` ranks focused major storage buckets such as Documents, Desktop, Downloads, user Applications, Application Support, app containers, cloud storage, media libraries, communication data, developer data, package stores, toolchains, container VMs, and Trash. It is review-only. Buckets can overlap when a smaller folder is also part of a larger parent.

`snapshot` writes the same focused storage-map data plus disk state into a timestamped JSON file under `~/.local/state/cleanroom/snapshots/`, or to `--output PATH`. It is useful before and after cleanup, installs, or support sessions.

`diff` compares two snapshot JSON files and ranks bucket deltas. With no paths, it compares the latest two snapshots from `~/.local/state/cleanroom/snapshots/`. It is read-only and useful for explaining what grew after an install or what shrank after cleanup.

`state` inventories Cleanroom-created audit logs, storage snapshots, and recoverable `~/.Trash/cleanroom-*` folders. It is read-only and helps users understand the tool's own footprint.

`--include-cleanroom-state` removes old Cleanroom-created audit logs, snapshots, and recoverable `~/.Trash/cleanroom-*` folders older than `--days`. It is never included in presets, because deleting old recovery folders can remove the easiest rollback path for previous `--trash` runs.

`permissions` audits whether common macOS privacy-sensitive storage locations exist and are readable/listable by the current terminal or app. If existing paths show `blocked` or `limited`, grant Full Disk Access to the app running Cleanroom for more complete inventories.

`review` gives normal users a read-only checklist of personal storage hotspots: Documents, Desktop, old Downloads, screenshots, archives, installers, app data, and installed app bundles. It points to the next focused command for each item.

`system-data` breaks common macOS System Data locations into focused buckets such as Application Support, caches, Developer data, container storage, diagnostics, MobileSync backups, Group Containers, HTTPStorages, and saved app state. It is review-only and points to the safest next command for each bucket.

`documents` ranks the top-level files and folders inside `~/Documents` or a provided directory. It is review-only, includes each item's guard status, and prints follow-up `documents` and `large` commands so you can drill down safely.

`desktop` is a convenience shortcut for the same guarded top-level inventory on `~/Desktop`, useful when screenshots, exports, archives, and loose project folders have piled up.

`screenshots` lists screenshot and screen recording files in Desktop, Downloads, and Documents, or a provided folder. Cleanup is opt-in with `--include-screenshots` and targets only known screenshot/recording filenames older than `--days`; arbitrary images and videos are not removed.

`archives` lists archive and disk image files such as `.zip`, `.rar`, `.7z`, `.tar.*`, `.dmg`, `.iso`, and `.img` in Downloads, Desktop, and Documents, or a provided folder. It is review-only because archives may be backups, deliverables, or installer sources.

`cloudfiles` lists large local files inside iCloud Drive, File Provider CloudStorage, Dropbox, Google Drive, OneDrive, Box, and Sync roots. It is review-only and does not delete files or evict local copies, because local deletes can sync remotely.

`android --json` emits Android SDK, NDK, system image, emulator, AVD, platform, build-tool, command-line tool, and Android Studio cache sizes with safety labels. NDKs, system images, and temporary SDK downloads are opt-in through `--include-dev-heavy`; full SDK roots and AVDs stay review-only.

`caches --json` emits safe and opt-in cache bucket sizes with the matching preview and apply commands.

`diagnostics` inventories user logs, diagnostic reports, and CrashReporter data. Default cleanup already removes old log files; diagnostic report cleanup is opt-in with `cleanroom clean --include-diagnostics --days N`.

`doctor --json` emits platform, config, disk, dependency, and safety-catalog diagnostics for wrappers and support reports.

`report` writes a Markdown summary with disk state, cleanup candidates, largest known cleanup locations, large-file hints from Spotlight, protected personal-data paths, and safety notes. Add `--redact` before sharing in GitHub issues or support chats; it masks home, user, and temporary paths while keeping storage categories readable.

`plan` estimates cleanup opportunities and prints copyable dry-run commands plus explicit apply commands. It does not delete anything.

`large` lists large files for review and never deletes them. Use it when macOS reports high Documents storage and you need to find videos, archives, disk images, datasets, or project artifacts manually.

`brokenlinks` lists dangling symlinks from common user folders or a path you provide. It never deletes links; review them first because source trees, package managers, and managed apps may intentionally leave links behind.

`quarantine` lists files and apps carrying macOS `com.apple.quarantine` metadata, usually downloaded from browsers, chat apps, or email. It never deletes files or clears attributes; use it to review downloaded content before deciding what to keep.

`metadata` lists `.DS_Store`, AppleDouble `._*` files, `__MACOSX` folders, `Thumbs.db`, `Desktop.ini`, and similar cross-platform metadata clutter under Desktop, Documents, Downloads, or paths you provide. Its direct apply mode requires `--trash`.

`quicklook` inventories rebuildable Quick Look thumbnail and preview caches that can contribute to System Data. Cleanup is opt-in with `cleanroom clean --include-quicklook`.

`fontcaches` inventories rebuildable user font cache databases that can contribute to System Data or font rendering weirdness. Cleanup is opt-in with `cleanroom clean --include-font-caches`; actual font files stay protected.

`webcaches` inventories Safari and WebKit cache folders that can grow in System Data. Cleanup is opt-in with `cleanroom clean --include-web-caches`; browser history, cookies, bookmarks, website data, passwords, and profiles stay protected.

`savedstate` inventories saved application window/session state under `~/Library/Saved Application State`. Cleanup is opt-in with `cleanroom clean --include-saved-state`; documents and app profiles stay protected.

`projectcaches` inventories known rebuildable project cache artifacts under Desktop, Documents, Downloads, or a provided folder. Cleanup is opt-in with `cleanroom clean --include-project-caches`; source, `.git`, `node_modules`, and virtualenv folders stay protected.

`updaters` inventories rebuildable Sparkle and Squirrel app updater cache/staging folders. Cleanup is opt-in with `cleanroom clean --include-updater-caches`; apps, profiles, browser data, and passwords stay protected.

`browsercaches` inventories Chromium and Firefox cache folders. Cleanup is opt-in with `cleanroom clean --include-browser-caches`; profiles, password databases, cookies, bookmarks, sessions, extensions, and settings stay protected.

`duplicates` hashes files above `--min-mb`, groups exact matches, estimates possible reclaim, and never deletes anything.

`downloads` lists old files in `~/Downloads` for manual review. Cleanup is opt-in for old downloadable artifacts only with `--include-download-artifacts`; arbitrary documents, photos, folders, and nested files are not targeted.

`installers` lists old `.dmg`, `.pkg`, `.mpkg`, `.xip`, `.ipsw`, and `.iso` files in `~/Downloads`. Cleanup is opt-in with `--include-installers`.

`nodes` lists stale `node_modules` folders before you decide whether to run `cleanroom clean --include-node-stale --apply`.

`venvs` lists stale Python virtualenv folders before you decide whether to run `cleanroom clean --include-venv-stale --apply`. It only treats folders with `pyvenv.cfg` as virtualenv cleanup candidates.

`apps` lists `.app` bundle sizes from `/Applications` and `~/Applications`, or a path you provide. It never uninstalls apps.

`uninstallers` lists likely vendor uninstallers, remover apps, packages, and scripts from common application and Application Support locations, or a path you provide. It never runs or removes them; use these official tools before manual leftover cleanup.

`appreview` combines matching app bundles, vendor uninstallers, package receipts, and leftover candidates into one read-only workflow. Use it before removing apps so official uninstallers and package records are visible before leftover cleanup.

`appdata` ranks top-level Application Support, Containers, Group Containers, HTTPStorages, WebKit, and saved-state folders. It is review-only and includes the central guard status so protected profiles and personal data stand out before you investigate with `leftovers APPNAME`.

`android` helps diagnose large developer storage created by Android Studio, Expo, React Native, Flutter, and native Android work. It inventories the SDK and emulator footprint before suggesting the explicit `clean --include-dev-heavy` path for redownloadable NDK/system-image/temp-download data.

`libraries` inventories protected media and creative libraries such as Photos, Photo Booth, Music, iTunes, TV, iMovie, GarageBand, Logic, and Audio Music Apps. It is review-only and helps explain large Documents or media storage without deleting personal projects.

`cloud` inventories protected cloud-sync folders such as iCloud Drive, File Provider CloudStorage, Dropbox, Google Drive, OneDrive, Box, and Sync. It is review-only because local deletes can affect remote cloud or peer data.

`personal` inventories protected app data such as Mail, Messages, Contacts, Calendars, Notes, Reminders, Voice Memos, and call history. It is review-only and helps explain large personal app storage without deleting account data.

`communications` inventories protected Mail, Mail Downloads, Messages, and Messages Attachments storage in more detail. It is review-only and helps explain large communication attachments without deleting accounts, chats, or message files.

`browsers` separates safe browser cache candidates from protected profile storage. It reports Chrome, Brave, Edge, Arc, Firefox, and Safari profile sizes, but cleanup commands still remove only cache folders and never profiles, passwords, cookies, bookmarks, or sessions.

`leftovers` searches common support, cache, preference, container, WebKit, log, and launch-item locations for an app or vendor name. By default it previews only. If you explicitly pass `--apply --trash`, matches move into a cleanroom Trash folder and are recorded in the apply log so `cleanroom restore --log PATH --apply` can put them back. Protected browser profiles, Keychains, device backups, Photos, Mail, iCloud Drive, and broad Library folders are still refused.

`backups` inventories local iPhone and iPad backups under MobileSync. Device-backup cleanup is high-impact and opt-in with `cleanroom clean --include-device-backups --days N --apply --trash`; only direct backup folders older than `--days` are moved, and the MobileSync root remains protected.

`xcode` inventories DerivedData, simulator caches, DeviceSupport, simulator devices, and Xcode Archives. It separates rebuildable caches from review-only archives and high-impact simulator data.

`startup` lists LaunchAgents and LaunchDaemons for review. It never unloads, disables, or removes startup items.

`loginitems` lists user Login Items reported by macOS System Events, including hidden status and app path when available. It never disables or removes anything; manage entries in System Settings > General > Login Items. macOS may ask for automation permission before returning results.

`trash` inventories current `~/.Trash` contents. `--include-user-trash` empties Trash only when explicitly requested, and it is intentionally not included in presets.

`packages` inventories npm, Yarn, pnpm, Gradle, CocoaPods, Cargo, and Homebrew stores with preview/apply commands for matching cleanup categories.

`npm-cache` runs npm's native cache workflow. It defaults to `npm cache verify`; add `--apply --yes` to run `npm cache clean --force`. Use this when you want npm's own cache maintenance before or instead of removing known npm cache folders through `cleanroom clean`.

`receipts` inventories macOS package installer receipt records from `/var/db/receipts`, `/Library/Receipts`, and `~/Library/Receipts`. It is useful when investigating software installed by `.pkg` installers, because package IDs often hint at vendor leftovers to inspect next. Cleanroom never removes receipt records.

`homebrew` inventories Homebrew cache, logs, Cellar, Caskroom, and service/runtime folders. It is review-only and points to `cleanroom homebrew-cleanup` for Homebrew-native dry-run detail.

`homebrew-cleanup` runs Homebrew's own cleanup flow. It defaults to `brew cleanup -n`; add `--apply --yes` to run `brew cleanup`. This delegates formula and cask cleanup decisions to Homebrew instead of hand-deleting Cellar or Caskroom internals.

`toolchains` inventories rebuildable language/toolchain caches for Go, pip, uv, Poetry, SwiftPM, Maven, Composer, RubyGems, and Bundler. Cleanup is opt-in with `cleanroom clean --include-toolchains`, and `--trash` keeps removals restorable through the normal apply log.

`containers` inventories local container VM disks and image stores for Docker Desktop, Colima, Lima, and Podman. Cleanup is high-impact and opt-in with `cleanroom clean --include-containers`.

`snapshots` lists local Time Machine snapshots before you decide whether to run `cleanroom clean --include-snapshots --apply`.

The project also ships `make install`, `make uninstall`, `make lint`, `make test`, `make package`, `make homebrew-formula`, and `make macos-app` targets for maintainers and package managers.

Release packaging is documented in [docs/RELEASE.md](docs/RELEASE.md).

## License

MIT
