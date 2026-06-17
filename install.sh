#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local/bin}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$PREFIX/cleanroom"

if [[ ! -d "$PREFIX" ]]; then
  echo "Creating $PREFIX"
  mkdir -p "$PREFIX"
fi

install -m 0755 "$SOURCE_DIR/bin/cleanroom" "$TARGET"
echo "Installed cleanroom to $TARGET"
echo "Try: cleanroom scan"
