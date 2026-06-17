# Recipes

Common `cleanroom` workflows.

## Start Here

```sh
cleanroom scan
cleanroom doctor
cleanroom categories
cleanroom init-config
cleanroom clean
```

`cleanroom clean` is a dry-run. Add `--apply` only after reviewing the preview.

## Automation / Reporting

```sh
cleanroom scan --json
cleanroom report --output cleanroom-report.md
```

`scan --json` emits disk and candidate sizes as JSON for wrappers, dashboards, or future GUI frontends.

`report` writes a Markdown summary with disk state, cleanup candidates, largest known cleanup locations, large-file hints from Spotlight, and safety notes. It is useful before asking for help because people can inspect what is taking space without deleting anything.

## Developer Laptop

```sh
cleanroom clean --preset dev
cleanroom clean --preset dev --apply
```

Good for package stores, stale `node_modules`, and safe app caches.

## Config File

```sh
cleanroom init-config
cleanroom clean --config ~/.config/cleanroom/config
```

Protect important project folders:

```text
exclude=~/Desktop/important-project
exclude=~/Documents/client-work
```

Config files are plain `key=value` data and are not executed as shell.

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
tmutil listlocalsnapshots /
```

Then try:

```sh
cleanroom clean --include-snapshots --apply
```

macOS Storage can lag after large deletes. Restarting often helps it recalculate.
