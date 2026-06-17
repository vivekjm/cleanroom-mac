# cleanroom

`cleanroom` is a safe-by-default macOS storage cleaner for developers and power users.

It scans the places that commonly bloat macOS storage, then cleans only rebuildable cache/artifact data unless you explicitly opt into heavier categories.

## Why

macOS Storage often labels hidden user folders as **Documents** or **System Data**. In real machines this can include:

- Xcode and simulator artifacts
- Android SDK NDK/system images
- npm, Yarn, pnpm, Gradle, CocoaPods stores
- old `node_modules`
- Gemini/Antigravity recordings and scratch data
- LM Studio model downloads
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

## Install

From this repo:

```sh
./install.sh
```

Or run directly:

```sh
./bin/cleanroom scan
```

## Usage

Scan:

```sh
cleanroom scan
```

Preview safe cleanup:

```sh
cleanroom clean
```

Apply safe cleanup:

```sh
cleanroom clean --apply
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

Clean Gemini/Antigravity generated recordings/scratch/brain data:

```sh
cleanroom clean --apply --include-gemini
```

Clean LM Studio downloaded models/backends:

```sh
cleanroom clean --apply --include-lmstudio
```

Combine categories:

```sh
cleanroom clean --apply --include-app-caches --include-dev-heavy --include-node-stale --days 30
```

## Notes

`--include-dev-heavy` can remove simulator app state and Android SDK components that may need to be reinstalled later.

`--include-gemini` removes generated Gemini/Antigravity state such as recordings, scratch folders, brain data, implicit data, and conversations.

`--include-lmstudio` removes downloaded models and backend extensions. LM Studio can download them again later.

## License

MIT
