# Cleanroom

Cleanroom is a safe macOS storage cleaner. It helps you find what is filling your Mac, review the files clearly, and move safe cleanup items to Trash.

It is built for normal Mac users first: fast reviews, visible file lists, plain language, and no command-line details in the desktop workflow.

## Highlights

- Fast reviews for Documents, Downloads, Desktop, archives, screenshots, apps, caches, developer files, AI tool data, and large files.
- Clear file rows with names, sizes, locations, Finder reveal, folder drill-down, Show more, and guarded Move to Trash.
- Conservative cleanup for rebuildable clutter such as logs, Quick Look thumbnails, metadata files, update caches, package caches, and project caches.
- App leftover review after uninstalling software.
- Developer storage review for stale `node_modules`, Python virtual environments, toolchains, simulators, and package stores.
- AI storage review for downloaded local models, generated workspace state, temporary data, and rebuildable backends.

## Protected By Default

Cleanroom does not automatically clean:

- browser profiles, saved passwords, cookies, bookmarks, sessions, extensions, or Keychains
- Photos, Music, TV, iMovie, GarageBand, or Logic libraries
- Mail, Messages, Contacts, Calendars, Notes, Reminders, Voice Memos, or call history
- iCloud Drive or cloud-sync roots such as Dropbox, Google Drive, OneDrive, Box, or Syncthing
- whole app profiles, broad Library folders, or arbitrary personal folders

## Desktop App

Build and open the app:

```sh
make macos-app
open dist/Cleanroom.app
```

Use the app to:

1. Pick an area such as Documents, Downloads, Caches, Apps, or AI Tools.
2. Review the visible list of files and folders.
3. Open folders, show items in Finder, show more results, or move eligible files to Trash.
4. Run Safe Cleanup only after reviewing the plan.

## Install The CLI

The command-line tool is useful for automation and advanced users.

```sh
./install.sh
```

Install to a custom prefix:

```sh
PREFIX="$HOME/.local" ./install.sh
```

Uninstall:

```sh
./uninstall.sh
```

## Useful Commands

```sh
cleanroom documents-fast
cleanroom downloads-fast
cleanroom aitools-fast
cleanroom appreview "App Name"
cleanroom clean --preflight
cleanroom clean --apply --trash --yes
```

## Development

```sh
make test
make package
make homebrew-formula
make macos-app
```

The local app build is ad-hoc signed. Release builds need maintainer signing and notarization.

## License

MIT
