#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="$(tr -d '[:space:]' <"$ROOT/VERSION")"
DIST_DIR="${DIST_DIR:-$ROOT/dist}"
APP_DIR="$DIST_DIR/Cleanroom.app"
CONTENTS="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

"$ROOT/scripts/check-version.sh" >/dev/null

rm -rf "$APP_DIR" "$DIST_DIR/Cleanroom.app.zip"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR/bin"
mkdir -p "$RESOURCES_DIR/data"

swiftc \
  -O \
  -framework AppKit \
  "$ROOT/macos/CleanroomApp/main.swift" \
  -o "$MACOS_DIR/Cleanroom"

cp "$ROOT/macos/CleanroomApp/Info.plist" "$CONTENTS/Info.plist"
cp "$ROOT/bin/cleanroom" "$RESOURCES_DIR/bin/cleanroom"
cp "$ROOT/data/cleanup-rules.tsv" "$RESOURCES_DIR/data/cleanup-rules.tsv"
chmod +x "$MACOS_DIR/Cleanroom" "$RESOURCES_DIR/bin/cleanroom"

/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" "$CONTENTS/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $VERSION" "$CONTENTS/Info.plist"

if command -v codesign >/dev/null 2>&1; then
  codesign --force --sign - --deep "$APP_DIR" >/dev/null
fi

(cd "$DIST_DIR" && zip -qry "Cleanroom.app.zip" "Cleanroom.app")
(cd "$DIST_DIR" && shasum -a 256 "Cleanroom.app.zip" >"Cleanroom.app.zip.sha256")

printf '%s\n' "$APP_DIR"
printf '%s\n' "$DIST_DIR/Cleanroom.app.zip"
