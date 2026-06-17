#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"
ARCHIVE="$ROOT/dist/cleanroom-$VERSION.tar.gz"
TEMPLATE="$ROOT/homebrew/cleanroom.rb.in"
OUTPUT="${OUTPUT:-$ROOT/dist/Formula/cleanroom.rb}"

if [[ ! -f "$ARCHIVE" ]]; then
  "$ROOT/scripts/package.sh" >/dev/null
fi

[[ -f "$ARCHIVE" ]] || { printf 'missing archive: %s\n' "$ARCHIVE" >&2; exit 1; }
[[ -f "$TEMPLATE" ]] || { printf 'missing template: %s\n' "$TEMPLATE" >&2; exit 1; }

SHA256="$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')"
mkdir -p "$(dirname "$OUTPUT")"

sed \
  -e "s/@VERSION@/$VERSION/g" \
  -e "s/@SHA256@/$SHA256/g" \
  "$TEMPLATE" >"$OUTPUT"

printf '%s\n' "$OUTPUT"
