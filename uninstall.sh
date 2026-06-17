#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
MANDIR="${MANDIR:-$PREFIX/share/man/man1}"
ZSH_COMPLETION_DIR="${ZSH_COMPLETION_DIR:-$PREFIX/share/zsh/site-functions}"
DATADIR="${DATADIR:-$PREFIX/share/cleanroom}"

rm -f "$BINDIR/cleanroom"
rm -f "$MANDIR/cleanroom.1"
rm -f "$ZSH_COMPLETION_DIR/_cleanroom"
rm -f "$DATADIR/data/cleanup-rules.tsv"
rm -f "$DATADIR/data/protected-paths.tsv"
rmdir "$DATADIR/data" "$DATADIR" 2>/dev/null || true

echo "Removed cleanroom from $PREFIX"
