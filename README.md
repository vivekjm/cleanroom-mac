# Cleanroom

Cleanroom is a fast, safe macOS storage cleaner.

It helps you see what is taking space, review real file and folder lists, and move eligible clutter to Trash without touching personal data like passwords, browser profiles, photos, mail, or cloud folders.

## What You Get

- Fast storage reviews for Documents, Downloads, Desktop, archives, screenshots, apps, caches, developer files, AI tools, and large files.
- Clear file lists with names, sizes, locations, Finder reveal, folder drill-down, and Show more.
- Guarded Move to Trash for reviewable personal files.
- Safe Cleanup for rebuildable clutter such as logs, Quick Look thumbnails, metadata files, update caches, package caches, and project caches.
- App leftover review for files left behind after uninstalling apps.
- Developer cleanup helpers for stale `node_modules`, Python virtual environments, Xcode data, simulators, Android data, and package stores.
- AI tool cleanup helpers for Gemini, Antigravity, LM Studio, Cursor, Trae, Comet, local models, generated state, and downloadable app components.

## Safe By Default

Cleanroom refuses to automatically clean high-risk data:

- Chrome, Safari, Firefox, Brave, Arc, and other browser profiles
- saved passwords, cookies, bookmarks, sessions, extensions, and Keychains
- Photos, Music, TV, iMovie, GarageBand, and Logic libraries
- Mail, Messages, Contacts, Calendars, Notes, Reminders, Voice Memos, and call history
- iCloud Drive, Dropbox, Google Drive, OneDrive, Box, Syncthing, and other cloud-sync roots
- whole app profiles, broad Library folders, and arbitrary personal folders

Cleanup actions move files to Trash first whenever possible, so you can review before emptying Trash.

## Use The Mac App

Build and open the desktop app:

```sh
make macos-app
open dist/Cleanroom.app
```

Then:

1. Choose an area such as Documents, Downloads, Caches, Apps, Developer Files, or AI Tools.
2. Review the visible file and folder rows.
3. Open folders, reveal items in Finder, show more results, or move eligible files to Trash.
4. Run Safe Cleanup only after reviewing the cleanup plan.

## Good For

- Macs where System Settings shows huge Documents or System Data usage.
- Developers with old project dependencies, build caches, simulators, and toolchains.
- AI app users with downloaded local models, generated state, and large workspace folders.
- Anyone who wants a review-first cleaner instead of a one-click delete tool.

## Build From Source

```sh
git clone https://github.com/vivekjm/cleanroom-mac.git
cd cleanroom-mac
make macos-app
open dist/Cleanroom.app
```

## For Contributors

```sh
make test
make package
make homebrew-formula
make macos-app
```

<details>
<summary>Advanced command-line use</summary>

The desktop app is the primary experience. The command-line tool is available for automation, scripting, and contributors.

Install locally:

```sh
./install.sh
```

Useful review commands:

```sh
cleanroom documents-fast
cleanroom downloads-fast
cleanroom aitools-fast
cleanroom appreview "App Name"
cleanroom clean --preflight
```

Apply safe cleanup after review:

```sh
cleanroom clean --apply --trash --yes
```

</details>

## License

MIT
