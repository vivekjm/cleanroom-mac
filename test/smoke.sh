#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT/bin/cleanroom"

bash -n "$BIN"

"$BIN" --version | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null
"$BIN" help | grep 'safe macOS storage cleaner' >/dev/null
"$BIN" categories | grep -- '--include-ai-models' >/dev/null
"$BIN" doctor | grep 'cleanroom doctor' >/dev/null

json_file="$(mktemp)"
"$BIN" scan --json > "$json_file"
python3 -m json.tool "$json_file" >/dev/null
rm -f "$json_file"

dry_run_output="$("$BIN" clean --preset dev 2>&1)"
grep 'Dry-run mode' <<<"$dry_run_output" >/dev/null

deep_output="$("$BIN" clean --include-ai-workspaces --include-ai-models --include-containers 2>&1)"
grep 'Dry-run mode' <<<"$deep_output" >/dev/null

echo "smoke tests passed"
