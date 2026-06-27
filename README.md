# Cleanroom

Cleanroom is a safe macOS storage cleaner for people who want disk space back without digging through hidden folders.

It focuses on the places that usually make a Mac feel full or slow: Documents, Downloads, developer caches, app leftovers, AI tool data, browser caches, logs, old archives, screenshots, and rebuildable system clutter.

## What It Does

- Shows large files and folders with clear names, sizes, and locations.
- Finds rebuildable junk such as caches, logs, Quick Look thumbnails, metadata files, update caches, project caches, stale package folders, and old generated data.
- Reviews app leftovers after uninstalling apps.
- Helps trim developer storage such as stale `node_modules`, virtual environments, package caches, simulators, and toolchain clutter.
- Helps review AI tool storage such as downloaded models, generated state, and temporary workspace data.
- Moves recoverable cleanup items to Trash when requested.
- Keeps cleanup history so Trash-mode runs can be inspected and restored.

## What It Protects

Cleanroom is review-first and conservative by default. It does not clean these automatically:

- browser profiles, saved passwords, cookies, bookmarks, sessions, and Keychains
- Photos, Music, TV, iMovie, GarageBand, and Logic libraries
- Mail, Messages, Contacts, Calendars, Notes, Reminders, Voice Memos, and call history
- iCloud Drive and cloud-sync roots such as Dropbox, Google Drive, OneDrive, Box, and Syncthing
- arbitrary personal files in Documents, Desktop, and Downloads

## Desktop App

Build and open the local macOS app:

```sh
make macos-app
open dist/Cleanroom.app
```

The app is designed for normal Mac users: review first, clear file lists, plain language, and no command-line details in the main workflow.

## Install

From this repo:

```sh
./install.sh
```

Install somewhere else:

```sh
PREFIX="$HOME/.local" ./install.sh
```

From a release archive:

```sh
tar -xzf cleanroom-*.tar.gz
cd cleanroom-*
./install.sh
```

Uninstall:

```sh
./uninstall.sh
```

## Common Tasks

List what is making Documents large:

```sh
cleanroom documents-fast
```

Review safe cleanup areas:

```sh
cleanroom clean --preflight
```

Clean safe rebuildable clutter and move recoverable items to Trash:

```sh
cleanroom clean --apply --trash --yes
```

Find stale project packages:

```sh
cleanroom nodes-fast
cleanroom venvs-fast
```

Review app leftovers after uninstalling an app:

```sh
cleanroom appreview "App Name"
cleanroom leftovers "App Name"
```

Review AI tool storage:

```sh
cleanroom aitools-fast
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
