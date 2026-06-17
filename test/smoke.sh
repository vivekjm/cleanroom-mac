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
  "$TEST_HOME/Library/LaunchAgents" \
  "$TEST_HOME/Library/Logs" \
  "$TEST_HOME/Library/Developer/Xcode/DerivedData" \
  "$TEST_HOME/Library/Developer/Xcode/Archives/2026-06-01/FakeApp.xcarchive" \
  "$TEST_HOME/Library/Developer/Xcode/iOS DeviceSupport/18.0" \
  "$TEST_HOME/Library/Developer/CoreSimulator/Caches" \
  "$TEST_HOME/Library/Developer/CoreSimulator/Devices/FakeSimulator/data" \
  "$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup" \
  "$TEST_HOME/Library/Application Support/Google/Chrome/Default" \
  "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache" \
  "$TEST_HOME/Library/Application Support/CleanroomTestAdobe/Creative Cloud" \
  "$TEST_HOME/Library/Caches/com.cleanroomtestadobe.acc" \
  "$TEST_HOME/Library/Preferences" \
  "$TEST_HOME/Library/Keychains" \
  "$TEST_HOME/.npm/_cacache" \
  "$TEST_HOME/Library/pnpm/store" \
  "$TEST_HOME/.cache" \
  "$TEST_HOME/.lmstudio/models" \
  "$TEST_HOME/.Trash" \
  "$TEST_HOME/Applications/FakeBig.app/Contents/MacOS" \
  "$TEST_HOME/Downloads" \
  "$TEST_HOME/Documents/duplicates" \
  "$TEST_HOME/Documents/example/node_modules"

printf 'cache\n' >"$TEST_HOME/Library/Caches/example.cache"
printf 'pnpm\n' >"$TEST_HOME/Library/pnpm/store/example"
printf 'log\n' >"$TEST_HOME/Library/Logs/example.log"
printf 'derived data\n' >"$TEST_HOME/Library/Developer/Xcode/DerivedData/build.db"
printf 'archive\n' >"$TEST_HOME/Library/Developer/Xcode/Archives/2026-06-01/FakeApp.xcarchive/Info.plist"
printf 'support\n' >"$TEST_HOME/Library/Developer/Xcode/iOS DeviceSupport/18.0/Symbols"
printf 'sim cache\n' >"$TEST_HOME/Library/Developer/CoreSimulator/Caches/cache.db"
printf 'sim data\n' >"$TEST_HOME/Library/Developer/CoreSimulator/Devices/FakeSimulator/data/app.db"
printf 'model\n' >"$TEST_HOME/.lmstudio/models/example.gguf"
printf 'login data\n' >"$TEST_HOME/Library/Application Support/Google/Chrome/Default/Login Data"
printf 'browser cache\n' >"$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache/example.cache"
printf 'adobe support\n' >"$TEST_HOME/Library/Application Support/CleanroomTestAdobe/Creative Cloud/state.db"
printf 'adobe cache\n' >"$TEST_HOME/Library/Caches/com.cleanroomtestadobe.acc/cache.bin"
printf 'adobe prefs\n' >"$TEST_HOME/Library/Preferences/com.cleanroomtestadobe.acc.plist"
printf 'keychain\n' >"$TEST_HOME/Library/Keychains/login.keychain-db"
printf 'trashed\n' >"$TEST_HOME/.Trash/old-trash.txt"
printf 'old dependency\n' >"$TEST_HOME/Documents/example/node_modules/package.txt"
touch -t 202001010000 "$TEST_HOME/Documents/example/node_modules" "$TEST_HOME/Documents/example/node_modules/package.txt"
cat >"$TEST_HOME/Library/LaunchAgents/com.example.cleanroom-test.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.example.cleanroom-test</string>
  <key>Program</key>
  <string>/usr/bin/true</string>
</dict>
</plist>
PLIST
cat >"$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Device Name</key>
  <string>Vivek Test iPhone</string>
  <key>Product Name</key>
  <string>iPhone</string>
  <key>Last Backup Date</key>
  <date>2026-06-01T10:00:00Z</date>
</dict>
</plist>
PLIST
dd if=/dev/zero of="$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup/Manifest.db" bs=1024 count=1024 >/dev/null 2>&1
dd if=/dev/zero of="$TEST_HOME/Downloads/big-test.bin" bs=1024 count=2048 >/dev/null 2>&1
dd if=/dev/zero of="$TEST_HOME/Downloads/old-installer.dmg" bs=1024 count=1024 >/dev/null 2>&1
touch -t 202001010000 "$TEST_HOME/Downloads/old-installer.dmg"
dd if=/dev/zero of="$TEST_HOME/Downloads/old-package.pkg" bs=1024 count=1024 >/dev/null 2>&1
touch -t 202001010000 "$TEST_HOME/Downloads/old-package.pkg"
dd if=/dev/zero of="$TEST_HOME/Documents/duplicates/copy-a.bin" bs=1024 count=2048 >/dev/null 2>&1
cp "$TEST_HOME/Documents/duplicates/copy-a.bin" "$TEST_HOME/Documents/duplicates/copy-b.bin"
dd if=/dev/zero of="$TEST_HOME/Applications/FakeBig.app/Contents/MacOS/fake" bs=1024 count=2048 >/dev/null 2>&1
export HOME="$TEST_HOME"

