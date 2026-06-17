#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"

fail=0

check_contains() {
  local file="$1"
  local pattern="$2"
  if ! grep -F "$pattern" "$ROOT/$file" >/dev/null; then
    printf 'version mismatch: %s does not contain %s\n' "$file" "$pattern" >&2
    fail=1
  fi
}

check_contains "bin/cleanroom" "VERSION=\"$VERSION\""
check_contains "man/cleanroom.1" "cleanroom $VERSION"

actual="$("$ROOT/bin/cleanroom" --version)"
if [[ "$actual" != "$VERSION" ]]; then
  printf 'version mismatch: bin/cleanroom --version returned %s, expected %s\n' "$actual" "$VERSION" >&2
  fail=1
fi

if [[ "$fail" -ne 0 ]]; then
  exit 1
fi

printf 'version %s ok\n' "$VERSION"
