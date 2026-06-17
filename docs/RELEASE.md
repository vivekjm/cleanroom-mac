# Release Process

This project releases a portable tarball for macOS users and package managers.

## Prepare

1. Update `VERSION`.
2. Update `VERSION` in `bin/cleanroom`.
3. Update the version string in `man/cleanroom.1`.
4. Run:

```sh
make dist
```

## Tag

```sh
version="$(cat VERSION)"
git tag "v$version"
git push origin "v$version"
```

The GitHub release workflow builds `dist/cleanroom-$version.tar.gz` and its SHA-256 file.

## Manual Package

```sh
make package
ls dist
```

Users can install from the archive with:

```sh
tar -xzf cleanroom-*.tar.gz
cd cleanroom-*
./install.sh
```