bash -n "$BIN"

"$BIN" --version | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null
"$BIN" help | grep 'safe macOS storage cleaner' >/dev/null
"$BIN" categories | grep -- '--include-ai-models' >/dev/null
"$BIN" categories | grep -- '--trash' >/dev/null
"$BIN" overview | grep 'cleanroom overview' >/dev/null
overview_json="$(mktemp)"
"$BIN" overview --json > "$overview_json"
python3 -m json.tool "$overview_json" >/dev/null
grep '"summary"' "$overview_json" >/dev/null
grep '"recommendations"' "$overview_json" >/dev/null
rm -f "$overview_json"
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
"$BIN" downloads --days 30 --limit 5 | grep 'old-installer.dmg' >/dev/null
downloads_json="$(mktemp)"
"$BIN" downloads --json --days 30 --limit 5 > "$downloads_json"
python3 -m json.tool "$downloads_json" >/dev/null
grep 'old-installer.dmg' "$downloads_json" >/dev/null
grep '"age_days"' "$downloads_json" >/dev/null
rm -f "$downloads_json"
"$BIN" installers --days 30 --limit 5 | grep 'old-installer.dmg' >/dev/null
installers_json="$(mktemp)"
"$BIN" installers --json --days 30 --limit 5 > "$installers_json"
python3 -m json.tool "$installers_json" >/dev/null
grep 'old-package.pkg' "$installers_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-installers --days 30' "$installers_json" >/dev/null
rm -f "$installers_json"
"$BIN" nodes "$HOME/Documents" --days 30 --limit 5 | grep 'node_modules' >/dev/null
nodes_json="$(mktemp)"
"$BIN" nodes --json "$HOME/Documents" --days 30 --limit 5 > "$nodes_json"
python3 -m json.tool "$nodes_json" >/dev/null
grep 'node_modules' "$nodes_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-node-stale --days 30' "$nodes_json" >/dev/null
rm -f "$nodes_json"
"$BIN" apps "$HOME/Applications" --limit 5 | grep 'FakeBig' >/dev/null
apps_json="$(mktemp)"
"$BIN" apps --json "$HOME/Applications" --limit 5 > "$apps_json"
python3 -m json.tool "$apps_json" >/dev/null
grep 'FakeBig' "$apps_json" >/dev/null
rm -f "$apps_json"
"$BIN" browsers | grep 'Google Chrome' >/dev/null
"$BIN" browsers | grep 'protected' >/dev/null
browsers_json="$(mktemp)"
"$BIN" browsers --json > "$browsers_json"
python3 -m json.tool "$browsers_json" >/dev/null
grep 'Google Chrome' "$browsers_json" >/dev/null
grep '"protected":true' "$browsers_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-app-caches' "$browsers_json" >/dev/null
rm -f "$browsers_json"
"$BIN" leftovers cleanroomtestadobe --limit 10 | grep 'com.cleanroomtestadobe.acc' >/dev/null
leftovers_json="$(mktemp)"
"$BIN" leftovers cleanroomtestadobe --json --limit 10 > "$leftovers_json"
python3 -m json.tool "$leftovers_json" >/dev/null
grep '"queries"' "$leftovers_json" >/dev/null
grep 'com.cleanroomtestadobe.acc' "$leftovers_json" >/dev/null
grep '"category":"preferences"' "$leftovers_json" >/dev/null
rm -f "$leftovers_json"
"$BIN" backups | grep 'Vivek Test iPhone' >/dev/null
backups_json="$(mktemp)"
"$BIN" backups --json > "$backups_json"
python3 -m json.tool "$backups_json" >/dev/null
grep 'Vivek Test iPhone' "$backups_json" >/dev/null
grep '"protected":true' "$backups_json" >/dev/null
rm -f "$backups_json"
"$BIN" xcode | grep 'Xcode Archives' >/dev/null
xcode_json="$(mktemp)"
"$BIN" xcode --json > "$xcode_json"
python3 -m json.tool "$xcode_json" >/dev/null
grep '"id":"xcode-archives"' "$xcode_json" >/dev/null
grep '"safety":"review-only"' "$xcode_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-dev-heavy' "$xcode_json" >/dev/null
rm -f "$xcode_json"
"$BIN" startup | grep 'com.example.cleanroom-test' >/dev/null
startup_json="$(mktemp)"
"$BIN" startup --json > "$startup_json"
python3 -m json.tool "$startup_json" >/dev/null
grep 'com.example.cleanroom-test' "$startup_json" >/dev/null
grep '"type":"LaunchAgent"' "$startup_json" >/dev/null
rm -f "$startup_json"
"$BIN" trash | grep 'old-trash.txt' >/dev/null
trash_json="$(mktemp)"
"$BIN" trash --json > "$trash_json"
python3 -m json.tool "$trash_json" >/dev/null
grep 'old-trash.txt' "$trash_json" >/dev/null
rm -f "$trash_json"
"$BIN" packages | grep 'pnpm-store' >/dev/null
packages_json="$(mktemp)"
"$BIN" packages --json > "$packages_json"
python3 -m json.tool "$packages_json" >/dev/null
grep 'pnpm-store' "$packages_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-package-stores' "$packages_json" >/dev/null
rm -f "$packages_json"
"$BIN" caches | grep 'user-caches' >/dev/null
caches_json="$(mktemp)"
"$BIN" caches --json > "$caches_json"
python3 -m json.tool "$caches_json" >/dev/null
grep 'safe-app-caches' "$caches_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-app-caches' "$caches_json" >/dev/null
rm -f "$caches_json"
"$BIN" snapshots | grep 'cleanroom local snapshots' >/dev/null
snapshots_json="$(mktemp)"
"$BIN" snapshots --json > "$snapshots_json"
python3 -m json.tool "$snapshots_json" >/dev/null
rm -f "$snapshots_json"
"$BIN" doctor | grep 'cleanroom doctor' >/dev/null
"$BIN" doctor | grep 'cleanroom protect' >/dev/null
doctor_json="$(mktemp)"
"$BIN" doctor --json > "$doctor_json"
python3 -m json.tool "$doctor_json" >/dev/null
grep '"tools"' "$doctor_json" >/dev/null
grep '"safety"' "$doctor_json" >/dev/null
rm -f "$doctor_json"
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
"$BIN" guard "$HOME/Library/Application Support/MobileSync/Backup" | grep 'refused-protected' >/dev/null
guard_json="$(mktemp)"
"$BIN" guard --json "$HOME/Library/Application Support/Google/Chrome" "$HOME/Library/Application Support/Google/Chrome/Default/Cache" "$HOME/Library/Application Support/MobileSync/Backup" > "$guard_json"
python3 -m json.tool "$guard_json" >/dev/null
grep '"status":"refused-protected"' "$guard_json" >/dev/null
grep '"status":"allowed"' "$guard_json" >/dev/null
grep 'MobileSync' "$guard_json" >/dev/null
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

