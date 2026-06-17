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
  "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache" \
  "$TEST_HOME/Library/Keychains" \
  "$TEST_HOME/.npm/_cacache" \
  "$TEST_HOME/.cache" \
  "$TEST_HOME/.lmstudio/models" \
  "$TEST_HOME/Applications/FakeBig.app/Contents/MacOS" \
  "$TEST_HOME/Downloads" \
  "$TEST_HOME/Documents/duplicates" \
  "$TEST_HOME/Documents/example/node_modules"

printf 'cache\n' >"$TEST_HOME/Library/Caches/example.cache"
printf 'log\n' >"$TEST_HOME/Library/Logs/example.log"
printf 'model\n' >"$TEST_HOME/.lmstudio/models/example.gguf"
printf 'login data\n' >"$TEST_HOME/Library/Application Support/Google/Chrome/Default/Login Data"
printf 'browser cache\n' >"$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache/example.cache"
printf 'keychain\n' >"$TEST_HOME/Library/Keychains/login.keychain-db"
dd if=/dev/zero of="$TEST_HOME/Downloads/big-test.bin" bs=1024 count=2048 >/dev/null 2>&1
dd if=/dev/zero of="$TEST_HOME/Documents/duplicates/copy-a.bin" bs=1024 count=2048 >/dev/null 2>&1
cp "$TEST_HOME/Documents/duplicates/copy-a.bin" "$TEST_HOME/Documents/duplicates/copy-b.bin"
dd if=/dev/zero of="$TEST_HOME/Applications/FakeBig.app/Contents/MacOS/fake" bs=1024 count=2048 >/dev/null 2>&1
export HOME="$TEST_HOME"

bash -n "$BIN"

"$BIN" --version | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null
"$BIN" help | grep 'safe macOS storage cleaner' >/dev/null
"$BIN" categories | grep -- '--include-ai-models' >/dev/null
"$BIN" categories | grep -- '--trash' >/dev/null
"$BIN" rules | grep 'safe-app-caches' >/dev/null
rules_json="$(mktemp)"
"$BIN" rules --json > "$rules_json"
python3 -m json.tool "$rules_json" >/dev/null
grep 'ai-models' "$rules_json" >/dev/null
rm -f "$rules_json"
"$BIN" plan | grep 'cleanroom plan' >/dev/null
plan_json="$(mktemp)"
"$BIN" plan --json > "$plan_json"
python3 -m json.tool "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash' "$plan_json" >/dev/null
rm -f "$plan_json"
"$BIN" large "$HOME/Downloads" --min-mb 1 --limit 5 | grep 'big-test.bin' >/dev/null
large_json="$(mktemp)"
"$BIN" large --json "$HOME/Downloads" --min-mb 1 --limit 5 > "$large_json"
python3 -m json.tool "$large_json" >/dev/null
grep 'big-test.bin' "$large_json" >/dev/null
rm -f "$large_json"
"$BIN" duplicates "$HOME/Documents" --min-mb 1 --limit 5 | grep 'copy-a.bin' >/dev/null
"$BIN" duplicates "$HOME/Documents" --min-mb 1 --limit 5 | grep 'copy-b.bin' >/dev/null
duplicates_json="$(mktemp)"
"$BIN" duplicates --json "$HOME/Documents" --min-mb 1 --limit 5 > "$duplicates_json"
python3 -m json.tool "$duplicates_json" >/dev/null
grep 'potential_reclaim_kb' "$duplicates_json" >/dev/null
grep 'copy-b.bin' "$duplicates_json" >/dev/null
rm -f "$duplicates_json"
"$BIN" apps "$HOME/Applications" --limit 5 | grep 'FakeBig' >/dev/null
apps_json="$(mktemp)"
"$BIN" apps --json "$HOME/Applications" --limit 5 > "$apps_json"
python3 -m json.tool "$apps_json" >/dev/null
grep 'FakeBig' "$apps_json" >/dev/null
rm -f "$apps_json"
"$BIN" doctor | grep 'cleanroom doctor' >/dev/null
"$BIN" doctor | grep 'cleanroom protect' >/dev/null
"$BIN" protect | grep 'chrome-login-data' >/dev/null
protect_json="$(mktemp)"
"$BIN" protect --json > "$protect_json"
python3 -m json.tool "$protect_json" >/dev/null
grep '"status":"present"' "$protect_json" >/dev/null
grep 'chrome-login-data' "$protect_json" >/dev/null
rm -f "$protect_json"
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome/Default" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome/Default/Login Data" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome/Default/Cache" | grep 'allowed' >/dev/null
guard_json="$(mktemp)"
"$BIN" guard --json "$HOME/Library/Application Support/Google/Chrome" "$HOME/Library/Application Support/Google/Chrome/Default/Cache" > "$guard_json"
python3 -m json.tool "$guard_json" >/dev/null
grep '"status":"refused-protected"' "$guard_json" >/dev/null
grep '"status":"allowed"' "$guard_json" >/dev/null
rm -f "$guard_json"
"$BIN" history 2>&1 | grep 'No cleanroom history found' >/dev/null

config_file="$(mktemp)"
rm -f "$config_file"
"$BIN" init-config --config "$config_file" --yes >/dev/null
grep '^preset=dev' "$config_file" >/dev/null
"$BIN" doctor --config "$config_file" | grep "$config_file" >/dev/null

report_stdout="$("$BIN" report)"
grep '# cleanroom report' <<<"$report_stdout" >/dev/null
grep 'Cleanup Candidates' <<<"$report_stdout" >/dev/null
grep 'Protected Personal Data' <<<"$report_stdout" >/dev/null

report_file="$(mktemp)"
"$BIN" report --output "$report_file" >/dev/null
grep '# cleanroom report' "$report_file" >/dev/null
grep 'chrome-login-data' "$report_file" >/dev/null
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

apply_log="$(mktemp)"
rm -f "$apply_log"
PATH="/usr/bin:/bin:/usr/sbin:/sbin" "$BIN" clean --apply --trash --yes --log "$apply_log" >/dev/null 2>&1
grep 'mode=trash' "$apply_log" >/dev/null
grep 'trash	ok' "$apply_log" >/dev/null
test ! -e "$HOME/.npm/_cacache"
find "$HOME/.Trash" -name _cacache -print -quit | grep _cacache >/dev/null
restore_preview="$("$BIN" restore --log "$apply_log" 2>&1)"
grep 'Restore dry-run mode' <<<"$restore_preview" >/dev/null
grep 'would restore' <<<"$restore_preview" >/dev/null
"$BIN" restore --log "$apply_log" --apply --yes >/dev/null 2>&1
test -e "$HOME/.npm/_cacache"

mkdir -p "$HOME/.npm/_cacache"
printf 'cache again\n' >"$HOME/.npm/_cacache/example.cache"
PATH="/usr/bin:/bin:/usr/sbin:/sbin" "$BIN" clean --apply --trash --yes >/dev/null 2>&1
"$BIN" history --limit 1 | grep 'trash_entries=' >/dev/null
"$BIN" restore --apply --yes >/dev/null 2>&1
test -e "$HOME/.npm/_cacache"
rm -f "$apply_log"

rm -f "$config_file"

echo "smoke tests passed"
