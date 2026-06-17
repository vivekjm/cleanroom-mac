#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"
DIST_DIR="${DIST_DIR:-$ROOT/dist}"
STAGE="$DIST_DIR/cleanroom-$VERSION"
ARCHIVE="$DIST_DIR/cleanroom-$VERSION.tar.gz"

"$ROOT/scripts/check-version.sh" >/dev/null

rm -rf "$STAGE" "$ARCHIVE"
mkdir -p "$STAGE"

copy_path() {
  local source="$1"
  local target="$STAGE/$source"
  mkdir -p "$(dirname "$target")"
  cp -R "$ROOT/$source" "$target"
}

copy_path "VERSION"
copy_path "LICENSE"
copy_path "README.md"
copy_path "CONTRIBUTING.md"
copy_path "Makefile"
copy_path "install.sh"
copy_path "uninstall.sh"
copy_path "bin"
copy_path "completions"
copy_path "man"
copy_path "docs"
copy_path "homebrew"
copy_path "macos"
copy_path "scripts"
copy_path "test"

find "$STAGE" -name '.DS_Store' -delete
chmod +x "$STAGE/bin/cleanroom" "$STAGE/install.sh" "$STAGE/uninstall.sh"

(cd "$DIST_DIR" && tar -czf "$(basename "$ARCHIVE")" "cleanroom-$VERSION")
(cd "$DIST_DIR" && shasum -a 256 "$(basename "$ARCHIVE")" >"$(basename "$ARCHIVE").sha256")

printf '%s\n' "$ARCHIVE"
printf '%s\n' "$ARCHIVE.sha256"