trash_dry_output="$("$BIN" clean --include-user-trash 2>&1)"
grep 'Dry-run mode' <<<"$trash_dry_output" >/dev/null
grep '.Trash' <<<"$trash_dry_output" >/dev/null

trash_log="$(mktemp)"
rm -f "$trash_log"
"$BIN" clean --include-user-trash --apply --yes --log "$trash_log" >/dev/null 2>&1
grep 'empty-trash	ok' "$trash_log" >/dev/null
test ! -e "$HOME/.Trash/old-trash.txt"
rm -f "$trash_log"
mkdir -p "$HOME/.npm/_cacache"
printf 'cache again\n' >"$HOME/.npm/_cacache/example.cache"
printf 'trashed again\n' >"$HOME/.Trash/old-trash.txt"
dd if=/dev/zero of="$HOME/Downloads/old-installer.dmg" bs=1024 count=1024 >/dev/null 2>&1
touch -t 202001010000 "$HOME/Downloads/old-installer.dmg"

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

installer_log="$(mktemp)"
rm -f "$installer_log"
"$BIN" clean --include-installers --days 30 --apply --trash --yes --log "$installer_log" >/dev/null 2>&1
grep 'old-package.pkg' "$installer_log" >/dev/null
test ! -e "$HOME/Downloads/old-package.pkg"
find "$HOME/.Trash" -name old-package.pkg -print -quit | grep old-package.pkg >/dev/null
rm -f "$installer_log"

mkdir -p "$HOME/.npm/_cacache"
printf 'cache again\n' >"$HOME/.npm/_cacache/example.cache"
PATH="/usr/bin:/bin:/usr/sbin:/sbin" "$BIN" clean --apply --trash --yes >/dev/null 2>&1
"$BIN" history --limit 1 | grep 'trash_entries=' >/dev/null
"$BIN" restore --apply --yes >/dev/null 2>&1
test -e "$HOME/.npm/_cacache"
rm -f "$apply_log"

rm -f "$config_file"

echo "smoke tests passed"
