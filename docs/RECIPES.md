# Recipes

Common `cleanroom` workflows.

## Start Here

```sh
cleanroom overview
cleanroom scan
cleanroom plan
cleanroom large
cleanroom duplicates
cleanroom nodes
cleanroom apps
cleanroom startup
cleanroom trash
cleanroom caches
cleanroom packages
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
cleanroom scan --json
cleanroom plan --json
cleanroom large --json ~/Documents
cleanroom duplicates --json ~/Documents
cleanroom nodes --json ~/Documents
cleanroom apps --json
cleanroom startup --json
cleanroom trash --json
cleanroom caches --json
cleanroom packages --json
cleanroom snapshots --json
cleanroom doctor --json
cleanroom protect --json
cleanroom guard --json ~/Library/Application\ Support/Google/Chrome
cleanroom rules --json
cleanroom report --output cleanroom-report.md
```

`overview --json` emits a compact dashboard with disk state, summary counts, and top cleanup recommendations.

`scan --json` emits disk and candidate sizes as JSON for wrappers, dashboards, or future GUI frontends.

`plan --json` emits ranked cleanup recommendations with estimated reclaim size, preview commands, and explicit apply commands.

`large --json [PATH]` emits large files above `--min-mb` for review. It is intentionally review-only and does not delete anything.

`duplicates --json [PATH]` emits exact duplicate groups with SHA-256 hashes, paths, and estimated possible reclaim. It is intentionally review-only and does not delete anything.

`nodes --json [PATH]` emits stale `node_modules` folders with age, size, and the matching preview/apply commands.

`apps --json [PATH]` emits app bundle sizes for `/Applications`, `~/Applications`, or a provided path. It is intentionally review-only and does not uninstall anything.

`startup --json` emits LaunchAgents and LaunchDaemons with scope, type, status, label, program, and path. It is intentionally review-only and does not unload, disable, or remove anything.

`trash --json` emits current `~/.Trash` size and top-level items. Emptying Trash requires `cleanroom clean --include-user-trash --apply`.

`caches --json` emits safe and opt-in cache bucket sizes with the matching preview and apply commands.

`packages --json` emits package-manager store sizes and matching preview/apply commands.

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

Good for package stores, stale `node_modules`, and safe app caches.

Inspect stale `node_modules` first:

```sh
cleanroom nodes
cleanroom nodes ~/Documents --days 45 --limit 30
```

Inspect cache buckets first:

```sh
cleanroom caches
```

Inspect package stores first:

```sh
cleanroom packages
cleanroom clean --include-package-stores
```

## Documents Storage

```sh
cleanroom large ~/Documents --min-mb 250 --limit 50
cleanroom large ~/Downloads --min-mb 100 --limit 50
cleanroom duplicates ~/Documents --min-mb 100 --limit 20
cleanroom nodes ~/Documents --days 45 --limit 30
```

Use this when macOS Storage reports a large Documents category. Review the output manually; cleanroom will not delete arbitrary personal files.

## Applications Storage

```sh
cleanroom apps --limit 30
cleanroom apps --json /Applications
```

Review large app bundles manually. cleanroom does not uninstall apps because app removal can require vendor uninstallers, launch agents, helper tools, login items, and account-specific data.

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
cleanroom clean --include-containers
cleanroom clean --include-containers --apply
```

This can remove local container VM disks, images, and volumes.

## “System Data” Looks Wrong

```sh
cleanroom scan
cleanroom snapshots
```

Then try:

```sh
cleanroom clean --include-snapshots
cleanroom clean --include-snapshots --apply
```

macOS Storage can lag after large deletes. Restarting often helps it recalculate.
