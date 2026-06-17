#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
MANDIR="${MANDIR:-$PREFIX/share/man/man1}"
ZSH_COMPLETION_DIR="${ZSH_COMPLETION_DIR:-$PREFIX/share/zsh/site-functions}"
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$BINDIR/cleanroom"

install -d "$BINDIR"
install -d "$MANDIR"
install -d "$ZSH_COMPLETION_DIR"

install -m 0755 "$SOURCE_DIR/bin/cleanroom" "$TARGET"
install -m 0644 "$SOURCE_DIR/man/cleanroom.1" "$MANDIR/cleanroom.1"
install -m 0644 "$SOURCE_DIR/completions/_cleanroom" "$ZSH_COMPLETION_DIR/_cleanroom"

echo "Installed cleanroom to $TARGET"
echo "Installed man page to $MANDIR/cleanroom.1"
echo "Installed zsh completion to $ZSH_COMPLETION_DIR/_cleanroom"
echo "Try: cleanroom scan"
