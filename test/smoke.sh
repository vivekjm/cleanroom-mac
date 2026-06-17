#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT/bin/cleanroom"
TEST_HOME="$(mktemp -d)"

cleanup() {
  rm -rf "$TEST_HOME"
}
trap cleanup EXIT

mkdir -p \
  "$TEST_HOME/Library/Caches" \
  "$TEST_HOME/Library/Logs" \
  "$TEST_HOME/Library/Developer/Xcode/DerivedData" \
  "$TEST_HOME/Library/Application Support/Google/Chrome/Default" \
  "$TEST_HOME/.npm/_cacache" \
  "$TEST_HOME/.cache" \
  "$TEST_HOME/.lmstudio/models" \
  "$TEST_HOME/Documents/example/node_modules"

printf 'cache\n' >"$TEST_HOME/Library/Caches/example.cache"
printf 'log\n' >"$TEST_HOME/Library/Logs/example.log"
printf 'model\n' >"$TEST_HOME/.lmstudio/models/example.gguf"
export HOME="$TEST_HOME"

bash -n "$BIN"

"$BIN" --version | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null
"$BIN" help | grep 'safe macOS storage cleaner' >/dev/null
"$BIN" categories | grep -- '--include-ai-models' >/dev/null
"$BIN" doctor | grep 'cleanroom doctor' >/dev/null

config_file="$(mktemp)"
rm -f "$config_file"
"$BIN" init-config --config "$config_file" --yes >/dev/null
grep '^preset=dev' "$config_file" >/dev/null
"$BIN" doctor --config "$config_file" | grep "$config_file" >/dev/null

report_stdout="$("$BIN" report)"
grep '# cleanroom report' <<<"$report_stdout" >/dev/null
grep 'Cleanup Candidates' <<<"$report_stdout" >/dev/null

report_file="$(mktemp)"
"$BIN" report --output "$report_file" >/dev/null
grep '# cleanroom report' "$report_file" >/dev/null
rm -f "$report_file"

json_file="$(mktemp)"
"$BIN" scan --json > "$json_file"
python3 -m json.tool "$json_file" >/dev/null
rm -f "$json_file"

dry_run_output="$("$BIN" clean --preset dev 2>&1)"
grep 'Dry-run mode' <<<"$dry_run_output" >/dev/null

deep_output="$("$BIN" clean --include-ai-workspaces --include-ai-models --include-containers 2>&1)"
grep 'Dry-run mode' <<<"$deep_output" >/dev/null

excluded_output="$("$BIN" clean --include-ai-models --exclude "$HOME/.lmstudio" 2>&1)"
grep 'Dry-run mode' <<<"$excluded_output" >/dev/null

rm -f "$config_file"

echo "smoke tests passed"
