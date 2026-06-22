# Release Process

This project releases a portable tarball, a generated Homebrew formula, and a lightweight macOS app wrapper for macOS users and package managers.

## Prepare

1. Update `VERSION`.
2. Update `VERSION` in `bin/cleanroom`.
3. Update the version string in `man/cleanroom.1`.
4. Run:

```sh
make dist homebrew-formula macos-app
```

## Tag

```sh
version="$(cat VERSION)"
git tag "v$version"
git push origin "v$version"
```

The GitHub release workflow builds:

- `dist/cleanroom-$version.tar.gz`
- `dist/cleanroom-$version.tar.gz.sha256`
- `dist/Formula/cleanroom.rb`
- `dist/Cleanroom.app.zip`
- `dist/Cleanroom.app.zip.sha256`

## Manual Package

```sh
make package
make homebrew-formula
make macos-app
ls dist
```

Users can install from the archive with:

```sh
tar -xzf cleanroom-*.tar.gz
cd cleanroom-*
./install.sh
```

After the GitHub release artifact exists, test the generated formula locally:

```sh
brew install ./dist/Formula/cleanroom.rb
cleanroom --version
brew uninstall cleanroom
```

When publishing to a tap, copy `dist/Formula/cleanroom.rb` into that tap after the GitHub release artifact exists.

The desktop app is intentionally high-level. It opens without a heavy storage scan, uses the fast dashboard summary for top-level Scan/Review refreshes, keeps implementation details hidden, and applies the safe cleanup flow through the native confirmation sheet.

Local app builds are ad-hoc signed. A notarized public app release requires a Developer ID certificate and Apple notarization outside this repository's default CI path.
