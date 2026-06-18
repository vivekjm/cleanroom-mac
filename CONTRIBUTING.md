# Contributing

Thanks for helping make `cleanroom` safer and more useful.

## Principles

- Safe by default.
- Dry-run before deletion.
- Browser profiles, password databases, Keychains, and personal libraries are protected.
- Destructive cleanup categories must be explicitly opted into.
- Prefer deleting rebuildable cache/artifact folders over app data.
- Keep `data/cleanup-rules.tsv` in sync with cleanup behavior and safety docs.

## Testing

Run:

```sh
make test
```

GitHub Actions runs the same macOS smoke suite on pushes and pull requests. CI also builds the release archive, renders the Homebrew formula, builds the macOS app, verifies checksums, verifies the ad-hoc app signature, and checks that redacted reports mask local paths.

Or run the individual checks:

```sh
bash -n bin/cleanroom
./bin/cleanroom --version
./bin/cleanroom report
./bin/cleanroom clean --include-app-caches
./bin/cleanroom clean --apply --trash --yes --log /tmp/cleanroom-test.log
./bin/cleanroom init-config --config /tmp/cleanroom-test-config --yes
./test/smoke.sh
```

Avoid running `--apply` in tests unless inside a disposable macOS account or fixture directory. Prefer `--trash` and a temporary `--log` path for integration tests.

## Releases

Run:

```sh
make package
make homebrew-formula
make macos-app
```

This validates version consistency, runs tests, and writes a tarball, SHA-256 file, generated Homebrew formula, and macOS app archive under `dist/`.

See [docs/RELEASE.md](docs/RELEASE.md) for tagging and GitHub release steps.
