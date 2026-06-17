# Contributing

Thanks for helping make `cleanroom` safer and more useful.

## Principles

- Safe by default.
- Dry-run before deletion.
- Browser profiles, password databases, Keychains, and personal libraries are protected.
- Destructive cleanup categories must be explicitly opted into.
- Prefer deleting rebuildable cache/artifact folders over app data.

## Testing

Run:

```sh
bash -n bin/cleanroom
./bin/cleanroom --version
./bin/cleanroom clean --include-app-caches
```

Avoid running `--apply` in tests unless inside a disposable macOS account or fixture directory.
