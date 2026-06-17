#!/usr/bin/env bash
set -euo pipefail

PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
MANDIR="${MANDIR:-$PREFIX/share/man/man1}"
ZSH_COMPLETION_DIR="${ZSH_COMPLETION_DIR:-$PREFIX/share/zsh/site-functions}"

rm -f "$BINDIR/cleanroom"
rm -f "$MANDIR/cleanroom.1"
rm -f "$ZSH_COMPLETION_DIR/_cleanroom"

echo "Removed cleanroom from $PREFIX"
