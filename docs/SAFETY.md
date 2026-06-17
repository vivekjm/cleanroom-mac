# Safety Notes

`cleanroom` is designed around a hard lesson: app profile folders can contain irreplaceable local state.

Never delete these by default:

- `~/Library/Application Support/Google/Chrome`
- `~/Library/Application Support/BraveSoftware`
- `~/Library/Application Support/Arc`
- `~/Library/Keychains`
- `~/Pictures/Photos Library.photoslibrary`
- `~/Library/Mail`
- `~/Library/Mobile Documents`

The app cache cleaner only removes nested folders with names like:

- `Cache`
- `Code Cache`
- `GPUCache`
- `DawnCache`
- `ShaderCache`
- `CachedData`
- `Crashpad`

It must not remove the whole profile folder.

## Explicit Opt-In Categories

These categories are intentionally excluded from the default cleaner:

- `--include-dev-heavy`: SDKs, simulator state, Android NDK/system images.
- `--include-toolchains`: rebuildable language/toolchain caches such as Go modules, pip, uv, Poetry, SwiftPM, Maven, Composer, RubyGems, and Bundler caches.
- `--include-ai-workspaces`: generated AI-agent recordings, scratch folders, memory/brain folders, and local conversation caches where known.
- `--include-ai-models`: downloaded local model files and AI backend extensions. These can be re-downloaded, but may be intentionally installed by the user.
- `--include-containers`: local container VM disks and image stores for Docker Desktop, Colima, Lima, and Podman. This may remove containers, images, and volumes.

Any new rule that can remove personal state, credentials, app profiles, project source, model downloads, or container volumes must be behind an explicit opt-in flag.

The rule catalog lives in `data/cleanup-rules.tsv` and is visible through:

```sh
cleanroom rules
cleanroom rules --json
```

Protected personal-state paths live in `data/protected-paths.tsv` and are visible through:

```sh
cleanroom protect
cleanroom protect --json
```

Use this audit when reviewing browser profiles, saved-password-adjacent files, Keychains, Photos, Mail, iCloud Drive, Messages, Contacts, or any new app profile family. New cleanup rules should never remove these locations wholesale.

Keep both catalogs in sync with cleanup behavior so users and wrappers can inspect risk before running anything.

## Guard Checks

Before deleting any direct path, cleanroom checks:

- broad dangerous paths such as `/`, `$HOME`, `~/Library`, `~/Documents`, `~/Desktop`, and `~/Downloads`
- exact protected catalog paths
- ancestor folders that would contain a protected catalog path
- user-provided excludes

You can inspect the same decision with:

```sh
cleanroom guard ~/Library/Application\ Support/Google/Chrome
cleanroom guard --json ~/Library/Application\ Support/Google/Chrome/Default/Login\ Data
```

Nested cache folders can still be allowed when they do not contain a protected catalog path. For example, a browser `Cache` folder can be removable while the profile folder and `Login Data` stay refused.

## Excludes

Users can protect custom paths with:

```sh
cleanroom clean --exclude ~/Desktop/important-project
```

or in config:

```text
exclude=~/Desktop/important-project
```

Excludes apply centrally to deletion helpers and should be respected by new cleanup rules.

## Apply Safety

`cleanroom` is dry-run by default and requires `--apply` before deleting anything.

Use `--trash` to move cleanroom-managed path removals to `~/.Trash/cleanroom-*` instead of deleting them immediately. Applied runs write an audit log under `~/.local/state/cleanroom/runs/` unless `--log` is provided.

Use `cleanroom history` to find recent logs, and `cleanroom restore --log PATH` to preview restoring Trash-mode entries. Add `--apply` only after reviewing the restore preview.

All direct path removals should go through the central deletion helpers. They enforce excludes, refuse dangerous broad paths such as the home directory and top-level personal folders, support Trash mode, and write audit log entries.

Trash mode is a recovery aid, not a backup. System commands delegated to macOS or developer tools, such as Time Machine snapshot thinning or simulator reset, may still be irreversible.
