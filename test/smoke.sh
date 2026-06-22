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
  "$TEST_HOME/Library/Caches/go-build" \
  "$TEST_HOME/go/pkg/mod" \
  "$TEST_HOME/Library/Caches/pip" \
  "$TEST_HOME/.cache/uv" \
  "$TEST_HOME/Library/Caches/pypoetry" \
  "$TEST_HOME/Library/Caches/org.swift.swiftpm" \
  "$TEST_HOME/.m2/repository" \
  "$TEST_HOME/Library/Caches/composer" \
  "$TEST_HOME/Library/Caches/Homebrew" \
  "$TEST_HOME/Library/Caches/com.apple.QuickLook.thumbnailcache" \
  "$TEST_HOME/Library/Caches/com.apple.quicklook.ThumbnailsAgent" \
  "$TEST_HOME/Library/Caches/com.apple.QuickLookDaemon" \
  "$TEST_HOME/Library/Caches/com.apple.ATS/User" \
  "$TEST_HOME/Library/Caches/com.apple.FontRegistry" \
  "$TEST_HOME/Library/Caches/com.apple.FontWorker" \
  "$TEST_HOME/Library/Caches/com.apple.FontServices" \
  "$TEST_HOME/Library/Caches/com.apple.Safari" \
  "$TEST_HOME/Library/Caches/com.apple.WebKit.Networking" \
  "$TEST_HOME/Library/Caches/com.apple.WebKit.WebContent" \
  "$TEST_HOME/Library/Caches/Firefox" \
  "$TEST_HOME/Library/Caches/org.mozilla.firefox" \
  "$TEST_HOME/Library/Caches/Sparkle" \
  "$TEST_HOME/Library/Caches/com.github.Squirrel.ShipIt" \
  "$TEST_HOME/Library/Application Support/com.github.Squirrel.ShipIt" \
  "$TEST_HOME/Library/Containers/com.apple.QuickLook.thumbnailcache/Data/Library/Caches" \
  "$TEST_HOME/Library/Containers/com.apple.quicklook.ThumbnailsAgent/Data/Library/Caches" \
  "$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/Caches" \
  "$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/WebKit/NetworkCache" \
  "$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/Safari" \
  "$TEST_HOME/Library/Logs/Homebrew" \
  "$TEST_HOME/Library/Saved Application State/com.example.Test.savedState" \
  "$TEST_HOME/Library/Receipts" \
  "$TEST_HOME/.bundle/cache" \
  "$TEST_HOME/Library/DiagnosticReports" \
  "$TEST_HOME/Library/Application Support/CrashReporter" \
  "$TEST_HOME/Library/LaunchAgents" \
  "$TEST_HOME/Library/Logs" \
  "$TEST_HOME/Library/Developer/Xcode/DerivedData" \
  "$TEST_HOME/Library/Developer/Xcode/Archives/2026-06-01/FakeApp.xcarchive" \
  "$TEST_HOME/Library/Developer/Xcode/iOS DeviceSupport/18.0" \
  "$TEST_HOME/Library/Developer/CoreSimulator/Caches" \
  "$TEST_HOME/Library/Developer/CoreSimulator/Devices/FakeSimulator/data" \
  "$TEST_HOME/Library/Android/sdk/ndk/25.2.9519653" \
  "$TEST_HOME/Library/Android/sdk/system-images/android-35/google_apis/arm64-v8a" \
  "$TEST_HOME/Library/Android/sdk/.downloadIntermediates" \
  "$TEST_HOME/Library/Android/sdk/.temp" \
  "$TEST_HOME/Library/Android/sdk/emulator" \
  "$TEST_HOME/Library/Android/sdk/platforms/android-35" \
  "$TEST_HOME/Library/Android/sdk/build-tools/35.0.0" \
  "$TEST_HOME/Library/Android/sdk/platform-tools" \
  "$TEST_HOME/Library/Android/sdk/cmdline-tools/latest/bin" \
  "$TEST_HOME/.android/avd/Test.avd" \
  "$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup" \
  "$TEST_HOME/Library/Application Support/Google/Chrome/Default" \
  "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache" \
  "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Code Cache" \
  "$TEST_HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/GPUCache" \
  "$TEST_HOME/Library/Application Support/AddressBook" \
  "$TEST_HOME/Library/Application Support/CallHistoryDB" \
  "$TEST_HOME/Library/Application Support/CleanroomTestAdobe/Creative Cloud" \
  "$TEST_HOME/Library/Caches/com.cleanroomtestadobe.acc" \
  "$TEST_HOME/Library/Preferences" \
  "$TEST_HOME/Library/Keychains" \
  "$TEST_HOME/Library/Safari" \
  "$TEST_HOME/Library/Mail" \
  "$TEST_HOME/Library/Mail Downloads" \
  "$TEST_HOME/Library/Containers/com.apple.mail/Data/Library/Mail Downloads" \
  "$TEST_HOME/Library/Messages" \
  "$TEST_HOME/Library/Messages/Attachments" \
  "$TEST_HOME/Library/Calendars" \
  "$TEST_HOME/Library/Group Containers/group.com.apple.notes" \
  "$TEST_HOME/Library/Group Containers/group.com.apple.reminders" \
  "$TEST_HOME/Library/Group Containers/group.com.apple.VoiceMemos.shared" \
  "$TEST_HOME/Library/Mobile Documents" \
  "$TEST_HOME/Library/CloudStorage/Dropbox-Test" \
  "$TEST_HOME/Dropbox" \
  "$TEST_HOME/Sync" \
  "$TEST_HOME/Pictures/Photos Library.photoslibrary" \
  "$TEST_HOME/Music/Music Library.musiclibrary" \
  "$TEST_HOME/Movies/iMovie Library.imovielibrary" \
  "$TEST_HOME/Music/GarageBand" \
  "$TEST_HOME/.npm/_cacache" \
  "$TEST_HOME/Library/pnpm/store" \
  "$TEST_HOME/.cache" \
  "$TEST_HOME/.lmstudio/models" \
  "$TEST_HOME/.colima/default" \
  "$TEST_HOME/.lima/default" \
  "$TEST_HOME/.local/share/containers/storage" \
  "$TEST_HOME/.local/share/podman" \
  "$TEST_HOME/Library/Containers/com.docker.docker/Data/vms/0" \
  "$TEST_HOME/Library/Containers/io.podman_desktop.PodmanDesktop/Data" \
  "$TEST_HOME/.Trash" \
  "$TEST_HOME/.Trash/cleanroom-test-run" \
  "$TEST_HOME/Applications/FakeBig.app/Contents/MacOS" \
  "$TEST_HOME/Applications/Cleanroom Test Uninstaller.app/Contents/MacOS" \
  "$TEST_HOME/Applications/Cleanroom Login Helper.app/Contents/MacOS" \
  "$TEST_HOME/bin" \
  "$TEST_HOME/Desktop" \
  "$TEST_HOME/Downloads" \
  "$TEST_HOME/Documents/duplicates" \
  "$TEST_HOME/Documents/media-project" \
  "$TEST_HOME/Documents/example/node_modules" \
  "$TEST_HOME/Documents/python-cache-project/pkg/__pycache__" \
  "$TEST_HOME/Documents/python-cache-project/.pytest_cache" \
  "$TEST_HOME/Documents/python-cache-project/.mypy_cache" \
  "$TEST_HOME/Documents/python-cache-project/.ruff_cache" \
  "$TEST_HOME/Documents/python-cache-project/.tox" \
  "$TEST_HOME/Documents/python-cache-project/.nox" \
  "$TEST_HOME/Documents/python-cache-project/htmlcov" \
  "$TEST_HOME/Documents/python-cache-project/node_modules/__pycache__" \
  "$TEST_HOME/Documents/python-app/.venv/bin"

printf 'cache\n' >"$TEST_HOME/Library/Caches/example.cache"
printf 'go build\n' >"$TEST_HOME/Library/Caches/go-build/cache.bin"
printf 'go module\n' >"$TEST_HOME/go/pkg/mod/example.mod"
printf 'pip cache\n' >"$TEST_HOME/Library/Caches/pip/http.cache"
printf 'uv cache\n' >"$TEST_HOME/.cache/uv/pkg.cache"
printf 'poetry cache\n' >"$TEST_HOME/Library/Caches/pypoetry/pkg.cache"
printf 'swiftpm cache\n' >"$TEST_HOME/Library/Caches/org.swift.swiftpm/pkg.cache"
printf 'maven cache\n' >"$TEST_HOME/.m2/repository/artifact.jar"
printf 'composer cache\n' >"$TEST_HOME/Library/Caches/composer/pkg.zip"
printf 'brew cache\n' >"$TEST_HOME/Library/Caches/Homebrew/bottle.tar.gz"
printf 'quicklook thumbnail\n' >"$TEST_HOME/Library/Caches/com.apple.QuickLook.thumbnailcache/thumb.db"
printf 'quicklook agent\n' >"$TEST_HOME/Library/Caches/com.apple.quicklook.ThumbnailsAgent/thumb.db"
printf 'quicklook daemon\n' >"$TEST_HOME/Library/Caches/com.apple.QuickLookDaemon/cache.db"
printf 'ats font cache\n' >"$TEST_HOME/Library/Caches/com.apple.ATS/User/annex.db"
printf 'font registry\n' >"$TEST_HOME/Library/Caches/com.apple.FontRegistry/registry.db"
printf 'font worker\n' >"$TEST_HOME/Library/Caches/com.apple.FontWorker/cache.db"
printf 'font services\n' >"$TEST_HOME/Library/Caches/com.apple.FontServices/cache.db"
printf 'safari cache\n' >"$TEST_HOME/Library/Caches/com.apple.Safari/cache.db"
printf 'webkit networking cache\n' >"$TEST_HOME/Library/Caches/com.apple.WebKit.Networking/cache.db"
printf 'webkit webcontent cache\n' >"$TEST_HOME/Library/Caches/com.apple.WebKit.WebContent/cache.db"
printf 'firefox cache\n' >"$TEST_HOME/Library/Caches/Firefox/cache2.db"
printf 'firefox org cache\n' >"$TEST_HOME/Library/Caches/org.mozilla.firefox/cache2.db"
printf 'quicklook container\n' >"$TEST_HOME/Library/Containers/com.apple.QuickLook.thumbnailcache/Data/Library/Caches/thumb.db"
printf 'quicklook agent container\n' >"$TEST_HOME/Library/Containers/com.apple.quicklook.ThumbnailsAgent/Data/Library/Caches/thumb.db"
printf 'safari container cache\n' >"$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/Caches/cache.db"
printf 'safari webkit cache\n' >"$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/WebKit/NetworkCache/cache.db"
printf 'safari container history\n' >"$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/Safari/History.db"
printf 'sparkle update\n' >"$TEST_HOME/Library/Caches/Sparkle/update.zip"
printf 'squirrel cache\n' >"$TEST_HOME/Library/Caches/com.github.Squirrel.ShipIt/update.nupkg"
printf 'squirrel staging\n' >"$TEST_HOME/Library/Application Support/com.github.Squirrel.ShipIt/staged-update"
printf 'saved state\n' >"$TEST_HOME/Library/Saved Application State/com.example.Test.savedState/window.plist"
printf 'brew log\n' >"$TEST_HOME/Library/Logs/Homebrew/build.log"
printf 'receipt plist\n' >"$TEST_HOME/Library/Receipts/com.cleanroom.test.pkg.plist"
printf 'receipt bom\n' >"$TEST_HOME/Library/Receipts/com.cleanroom.test.pkg.bom"
printf 'bundler cache\n' >"$TEST_HOME/.bundle/cache/gem.gem"
printf 'diagnostic\n' >"$TEST_HOME/Library/DiagnosticReports/OldApp.crash"
printf 'crash reporter\n' >"$TEST_HOME/Library/Application Support/CrashReporter/OldApp.plist"
printf 'pnpm\n' >"$TEST_HOME/Library/pnpm/store/example"
printf 'log\n' >"$TEST_HOME/Library/Logs/example.log"
printf 'derived data\n' >"$TEST_HOME/Library/Developer/Xcode/DerivedData/build.db"
printf 'archive\n' >"$TEST_HOME/Library/Developer/Xcode/Archives/2026-06-01/FakeApp.xcarchive/Info.plist"
printf 'support\n' >"$TEST_HOME/Library/Developer/Xcode/iOS DeviceSupport/18.0/Symbols"
printf 'sim cache\n' >"$TEST_HOME/Library/Developer/CoreSimulator/Caches/cache.db"
printf 'sim data\n' >"$TEST_HOME/Library/Developer/CoreSimulator/Devices/FakeSimulator/data/app.db"
printf 'ndk\n' >"$TEST_HOME/Library/Android/sdk/ndk/25.2.9519653/source.properties"
printf 'system image\n' >"$TEST_HOME/Library/Android/sdk/system-images/android-35/google_apis/arm64-v8a/system.img"
printf 'sdk temp\n' >"$TEST_HOME/Library/Android/sdk/.downloadIntermediates/package.zip"
printf 'sdk temp\n' >"$TEST_HOME/Library/Android/sdk/.temp/download.tmp"
printf 'emulator\n' >"$TEST_HOME/Library/Android/sdk/emulator/emulator"
printf 'android jar\n' >"$TEST_HOME/Library/Android/sdk/platforms/android-35/android.jar"
printf 'aapt\n' >"$TEST_HOME/Library/Android/sdk/build-tools/35.0.0/aapt"
printf 'adb\n' >"$TEST_HOME/Library/Android/sdk/platform-tools/adb"
printf 'sdkmanager\n' >"$TEST_HOME/Library/Android/sdk/cmdline-tools/latest/bin/sdkmanager"
printf 'avd\n' >"$TEST_HOME/.android/avd/Test.avd/userdata-qemu.img"
printf 'model\n' >"$TEST_HOME/.lmstudio/models/example.gguf"
printf 'colima disk\n' >"$TEST_HOME/.colima/default/disk.img"
printf 'lima disk\n' >"$TEST_HOME/.lima/default/disk.img"
printf 'podman image\n' >"$TEST_HOME/.local/share/containers/storage/image"
printf 'podman vm\n' >"$TEST_HOME/.local/share/podman/machine"
printf 'docker raw\n' >"$TEST_HOME/Library/Containers/com.docker.docker/Data/vms/0/Docker.raw"
printf 'podman desktop\n' >"$TEST_HOME/Library/Containers/io.podman_desktop.PodmanDesktop/Data/state.db"
printf 'login data\n' >"$TEST_HOME/Library/Application Support/Google/Chrome/Default/Login Data"
printf 'browser cache\n' >"$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache/example.cache"
printf 'browser code cache\n' >"$TEST_HOME/Library/Application Support/Google/Chrome/Default/Code Cache/code.cache"
printf 'brave gpu cache\n' >"$TEST_HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/GPUCache/gpu.cache"
printf 'contacts\n' >"$TEST_HOME/Library/Application Support/AddressBook/AddressBook-v22.abcddb"
printf 'call history\n' >"$TEST_HOME/Library/Application Support/CallHistoryDB/CallHistory.storedata"
printf 'adobe support\n' >"$TEST_HOME/Library/Application Support/CleanroomTestAdobe/Creative Cloud/state.db"
dd if=/dev/zero of="$TEST_HOME/Library/Application Support/CleanroomTestAdobe/Creative Cloud/blob.cache" bs=1024 count=64 >/dev/null 2>&1
printf 'adobe cache\n' >"$TEST_HOME/Library/Caches/com.cleanroomtestadobe.acc/cache.bin"
printf 'adobe prefs\n' >"$TEST_HOME/Library/Preferences/com.cleanroomtestadobe.acc.plist"
printf 'keychain\n' >"$TEST_HOME/Library/Keychains/login.keychain-db"
printf 'safari history\n' >"$TEST_HOME/Library/Safari/History.db"
printf 'safari bookmarks\n' >"$TEST_HOME/Library/Safari/Bookmarks.plist"
printf 'mail\n' >"$TEST_HOME/Library/Mail/envelope-index"
printf 'mail attachment\n' >"$TEST_HOME/Library/Mail Downloads/attachment.pdf"
printf 'container mail attachment\n' >"$TEST_HOME/Library/Containers/com.apple.mail/Data/Library/Mail Downloads/container-attachment.pdf"
printf 'message\n' >"$TEST_HOME/Library/Messages/chat.db"
printf 'message attachment\n' >"$TEST_HOME/Library/Messages/Attachments/photo.jpg"
printf 'calendar\n' >"$TEST_HOME/Library/Calendars/Calendar.sqlitedb"
printf 'note\n' >"$TEST_HOME/Library/Group Containers/group.com.apple.notes/NoteStore.sqlite"
printf 'reminder\n' >"$TEST_HOME/Library/Group Containers/group.com.apple.reminders/Container.sqlite"
printf 'voice memo\n' >"$TEST_HOME/Library/Group Containers/group.com.apple.VoiceMemos.shared/recording.m4a"
printf 'icloud doc\n' >"$TEST_HOME/Library/Mobile Documents/document.txt"
printf 'cloudstorage doc\n' >"$TEST_HOME/Library/CloudStorage/Dropbox-Test/document.txt"
dd if=/dev/zero of="$TEST_HOME/Library/CloudStorage/Dropbox-Test/big-cloud.bin" bs=1024 count=2048 >/dev/null 2>&1
printf 'dropbox doc\n' >"$TEST_HOME/Dropbox/document.txt"
printf 'sync doc\n' >"$TEST_HOME/Sync/document.txt"
printf 'photo library\n' >"$TEST_HOME/Pictures/Photos Library.photoslibrary/database"
printf 'music library\n' >"$TEST_HOME/Music/Music Library.musiclibrary/Library.musicdb"
printf 'imovie library\n' >"$TEST_HOME/Movies/iMovie Library.imovielibrary/CurrentVersion.flexolibrary"
printf 'garageband project\n' >"$TEST_HOME/Music/GarageBand/song.band"
printf 'trashed\n' >"$TEST_HOME/.Trash/old-trash.txt"
printf 'recoverable cleanroom trash\n' >"$TEST_HOME/.Trash/cleanroom-test-run/item.txt"
printf 'screenshot\n' >"$TEST_HOME/Desktop/Screenshot 2026-06-01 at 10.00.00 PM.png"
printf 'recording\n' >"$TEST_HOME/Downloads/Screen Recording 2026-06-01 at 10.00.00 PM.mov"
dd if=/dev/zero of="$TEST_HOME/Downloads/old-archive.zip" bs=1024 count=512 >/dev/null 2>&1
dd if=/dev/zero of="$TEST_HOME/Desktop/old-disk-image.dmg" bs=1024 count=512 >/dev/null 2>&1
printf 'document\n' >"$TEST_HOME/Documents/readme.txt"
printf 'finder metadata\n' >"$TEST_HOME/Documents/.DS_Store"
printf 'appledouble metadata\n' >"$TEST_HOME/Downloads/._old-installer.dmg"
printf 'windows metadata\n' >"$TEST_HOME/Desktop/Thumbs.db"
dd if=/dev/zero of="$TEST_HOME/Documents/media-project/clip.mov" bs=1024 count=64 >/dev/null 2>&1
printf 'old dependency\n' >"$TEST_HOME/Documents/example/node_modules/package.txt"
printf 'bytecode\n' >"$TEST_HOME/Documents/python-cache-project/pkg/__pycache__/module.cpython-312.pyc"
printf 'pytest cache\n' >"$TEST_HOME/Documents/python-cache-project/.pytest_cache/CACHEDIR.TAG"
printf 'mypy cache\n' >"$TEST_HOME/Documents/python-cache-project/.mypy_cache/meta.json"
printf 'ruff cache\n' >"$TEST_HOME/Documents/python-cache-project/.ruff_cache/cache.db"
printf 'tox cache\n' >"$TEST_HOME/Documents/python-cache-project/.tox/state.json"
printf 'nox cache\n' >"$TEST_HOME/Documents/python-cache-project/.nox/state.json"
printf 'coverage report\n' >"$TEST_HOME/Documents/python-cache-project/htmlcov/index.html"
printf 'coverage data\n' >"$TEST_HOME/Documents/python-cache-project/.coverage"
printf 'ignored dependency cache\n' >"$TEST_HOME/Documents/python-cache-project/node_modules/__pycache__/ignored.pyc"
printf 'home = /usr/bin\n' >"$TEST_HOME/Documents/python-app/.venv/pyvenv.cfg"
printf 'python shim\n' >"$TEST_HOME/Documents/python-app/.venv/bin/python"
ln -s "$TEST_HOME/Documents/missing-target" "$TEST_HOME/Documents/broken-link"
touch -t 202001010000 "$TEST_HOME/Documents/example/node_modules" "$TEST_HOME/Documents/example/node_modules/package.txt"
touch -t 202001010000 "$TEST_HOME/Documents/python-app/.venv" "$TEST_HOME/Documents/python-app/.venv/pyvenv.cfg" "$TEST_HOME/Documents/python-app/.venv/bin/python"
touch -t 202001010000 "$TEST_HOME/Desktop/Screenshot 2026-06-01 at 10.00.00 PM.png" "$TEST_HOME/Downloads/Screen Recording 2026-06-01 at 10.00.00 PM.mov" "$TEST_HOME/Downloads/old-archive.zip" "$TEST_HOME/Desktop/old-disk-image.dmg"
touch -t 202001010000 "$TEST_HOME/Library/DiagnosticReports/OldApp.crash" "$TEST_HOME/Library/Application Support/CrashReporter/OldApp.plist"
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
touch -t 202001010000 "$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup" "$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup/Info.plist" "$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup/Manifest.db"
dd if=/dev/zero of="$TEST_HOME/Downloads/big-test.bin" bs=1024 count=2048 >/dev/null 2>&1
dd if=/dev/zero of="$TEST_HOME/Downloads/old-installer.dmg" bs=1024 count=1024 >/dev/null 2>&1
touch -t 202001010000 "$TEST_HOME/Downloads/old-installer.dmg"
dd if=/dev/zero of="$TEST_HOME/Downloads/old-package.pkg" bs=1024 count=1024 >/dev/null 2>&1
touch -t 202001010000 "$TEST_HOME/Downloads/old-package.pkg"
dd if=/dev/zero of="$TEST_HOME/Downloads/old-download-artifact.tar.gz" bs=1024 count=768 >/dev/null 2>&1
printf 'keep me\n' >"$TEST_HOME/Downloads/old-report.pdf"
touch -t 202001010000 "$TEST_HOME/Downloads/old-download-artifact.tar.gz" "$TEST_HOME/Downloads/old-report.pdf"
dd if=/dev/zero of="$TEST_HOME/Documents/duplicates/copy-a.bin" bs=1024 count=2048 >/dev/null 2>&1
cp "$TEST_HOME/Documents/duplicates/copy-a.bin" "$TEST_HOME/Documents/duplicates/copy-b.bin"
dd if=/dev/zero of="$TEST_HOME/Applications/FakeBig.app/Contents/MacOS/fake" bs=1024 count=2048 >/dev/null 2>&1
printf 'uninstaller\n' >"$TEST_HOME/Applications/Cleanroom Test Uninstaller.app/Contents/MacOS/uninstall"
printf 'login helper\n' >"$TEST_HOME/Applications/Cleanroom Login Helper.app/Contents/MacOS/helper"
cat >"$TEST_HOME/bin/osascript" <<'SH'
#!/usr/bin/env bash
printf 'Cleanroom Login Helper\tfalse\t%s/Applications/Cleanroom Login Helper.app\n' "$HOME"
SH
chmod +x "$TEST_HOME/bin/osascript"
cat >"$TEST_HOME/bin/xattr" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "-p" && "${2:-}" == "com.apple.quarantine" && "${3:-}" == *"old-installer.dmg" ]]; then
  printf '0081;66554433;Safari;12345678-90AB-CDEF-1234-567890ABCDEF\n'
  exit 0
fi
exit 1
SH
chmod +x "$TEST_HOME/bin/xattr"
cat >"$TEST_HOME/bin/mdfind" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "-onlyin" ]]; then
  root="${2:-}"
  query="${3:-}"
  if [[ "$query" == *"kMDItemFSName"* ]]; then
    [[ -f "$root/Documents/.DS_Store" ]] && printf '%s\n' "$root/Documents/.DS_Store"
    [[ -f "$root/Downloads/._old-installer.dmg" ]] && printf '%s\n' "$root/Downloads/._old-installer.dmg"
    [[ -f "$root/Desktop/Thumbs.db" ]] && printf '%s\n' "$root/Desktop/Thumbs.db"
  else
    [[ -f "$root/Downloads/big-test.bin" ]] && printf '%s\n' "$root/Downloads/big-test.bin"
    [[ -f "$root/Downloads/old-installer.dmg" ]] && printf '%s\n' "$root/Downloads/old-installer.dmg"
    [[ -f "$root/Documents/duplicates/copy-a.bin" ]] && printf '%s\n' "$root/Documents/duplicates/copy-a.bin"
    [[ -f "$root/Documents/duplicates/copy-b.bin" ]] && printf '%s\n' "$root/Documents/duplicates/copy-b.bin"
  fi
  exit 0
fi
exit 2
SH
chmod +x "$TEST_HOME/bin/mdfind"
cat >"$TEST_HOME/bin/brew" <<'SH'
#!/usr/bin/env bash
case "${1:-}" in
  --prefix)
    printf '%s/homebrew-prefix\n' "$HOME"
    ;;
  list)
    case "${2:-}" in
      --formula) printf 'node\nopenssl\n' ;;
      --cask) printf 'visual-studio-code\n' ;;
      *) exit 2 ;;
    esac
    ;;
  cleanup)
    if [[ "${2:-}" == "-n" ]]; then
      printf 'Would remove: old-bottle.tar.gz\n'
    elif [[ -z "${2:-}" ]]; then
      printf 'Removing: old-bottle.tar.gz\n'
      printf 'applied\n' >"$HOME/brew-cleanup-applied"
    else
      exit 2
    fi
    ;;
  *)
    exit 2
    ;;
esac
SH
chmod +x "$TEST_HOME/bin/brew"
cat >"$TEST_HOME/bin/npm" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "cache" && "${2:-}" == "verify" ]]; then
  printf 'Cache verified and compressed (~/.npm/_cacache)\n'
  exit 0
fi
if [[ "${1:-}" == "cache" && "${2:-}" == "clean" && "${3:-}" == "--force" ]]; then
  printf 'npm WARN using --force Recommended protections disabled.\n'
  printf 'npm cache cleaned\n'
  printf 'applied\n' >"$HOME/npm-cache-clean-applied"
  exit 0
fi
exit 2
SH
chmod +x "$TEST_HOME/bin/npm"
cat >"$TEST_HOME/bin/yarn" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "cache" && "${2:-}" == "dir" ]]; then
  printf '%s/.cache/yarn\n' "$HOME"
  exit 0
fi
if [[ "${1:-}" == "cache" && "${2:-}" == "clean" ]]; then
  printf 'success Cleared cache.\n'
  printf 'applied\n' >"$HOME/yarn-cache-clean-applied"
  exit 0
fi
if [[ "${1:-}" == "config" && "${2:-}" == "get" && "${3:-}" == "cacheFolder" ]]; then
  printf '%s/.yarn/berry/cache\n' "$HOME"
  exit 0
fi
exit 2
SH
chmod +x "$TEST_HOME/bin/yarn"
cat >"$TEST_HOME/bin/pnpm" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "store" && "${2:-}" == "status" ]]; then
  printf 'Packages in the store are untouched\n'
  exit 0
fi
if [[ "${1:-}" == "store" && "${2:-}" == "prune" ]]; then
  printf 'Removed all cached metadata files\n'
  printf 'Removed 3 packages\n'
  printf 'applied\n' >"$HOME/pnpm-store-prune-applied"
  exit 0
fi
exit 2
SH
chmod +x "$TEST_HOME/bin/pnpm"
cat >"$TEST_HOME/bin/pod" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "cache" && "${2:-}" == "list" ]]; then
  printf 'AFNetworking:\n  - 4.0.1\n'
  exit 0
fi
if [[ "${1:-}" == "cache" && "${2:-}" == "clean" && "${3:-}" == "--all" ]]; then
  printf 'Cleaning CocoaPods cache\n'
  printf 'applied\n' >"$HOME/cocoapods-cache-clean-applied"
  exit 0
fi
exit 2
SH
chmod +x "$TEST_HOME/bin/pod"
cat >"$TEST_HOME/bin/pip3" <<'SH'
#!/usr/bin/env bash
if [[ "${1:-}" == "cache" && "${2:-}" == "info" ]]; then
  printf 'Package index page cache size: 48.0 MB\n'
  printf 'Locally built wheels size: 12.0 MB\n'
  exit 0
fi
if [[ "${1:-}" == "cache" && "${2:-}" == "purge" ]]; then
  printf 'Files removed: 42\n'
  printf 'applied\n' >"$HOME/pip-cache-purge-applied"
  exit 0
fi
exit 2
SH
chmod +x "$TEST_HOME/bin/pip3"
export HOME="$TEST_HOME"
export PATH="$TEST_HOME/bin:$PATH"

bash -n "$BIN"

"$BIN" --version | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' >/dev/null
"$BIN" help | grep 'safe macOS storage cleaner' >/dev/null
"$BIN" categories | grep -- '--include-ai-models' >/dev/null
"$BIN" categories | grep -- '--include-toolchains' >/dev/null
"$BIN" categories | grep -- '--include-venv-stale' >/dev/null
"$BIN" categories | grep -- '--trash' >/dev/null
"$BIN" dashboard | grep 'cleanroom dashboard' >/dev/null
dashboard_json="$(mktemp)"
"$BIN" dashboard --json > "$dashboard_json"
python3 -m json.tool "$dashboard_json" >/dev/null
grep '"safe_mode":true' "$dashboard_json" >/dev/null
grep '"deep_scan_required":true' "$dashboard_json" >/dev/null
rm -f "$dashboard_json"
"$BIN" overview | grep 'cleanroom overview' >/dev/null
overview_json="$(mktemp)"
"$BIN" overview --json > "$overview_json"
python3 -m json.tool "$overview_json" >/dev/null
grep '"summary"' "$overview_json" >/dev/null
grep '"toolchain_kb"' "$overview_json" >/dev/null
grep '"container_kb"' "$overview_json" >/dev/null
grep '"diagnostic_kb"' "$overview_json" >/dev/null
grep '"recommendations"' "$overview_json" >/dev/null
rm -f "$overview_json"
"$BIN" map | grep 'storage map' >/dev/null
map_json="$(mktemp)"
"$BIN" map --json > "$map_json"
python3 -m json.tool "$map_json" >/dev/null
grep '"id":"documents"' "$map_json" >/dev/null
grep '"id":"app-support"' "$map_json" >/dev/null
grep '"id":"cloud-files"' "$map_json" >/dev/null
grep '"id":"communications"' "$map_json" >/dev/null
grep '"command":"cleanroom communications"' "$map_json" >/dev/null
rm -f "$map_json"
snapshot_json="$(mktemp)"
"$BIN" snapshot --json > "$snapshot_json"
python3 -m json.tool "$snapshot_json" >/dev/null
grep '"created_at"' "$snapshot_json" >/dev/null
grep '"buckets"' "$snapshot_json" >/dev/null
grep '"id":"documents"' "$snapshot_json" >/dev/null
rm -f "$snapshot_json"
snapshot_output="$TEST_HOME/snapshot-output.json"
"$BIN" snapshot --output "$snapshot_output" | grep 'Wrote snapshot' >/dev/null
test -f "$snapshot_output"
python3 -m json.tool "$snapshot_output" >/dev/null
"$BIN" snapshot | grep 'Wrote snapshot' >/dev/null
find "$TEST_HOME/.local/state/cleanroom/snapshots" -type f -name 'snapshot-*.json' | grep 'snapshot-' >/dev/null
snapshot_before="$TEST_HOME/snapshot-before.json"
snapshot_after="$TEST_HOME/snapshot-after.json"
"$BIN" snapshot --output "$snapshot_before" >/dev/null
dd if=/dev/zero of="$TEST_HOME/Downloads/snapshot-growth.bin" bs=1024 count=32 >/dev/null 2>&1
"$BIN" snapshot --output "$snapshot_after" >/dev/null
"$BIN" diff "$snapshot_before" "$snapshot_after" | grep 'downloads' >/dev/null
diff_json="$(mktemp)"
"$BIN" diff "$snapshot_before" "$snapshot_after" --json > "$diff_json"
python3 -m json.tool "$diff_json" >/dev/null
grep '"id":"downloads"' "$diff_json" >/dev/null
grep '"delta_kb":' "$diff_json" >/dev/null
rm -f "$diff_json"
"$BIN" state | grep 'cleanroom state' >/dev/null
"$BIN" state | grep 'include-cleanroom-state' >/dev/null
state_json="$(mktemp)"
"$BIN" state --json > "$state_json"
python3 -m json.tool "$state_json" >/dev/null
grep '"id":"run-logs"' "$state_json" >/dev/null
grep '"id":"snapshots"' "$state_json" >/dev/null
grep '"id":"recoverable-trash"' "$state_json" >/dev/null
rm -f "$state_json"
"$BIN" permissions | grep 'cleanroom permissions' >/dev/null
permissions_json="$(mktemp)"
"$BIN" permissions --json > "$permissions_json"
python3 -m json.tool "$permissions_json" >/dev/null
grep '"id":"mail"' "$permissions_json" >/dev/null
grep '"id":"messages"' "$permissions_json" >/dev/null
grep '"status":"accessible"' "$permissions_json" >/dev/null
rm -f "$permissions_json"
"$BIN" system-data | grep 'System Data breakdown' >/dev/null
system_data_json="$(mktemp)"
"$BIN" system-data --json > "$system_data_json"
python3 -m json.tool "$system_data_json" >/dev/null
grep 'mobile-backups' "$system_data_json" >/dev/null
grep 'media-libraries' "$system_data_json" >/dev/null
grep 'cloud-sync' "$system_data_json" >/dev/null
grep 'personal-data' "$system_data_json" >/dev/null
grep 'quicklook' "$system_data_json" >/dev/null
grep 'font-caches' "$system_data_json" >/dev/null
grep 'web-caches' "$system_data_json" >/dev/null
grep 'saved-state' "$system_data_json" >/dev/null
grep '"category":"protected"' "$system_data_json" >/dev/null
grep 'cleanroom containers' "$system_data_json" >/dev/null
rm -f "$system_data_json"
"$BIN" rules | grep 'safe-app-caches' >/dev/null
rules_json="$(mktemp)"
"$BIN" rules --json > "$rules_json"
python3 -m json.tool "$rules_json" >/dev/null
grep 'ai-models' "$rules_json" >/dev/null
grep 'old-diagnostics' "$rules_json" >/dev/null
grep 'toolchain-caches' "$rules_json" >/dev/null
grep 'stale-python-virtualenvs' "$rules_json" >/dev/null
grep 'storage-map' "$rules_json" >/dev/null
grep 'storage-snapshot' "$rules_json" >/dev/null
grep 'storage-diff' "$rules_json" >/dev/null
grep 'cleanroom-state' "$rules_json" >/dev/null
grep 'permissions-audit' "$rules_json" >/dev/null
grep 'review-dashboard' "$rules_json" >/dev/null
grep 'documents-inventory' "$rules_json" >/dev/null
grep 'desktop-inventory' "$rules_json" >/dev/null
grep 'brokenlinks-inventory' "$rules_json" >/dev/null
grep 'quarantine-inventory' "$rules_json" >/dev/null
grep 'metadata-clutter' "$rules_json" >/dev/null
grep 'quicklook-caches' "$rules_json" >/dev/null
grep 'font-caches' "$rules_json" >/dev/null
grep 'web-caches' "$rules_json" >/dev/null
grep 'saved-state' "$rules_json" >/dev/null
grep 'project-caches' "$rules_json" >/dev/null
grep 'updater-caches' "$rules_json" >/dev/null
grep 'browser-caches' "$rules_json" >/dev/null
grep 'device-backups' "$rules_json" >/dev/null
grep 'download-artifacts' "$rules_json" >/dev/null
grep 'old-screenshots' "$rules_json" >/dev/null
grep 'screenshots-inventory' "$rules_json" >/dev/null
grep 'archives-inventory' "$rules_json" >/dev/null
grep 'android-inventory' "$rules_json" >/dev/null
grep 'loginitems-inventory' "$rules_json" >/dev/null
grep 'uninstallers-inventory' "$rules_json" >/dev/null
grep 'appreview-inventory' "$rules_json" >/dev/null
grep 'appdata-inventory' "$rules_json" >/dev/null
grep 'cloud-inventory' "$rules_json" >/dev/null
grep 'cloudfiles-inventory' "$rules_json" >/dev/null
grep 'personal-inventory' "$rules_json" >/dev/null
grep 'communications-inventory' "$rules_json" >/dev/null
grep 'receipts-inventory' "$rules_json" >/dev/null
rm -f "$rules_json"
"$BIN" review | grep 'personal storage checklist' >/dev/null
review_json="$(mktemp)"
"$BIN" review --json > "$review_json"
python3 -m json.tool "$review_json" >/dev/null
grep '"id":"documents"' "$review_json" >/dev/null
grep '"id":"desktop"' "$review_json" >/dev/null
grep '"id":"screenshots"' "$review_json" >/dev/null
grep '"id":"archives"' "$review_json" >/dev/null
grep '"id":"communications"' "$review_json" >/dev/null
grep '"command":"cleanroom appdata --limit 20"' "$review_json" >/dev/null
rm -f "$review_json"
"$BIN" plan | grep 'cleanroom plan' >/dev/null
plan_json="$(mktemp)"
"$BIN" plan --json > "$plan_json"
python3 -m json.tool "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-toolchains' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-venv-stale --days 30' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-containers' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-diagnostics --days 30' "$plan_json" >/dev/null
grep 'cleanroom metadata --apply --trash' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-quicklook' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-font-caches' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-web-caches' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-saved-state' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-project-caches' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-updater-caches' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-browser-caches' "$plan_json" >/dev/null
grep 'cleanroom clean --include-device-backups --days 30 --apply --trash' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-download-artifacts --days 30' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-screenshots --days 30' "$plan_json" >/dev/null
grep 'cleanroom clean --apply --include-cleanroom-state --days 30' "$plan_json" >/dev/null
rm -f "$plan_json"
"$BIN" large "$HOME/Downloads" --min-mb 1 --limit 5 | grep 'big-test.bin' >/dev/null
large_json="$(mktemp)"
"$BIN" large --json "$HOME/Downloads" --min-mb 1 --limit 5 > "$large_json"
python3 -m json.tool "$large_json" >/dev/null
grep 'big-test.bin' "$large_json" >/dev/null
rm -f "$large_json"
"$BIN" large-fast "$HOME" --min-mb 1 --limit 5 | grep 'big-test.bin' >/dev/null
large_fast_json="$(mktemp)"
"$BIN" large-fast --json "$HOME" --min-mb 1 --limit 5 > "$large_fast_json"
python3 -m json.tool "$large_fast_json" >/dev/null
grep '"available":true' "$large_fast_json" >/dev/null
grep 'big-test.bin' "$large_fast_json" >/dev/null
rm -f "$large_fast_json"
"$BIN" brokenlinks "$HOME/Documents" --limit 10 | grep 'broken-link' >/dev/null
brokenlinks_json="$(mktemp)"
"$BIN" brokenlinks --json "$HOME/Documents" --limit 10 > "$brokenlinks_json"
python3 -m json.tool "$brokenlinks_json" >/dev/null
grep '"path":' "$brokenlinks_json" >/dev/null
grep 'broken-link' "$brokenlinks_json" >/dev/null
grep 'missing-target' "$brokenlinks_json" >/dev/null
grep 'open -R' "$brokenlinks_json" >/dev/null
rm -f "$brokenlinks_json"
"$BIN" quarantine "$HOME/Downloads" --limit 10 | grep 'old-installer.dmg' >/dev/null
quarantine_json="$(mktemp)"
"$BIN" quarantine --json "$HOME/Downloads" --limit 10 > "$quarantine_json"
python3 -m json.tool "$quarantine_json" >/dev/null
grep 'old-installer.dmg' "$quarantine_json" >/dev/null
grep '"quarantine":"' "$quarantine_json" >/dev/null
grep 'Safari' "$quarantine_json" >/dev/null
grep 'open -R' "$quarantine_json" >/dev/null
rm -f "$quarantine_json"
"$BIN" metadata "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" --limit 10 | grep '.DS_Store' >/dev/null
"$BIN" metadata "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" --limit 10 | grep 'Thumbs.db' >/dev/null
metadata_json="$(mktemp)"
"$BIN" metadata --json "$HOME/Documents" "$HOME/Downloads" "$HOME/Desktop" --limit 10 > "$metadata_json"
python3 -m json.tool "$metadata_json" >/dev/null
grep '"kind":"finder-metadata"' "$metadata_json" >/dev/null
grep '"kind":"appledouble"' "$metadata_json" >/dev/null
grep '"kind":"windows-metadata"' "$metadata_json" >/dev/null
grep 'cleanroom metadata --apply --trash' "$metadata_json" >/dev/null
rm -f "$metadata_json"
"$BIN" metadata-fast "$HOME" --limit 10 | grep '.DS_Store' >/dev/null
metadata_fast_json="$(mktemp)"
"$BIN" metadata-fast --json "$HOME" --limit 10 > "$metadata_fast_json"
python3 -m json.tool "$metadata_fast_json" >/dev/null
grep '"available":true' "$metadata_fast_json" >/dev/null
grep '"kind":"finder-metadata"' "$metadata_fast_json" >/dev/null
grep '"kind":"appledouble"' "$metadata_fast_json" >/dev/null
grep '"kind":"windows-metadata"' "$metadata_fast_json" >/dev/null
rm -f "$metadata_fast_json"
if "$BIN" metadata "$HOME/Documents" --apply --yes --limit 1 >/dev/null 2>&1; then
  echo "metadata apply without --trash should fail" >&2
  exit 1
fi
metadata_log="$TEST_HOME/metadata-apply.log"
"$BIN" metadata "$HOME/Documents" --apply --trash --yes --limit 10 --log "$metadata_log" | grep 'metadata summary' >/dev/null
test ! -e "$TEST_HOME/Documents/.DS_Store"
test -f "$metadata_log"
grep $'\ttrash\tok\t' "$metadata_log" >/dev/null
"$BIN" restore --log "$metadata_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Documents/.DS_Store"
"$BIN" quicklook | grep 'Quick Look Thumbnail Cache' >/dev/null
quicklook_json="$(mktemp)"
"$BIN" quicklook --json > "$quicklook_json"
python3 -m json.tool "$quicklook_json" >/dev/null
grep '"id":"quicklook-thumbnail-cache"' "$quicklook_json" >/dev/null
grep '"exists":true' "$quicklook_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-quicklook' "$quicklook_json" >/dev/null
rm -f "$quicklook_json"
quicklook_log="$TEST_HOME/quicklook-apply.log"
"$BIN" clean --include-quicklook --apply --trash --yes --log "$quicklook_log" >/dev/null
test ! -e "$TEST_HOME/Library/Containers/com.apple.QuickLook.thumbnailcache/Data/Library/Caches"
test -f "$quicklook_log"
grep $'\ttrash\tok\t' "$quicklook_log" >/dev/null
"$BIN" restore --log "$quicklook_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Containers/com.apple.QuickLook.thumbnailcache/Data/Library/Caches"
"$BIN" fontcaches | grep 'ATS User Font Cache' >/dev/null
fontcaches_json="$(mktemp)"
"$BIN" fontcaches --json > "$fontcaches_json"
python3 -m json.tool "$fontcaches_json" >/dev/null
grep '"id":"ats-user-cache"' "$fontcaches_json" >/dev/null
grep '"exists":true' "$fontcaches_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-font-caches' "$fontcaches_json" >/dev/null
rm -f "$fontcaches_json"
fontcaches_log="$TEST_HOME/fontcaches-apply.log"
"$BIN" clean --include-font-caches --apply --trash --yes --log "$fontcaches_log" >/dev/null
test ! -e "$TEST_HOME/Library/Caches/com.apple.ATS"
test -f "$fontcaches_log"
grep $'\ttrash\tok\t' "$fontcaches_log" >/dev/null
"$BIN" restore --log "$fontcaches_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Caches/com.apple.ATS"
"$BIN" webcaches | grep 'Safari User Cache' >/dev/null
webcaches_json="$(mktemp)"
"$BIN" webcaches --json > "$webcaches_json"
python3 -m json.tool "$webcaches_json" >/dev/null
grep '"id":"safari-user-cache"' "$webcaches_json" >/dev/null
grep '"exists":true' "$webcaches_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-web-caches' "$webcaches_json" >/dev/null
rm -f "$webcaches_json"
webcaches_log="$TEST_HOME/webcaches-apply.log"
"$BIN" clean --include-web-caches --apply --trash --yes --log "$webcaches_log" >/dev/null
test ! -e "$TEST_HOME/Library/Caches/com.apple.Safari"
test ! -e "$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/Caches"
test -e "$TEST_HOME/Library/Safari/History.db"
test -e "$TEST_HOME/Library/Safari/Bookmarks.plist"
test -e "$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/Safari/History.db"
test -f "$webcaches_log"
grep $'\ttrash\tok\t' "$webcaches_log" >/dev/null
"$BIN" restore --log "$webcaches_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Caches/com.apple.Safari"
test -e "$TEST_HOME/Library/Containers/com.apple.Safari/Data/Library/Caches"
"$BIN" savedstate | grep 'Saved Application State' >/dev/null
savedstate_json="$(mktemp)"
"$BIN" savedstate --json > "$savedstate_json"
python3 -m json.tool "$savedstate_json" >/dev/null
grep '"id":"saved-application-state"' "$savedstate_json" >/dev/null
grep '"exists":true' "$savedstate_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-saved-state' "$savedstate_json" >/dev/null
rm -f "$savedstate_json"
savedstate_log="$TEST_HOME/savedstate-apply.log"
"$BIN" clean --include-saved-state --apply --trash --yes --log "$savedstate_log" >/dev/null
test ! -e "$TEST_HOME/Library/Saved Application State"
test -f "$savedstate_log"
grep $'\ttrash\tok\t' "$savedstate_log" >/dev/null
"$BIN" restore --log "$savedstate_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Saved Application State/com.example.Test.savedState/window.plist"
"$BIN" projectcaches "$HOME/Documents" --limit 20 | grep '__pycache__' >/dev/null
"$BIN" projectcaches "$HOME/Documents" --limit 20 | grep '.pytest_cache' >/dev/null
if "$BIN" projectcaches "$HOME/Documents" --limit 20 | grep 'node_modules/__pycache__' >/dev/null; then
  echo "projectcaches should prune node_modules" >&2
  exit 1
fi
projectcaches_json="$(mktemp)"
"$BIN" projectcaches --json "$HOME/Documents" --limit 20 > "$projectcaches_json"
python3 -m json.tool "$projectcaches_json" >/dev/null
grep '"kind":"python-bytecode"' "$projectcaches_json" >/dev/null
grep '"kind":"pytest-cache"' "$projectcaches_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-project-caches' "$projectcaches_json" >/dev/null
rm -f "$projectcaches_json"
projectcaches_log="$TEST_HOME/projectcaches-apply.log"
"$BIN" clean --include-project-caches --apply --trash --yes --log "$projectcaches_log" >/dev/null
test ! -e "$TEST_HOME/Documents/python-cache-project/pkg/__pycache__"
test ! -e "$TEST_HOME/Documents/python-cache-project/.pytest_cache"
test -e "$TEST_HOME/Documents/python-cache-project/node_modules/__pycache__/ignored.pyc"
test -f "$projectcaches_log"
grep $'\ttrash\tok\t' "$projectcaches_log" >/dev/null
"$BIN" restore --log "$projectcaches_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Documents/python-cache-project/pkg/__pycache__/module.cpython-312.pyc"
"$BIN" updaters | grep 'Sparkle cache' >/dev/null
"$BIN" updaters | grep 'Squirrel staging' >/dev/null
updaters_json="$(mktemp)"
"$BIN" updaters --json > "$updaters_json"
python3 -m json.tool "$updaters_json" >/dev/null
grep '"id":"sparkle-cache"' "$updaters_json" >/dev/null
grep '"id":"squirrel-staging"' "$updaters_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-updater-caches' "$updaters_json" >/dev/null
rm -f "$updaters_json"
updaters_log="$TEST_HOME/updaters-apply.log"
"$BIN" clean --include-updater-caches --apply --trash --yes --log "$updaters_log" >/dev/null
test ! -e "$TEST_HOME/Library/Caches/Sparkle"
test ! -e "$TEST_HOME/Library/Caches/com.github.Squirrel.ShipIt"
test ! -e "$TEST_HOME/Library/Application Support/com.github.Squirrel.ShipIt"
test -f "$updaters_log"
grep $'\ttrash\tok\t' "$updaters_log" >/dev/null
"$BIN" restore --log "$updaters_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Caches/Sparkle/update.zip"
test -e "$TEST_HOME/Library/Application Support/com.github.Squirrel.ShipIt/staged-update"
"$BIN" browsercaches | grep 'Google Chrome' >/dev/null
"$BIN" browsercaches | grep 'Firefox' >/dev/null
browsercaches_json="$(mktemp)"
"$BIN" browsercaches --json > "$browsercaches_json"
python3 -m json.tool "$browsercaches_json" >/dev/null
grep '"browser":"Google Chrome"' "$browsercaches_json" >/dev/null
grep '"kind":"firefox-cache"' "$browsercaches_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-browser-caches' "$browsercaches_json" >/dev/null
rm -f "$browsercaches_json"
browsercaches_log="$TEST_HOME/browsercaches-apply.log"
"$BIN" clean --include-browser-caches --apply --trash --yes --log "$browsercaches_log" >/dev/null
test ! -e "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache"
test ! -e "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Code Cache"
test ! -e "$TEST_HOME/Library/Caches/Firefox"
test -e "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Login Data"
test -f "$browsercaches_log"
grep $'\ttrash\tok\t' "$browsercaches_log" >/dev/null
"$BIN" restore --log "$browsercaches_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Application Support/Google/Chrome/Default/Cache/example.cache"
test -e "$TEST_HOME/Library/Caches/Firefox/cache2.db"
"$BIN" duplicates "$HOME/Documents" --min-mb 1 --limit 5 | grep 'copy-a.bin' >/dev/null
"$BIN" duplicates "$HOME/Documents" --min-mb 1 --limit 5 | grep 'copy-b.bin' >/dev/null
duplicates_json="$(mktemp)"
"$BIN" duplicates --json "$HOME/Documents" --min-mb 1 --limit 5 > "$duplicates_json"
python3 -m json.tool "$duplicates_json" >/dev/null
grep 'potential_reclaim_kb' "$duplicates_json" >/dev/null
grep 'copy-b.bin' "$duplicates_json" >/dev/null
rm -f "$duplicates_json"
"$BIN" duplicates-fast "$HOME" --min-mb 1 --limit 5 | grep 'copy-a.bin' >/dev/null
duplicates_fast_json="$(mktemp)"
"$BIN" duplicates-fast --json "$HOME" --min-mb 1 --limit 5 > "$duplicates_fast_json"
python3 -m json.tool "$duplicates_fast_json" >/dev/null
grep '"available":true' "$duplicates_fast_json" >/dev/null
grep 'copy-a.bin' "$duplicates_fast_json" >/dev/null
grep 'copy-b.bin' "$duplicates_fast_json" >/dev/null
rm -f "$duplicates_fast_json"
"$BIN" documents "$HOME/Documents" --limit 10 | grep 'media-project' >/dev/null
documents_json="$(mktemp)"
"$BIN" documents --json "$HOME/Documents" --limit 10 > "$documents_json"
python3 -m json.tool "$documents_json" >/dev/null
grep '"name":"media-project"' "$documents_json" >/dev/null
grep '"kind":"directory"' "$documents_json" >/dev/null
grep '"guard_status":"review"' "$documents_json" >/dev/null
grep 'cleanroom large' "$documents_json" >/dev/null
rm -f "$documents_json"
"$BIN" desktop --limit 10 | grep 'old-disk-image.dmg' >/dev/null
desktop_json="$(mktemp)"
"$BIN" desktop --json --limit 10 > "$desktop_json"
python3 -m json.tool "$desktop_json" >/dev/null
grep '"name":"old-disk-image.dmg"' "$desktop_json" >/dev/null
grep '"guard_status":"review"' "$desktop_json" >/dev/null
grep 'cleanroom large' "$desktop_json" >/dev/null
rm -f "$desktop_json"
"$BIN" screenshots "$HOME/Desktop" --days 7 --limit 10 | grep 'Screenshot 2026' >/dev/null
screenshots_json="$(mktemp)"
"$BIN" screenshots --json "$HOME/Desktop" --days 7 --limit 10 > "$screenshots_json"
python3 -m json.tool "$screenshots_json" >/dev/null
grep '"name":"Screenshot 2026-06-01 at 10.00.00 PM.png"' "$screenshots_json" >/dev/null
grep '"age_days"' "$screenshots_json" >/dev/null
grep 'open -R' "$screenshots_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-screenshots --days 7' "$screenshots_json" >/dev/null
rm -f "$screenshots_json"
"$BIN" archives "$HOME/Downloads" --days 7 --limit 10 | grep 'old-archive.zip' >/dev/null
archives_json="$(mktemp)"
"$BIN" archives --json "$HOME/Downloads" --days 7 --limit 10 > "$archives_json"
python3 -m json.tool "$archives_json" >/dev/null
grep '"name":"old-archive.zip"' "$archives_json" >/dev/null
grep '"kind":"archive"' "$archives_json" >/dev/null
grep 'open -R' "$archives_json" >/dev/null
rm -f "$archives_json"
"$BIN" downloads --days 30 --limit 5 | grep 'old-installer.dmg' >/dev/null
downloads_json="$(mktemp)"
"$BIN" downloads --json --days 30 --limit 5 > "$downloads_json"
python3 -m json.tool "$downloads_json" >/dev/null
grep 'old-installer.dmg' "$downloads_json" >/dev/null
grep '"age_days"' "$downloads_json" >/dev/null
grep '"cleanup_eligible":true' "$downloads_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-download-artifacts --days 30' "$downloads_json" >/dev/null
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
"$BIN" venvs "$HOME/Documents" --days 30 --limit 5 | grep '.venv' >/dev/null
venvs_json="$(mktemp)"
"$BIN" venvs --json "$HOME/Documents" --days 30 --limit 5 > "$venvs_json"
python3 -m json.tool "$venvs_json" >/dev/null
grep 'pyvenv.cfg' "$venvs_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-venv-stale --days 30' "$venvs_json" >/dev/null
rm -f "$venvs_json"
"$BIN" apps "$HOME/Applications" --limit 5 | grep 'FakeBig' >/dev/null
apps_json="$(mktemp)"
"$BIN" apps --json "$HOME/Applications" --limit 5 > "$apps_json"
python3 -m json.tool "$apps_json" >/dev/null
grep 'FakeBig' "$apps_json" >/dev/null
rm -f "$apps_json"
"$BIN" uninstallers "$HOME/Applications" --limit 10 | grep 'Cleanroom Test Uninstaller' >/dev/null
uninstallers_json="$(mktemp)"
"$BIN" uninstallers --json "$HOME/Applications" --limit 10 > "$uninstallers_json"
python3 -m json.tool "$uninstallers_json" >/dev/null
grep '"name":"Cleanroom Test Uninstaller.app"' "$uninstallers_json" >/dev/null
grep '"kind":"app"' "$uninstallers_json" >/dev/null
grep 'open ' "$uninstallers_json" >/dev/null
rm -f "$uninstallers_json"
"$BIN" appreview cleanroom --limit 20 | grep 'cleanroom app removal review' >/dev/null
"$BIN" appreview cleanroom --limit 20 | grep 'Cleanroom Test Uninstaller.app' >/dev/null
"$BIN" appreview cleanroom --limit 20 | grep 'com.cleanroom.test.pkg' >/dev/null
appreview_json="$(mktemp)"
"$BIN" appreview cleanroom --json --limit 20 > "$appreview_json"
python3 -m json.tool "$appreview_json" >/dev/null
grep '"apps"' "$appreview_json" >/dev/null
grep '"uninstallers"' "$appreview_json" >/dev/null
grep '"receipts"' "$appreview_json" >/dev/null
grep '"leftovers"' "$appreview_json" >/dev/null
grep 'Cleanroom Test Uninstaller.app' "$appreview_json" >/dev/null
grep 'com.cleanroom.test.pkg' "$appreview_json" >/dev/null
grep 'CleanroomTestAdobe' "$appreview_json" >/dev/null
rm -f "$appreview_json"
"$BIN" appdata --limit 20 | grep 'CleanroomTestAdobe' >/dev/null
appdata_json="$(mktemp)"
"$BIN" appdata --json --limit 20 > "$appdata_json"
python3 -m json.tool "$appdata_json" >/dev/null
grep 'CleanroomTestAdobe' "$appdata_json" >/dev/null
grep '"status":"allowed"' "$appdata_json" >/dev/null
grep '"status":"refused-protected"' "$appdata_json" >/dev/null
rm -f "$appdata_json"
"$BIN" libraries | grep 'Photos Library' >/dev/null
libraries_json="$(mktemp)"
"$BIN" libraries --json > "$libraries_json"
python3 -m json.tool "$libraries_json" >/dev/null
grep 'iMovie Library' "$libraries_json" >/dev/null
grep '"protected":true' "$libraries_json" >/dev/null
rm -f "$libraries_json"
"$BIN" cloud | grep 'iCloud Drive' >/dev/null
cloud_json="$(mktemp)"
"$BIN" cloud --json > "$cloud_json"
python3 -m json.tool "$cloud_json" >/dev/null
grep 'cloudstorage' "$cloud_json" >/dev/null
grep '"protected":true' "$cloud_json" >/dev/null
rm -f "$cloud_json"
"$BIN" cloudfiles "$HOME/Library/CloudStorage" --min-mb 1 --limit 10 | grep 'big-cloud.bin' >/dev/null
cloudfiles_json="$(mktemp)"
"$BIN" cloudfiles --json "$HOME/Library/CloudStorage" --min-mb 1 --limit 10 > "$cloudfiles_json"
python3 -m json.tool "$cloudfiles_json" >/dev/null
grep 'big-cloud.bin' "$cloudfiles_json" >/dev/null
grep '"provider":"Dropbox-Test"' "$cloudfiles_json" >/dev/null
grep 'open -R' "$cloudfiles_json" >/dev/null
rm -f "$cloudfiles_json"
"$BIN" personal | grep 'Messages' >/dev/null
personal_json="$(mktemp)"
"$BIN" personal --json > "$personal_json"
python3 -m json.tool "$personal_json" >/dev/null
grep 'Voice Memos' "$personal_json" >/dev/null
grep '"protected":true' "$personal_json" >/dev/null
rm -f "$personal_json"
"$BIN" communications | grep 'Messages Attachments' >/dev/null
communications_json="$(mktemp)"
"$BIN" communications --json > "$communications_json"
python3 -m json.tool "$communications_json" >/dev/null
grep '"id":"mail-downloads"' "$communications_json" >/dev/null
grep '"id":"mail-container-downloads"' "$communications_json" >/dev/null
grep '"id":"messages-attachments"' "$communications_json" >/dev/null
grep '"protected":true' "$communications_json" >/dev/null
rm -f "$communications_json"
"$BIN" browsers | grep 'Google Chrome' >/dev/null
"$BIN" browsers | grep 'protected' >/dev/null
browsers_json="$(mktemp)"
"$BIN" browsers --json > "$browsers_json"
python3 -m json.tool "$browsers_json" >/dev/null
grep 'Google Chrome' "$browsers_json" >/dev/null
grep '"protected":true' "$browsers_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-browser-caches' "$browsers_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-web-caches' "$browsers_json" >/dev/null
rm -f "$browsers_json"
"$BIN" leftovers cleanroomtestadobe --limit 10 | grep 'com.cleanroomtestadobe.acc' >/dev/null
leftovers_json="$(mktemp)"
"$BIN" leftovers cleanroomtestadobe --json --limit 10 > "$leftovers_json"
python3 -m json.tool "$leftovers_json" >/dev/null
grep '"queries"' "$leftovers_json" >/dev/null
grep 'com.cleanroomtestadobe.acc' "$leftovers_json" >/dev/null
grep '"category":"preferences"' "$leftovers_json" >/dev/null
grep '"status":"allowed"' "$leftovers_json" >/dev/null
grep 'cleanroom leftovers --apply --trash' "$leftovers_json" >/dev/null
rm -f "$leftovers_json"
if "$BIN" leftovers cleanroomtestadobe --apply --yes --limit 1 >/dev/null 2>&1; then
  echo "leftovers apply without --trash should fail" >&2
  exit 1
fi
leftover_log="$TEST_HOME/leftovers-apply.log"
mkdir -p "$TEST_HOME/Library/Application Support/CleanroomRestoreLeftover"
printf 'leftover support\n' >"$TEST_HOME/Library/Application Support/CleanroomRestoreLeftover/state.db"
mkdir -p "$TEST_HOME/Library/Caches/com.cleanroomrestoreleftover"
printf 'leftover cache\n' >"$TEST_HOME/Library/Caches/com.cleanroomrestoreleftover/cache.bin"
"$BIN" leftovers cleanroomrestoreleftover --apply --trash --yes --limit 10 --log "$leftover_log" | grep 'leftovers summary' >/dev/null
test ! -e "$TEST_HOME/Library/Application Support/CleanroomRestoreLeftover"
test -f "$leftover_log"
grep $'\ttrash\tok\t' "$leftover_log" >/dev/null
"$BIN" restore --log "$leftover_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Application Support/CleanroomRestoreLeftover"
"$BIN" backups | grep 'Vivek Test iPhone' >/dev/null
backups_json="$(mktemp)"
"$BIN" backups --json > "$backups_json"
python3 -m json.tool "$backups_json" >/dev/null
grep 'Vivek Test iPhone' "$backups_json" >/dev/null
grep '"protected":true' "$backups_json" >/dev/null
grep '"cleanup_eligible":true' "$backups_json" >/dev/null
grep 'cleanroom clean --include-device-backups --days 30 --apply --trash' "$backups_json" >/dev/null
rm -f "$backups_json"
device_backups_log="$TEST_HOME/device-backups-apply.log"
"$BIN" clean --include-device-backups --days 30 --apply --trash --yes --log "$device_backups_log" >/dev/null
test ! -e "$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup"
test -f "$device_backups_log"
grep $'\ttrash\tok\t' "$device_backups_log" >/dev/null
"$BIN" restore --log "$device_backups_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/Application Support/MobileSync/Backup/FakeDeviceBackup/Info.plist"
"$BIN" xcode | grep 'Xcode Archives' >/dev/null
xcode_json="$(mktemp)"
"$BIN" xcode --json > "$xcode_json"
python3 -m json.tool "$xcode_json" >/dev/null
grep '"id":"xcode-archives"' "$xcode_json" >/dev/null
grep '"safety":"review-only"' "$xcode_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-dev-heavy' "$xcode_json" >/dev/null
rm -f "$xcode_json"
"$BIN" android | grep 'Android Virtual Devices' >/dev/null
android_json="$(mktemp)"
"$BIN" android --json > "$android_json"
python3 -m json.tool "$android_json" >/dev/null
grep '"id":"android-system-images"' "$android_json" >/dev/null
grep '"id":"android-avds"' "$android_json" >/dev/null
grep '"safety":"dev-heavy"' "$android_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-dev-heavy' "$android_json" >/dev/null
rm -f "$android_json"
"$BIN" startup | grep 'com.example.cleanroom-test' >/dev/null
startup_json="$(mktemp)"
"$BIN" startup --json > "$startup_json"
python3 -m json.tool "$startup_json" >/dev/null
grep 'com.example.cleanroom-test' "$startup_json" >/dev/null
grep '"type":"LaunchAgent"' "$startup_json" >/dev/null
rm -f "$startup_json"
"$BIN" loginitems | grep 'Cleanroom Login Helper' >/dev/null
loginitems_json="$(mktemp)"
"$BIN" loginitems --json > "$loginitems_json"
python3 -m json.tool "$loginitems_json" >/dev/null
grep '"name":"Cleanroom Login Helper"' "$loginitems_json" >/dev/null
grep '"hidden":"false"' "$loginitems_json" >/dev/null
grep '"present":true' "$loginitems_json" >/dev/null
rm -f "$loginitems_json"
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
grep 'cocoapods-cache' "$packages_json" >/dev/null
grep 'pip-cache' "$packages_json" >/dev/null
grep 'homebrew-cache' "$packages_json" >/dev/null
grep 'cleanroom yarn-cache --apply --yes' "$packages_json" >/dev/null
grep 'cleanroom pnpm-store --apply --yes' "$packages_json" >/dev/null
grep 'cleanroom cocoapods-cache --apply --yes' "$packages_json" >/dev/null
grep 'cleanroom pip-cache --apply --yes' "$packages_json" >/dev/null
rm -f "$packages_json"
"$BIN" npm-cache | grep 'Cache verified' >/dev/null
npm_cache_json="$(mktemp)"
"$BIN" npm-cache --json > "$npm_cache_json"
python3 -m json.tool "$npm_cache_json" >/dev/null
grep '"command":"npm cache verify"' "$npm_cache_json" >/dev/null
grep 'Cache verified' "$npm_cache_json" >/dev/null
rm -f "$npm_cache_json"
npm_cache_log="$(mktemp)"
rm -f "$npm_cache_log" "$TEST_HOME/npm-cache-clean-applied"
"$BIN" npm-cache --apply --yes --log "$npm_cache_log" | grep 'npm cache cleaned' >/dev/null
test -f "$TEST_HOME/npm-cache-clean-applied"
grep 'npm-cache' "$npm_cache_log" >/dev/null
"$BIN" yarn-cache | grep '.cache/yarn' >/dev/null
yarn_cache_json="$(mktemp)"
"$BIN" yarn-cache --json > "$yarn_cache_json"
python3 -m json.tool "$yarn_cache_json" >/dev/null
grep '"command":"yarn cache dir"' "$yarn_cache_json" >/dev/null
grep '.cache/yarn' "$yarn_cache_json" >/dev/null
rm -f "$yarn_cache_json"
yarn_cache_log="$(mktemp)"
rm -f "$yarn_cache_log" "$TEST_HOME/yarn-cache-clean-applied"
"$BIN" yarn-cache --apply --yes --log "$yarn_cache_log" | grep 'Cleared cache' >/dev/null
test -f "$TEST_HOME/yarn-cache-clean-applied"
grep 'yarn-cache' "$yarn_cache_log" >/dev/null
"$BIN" pnpm-store | grep 'Packages in the store are untouched' >/dev/null
pnpm_store_json="$(mktemp)"
"$BIN" pnpm-store --json > "$pnpm_store_json"
python3 -m json.tool "$pnpm_store_json" >/dev/null
grep '"command":"pnpm store status"' "$pnpm_store_json" >/dev/null
grep 'Packages in the store are untouched' "$pnpm_store_json" >/dev/null
rm -f "$pnpm_store_json"
pnpm_store_log="$(mktemp)"
rm -f "$pnpm_store_log" "$TEST_HOME/pnpm-store-prune-applied"
"$BIN" pnpm-store --apply --yes --log "$pnpm_store_log" | grep 'Removed 3 packages' >/dev/null
test -f "$TEST_HOME/pnpm-store-prune-applied"
grep 'pnpm-store' "$pnpm_store_log" >/dev/null
"$BIN" cocoapods-cache | grep 'AFNetworking' >/dev/null
cocoapods_cache_json="$(mktemp)"
"$BIN" cocoapods-cache --json > "$cocoapods_cache_json"
python3 -m json.tool "$cocoapods_cache_json" >/dev/null
grep '"command":"pod cache list"' "$cocoapods_cache_json" >/dev/null
grep 'AFNetworking' "$cocoapods_cache_json" >/dev/null
rm -f "$cocoapods_cache_json"
cocoapods_cache_log="$(mktemp)"
rm -f "$cocoapods_cache_log" "$TEST_HOME/cocoapods-cache-clean-applied"
"$BIN" cocoapods-cache --apply --yes --log "$cocoapods_cache_log" | grep 'Cleaning CocoaPods cache' >/dev/null
test -f "$TEST_HOME/cocoapods-cache-clean-applied"
grep 'cocoapods-cache' "$cocoapods_cache_log" >/dev/null
"$BIN" pip-cache | grep 'Package index page cache size' >/dev/null
pip_cache_json="$(mktemp)"
"$BIN" pip-cache --json > "$pip_cache_json"
python3 -m json.tool "$pip_cache_json" >/dev/null
grep '"command":"pip3 cache info"' "$pip_cache_json" >/dev/null
grep 'Locally built wheels size' "$pip_cache_json" >/dev/null
rm -f "$pip_cache_json"
pip_cache_log="$(mktemp)"
rm -f "$pip_cache_log" "$TEST_HOME/pip-cache-purge-applied"
"$BIN" pip-cache --apply --yes --log "$pip_cache_log" | grep 'Files removed: 42' >/dev/null
test -f "$TEST_HOME/pip-cache-purge-applied"
grep 'pip-cache' "$pip_cache_log" >/dev/null
"$BIN" receipts --limit 20 | grep 'com.cleanroom.test.pkg' >/dev/null
receipts_json="$(mktemp)"
"$BIN" receipts --json --limit 20 > "$receipts_json"
python3 -m json.tool "$receipts_json" >/dev/null
grep '"id":"com.cleanroom.test.pkg"' "$receipts_json" >/dev/null
grep '"kind":"bom"' "$receipts_json" >/dev/null
grep 'cleanroom leftovers com.cleanroom.test.pkg' "$receipts_json" >/dev/null
rm -f "$receipts_json"
"$BIN" homebrew | grep 'homebrew-cache' >/dev/null
homebrew_json="$(mktemp)"
"$BIN" homebrew --json > "$homebrew_json"
python3 -m json.tool "$homebrew_json" >/dev/null
grep '"installed_formulae"' "$homebrew_json" >/dev/null
grep 'homebrew-logs' "$homebrew_json" >/dev/null
rm -f "$homebrew_json"
"$BIN" homebrew-cleanup | grep 'Would remove: old-bottle.tar.gz' >/dev/null
homebrew_cleanup_json="$(mktemp)"
"$BIN" homebrew-cleanup --json > "$homebrew_cleanup_json"
python3 -m json.tool "$homebrew_cleanup_json" >/dev/null
grep '"command":"brew cleanup -n"' "$homebrew_cleanup_json" >/dev/null
grep 'Would remove: old-bottle.tar.gz' "$homebrew_cleanup_json" >/dev/null
rm -f "$homebrew_cleanup_json"
homebrew_cleanup_log="$(mktemp)"
rm -f "$homebrew_cleanup_log" "$TEST_HOME/brew-cleanup-applied"
"$BIN" homebrew-cleanup --apply --yes --log "$homebrew_cleanup_log" | grep 'Removing: old-bottle.tar.gz' >/dev/null
test -f "$TEST_HOME/brew-cleanup-applied"
grep 'homebrew-cleanup' "$homebrew_cleanup_log" >/dev/null
"$BIN" toolchains | grep 'go-build-cache' >/dev/null
toolchains_json="$(mktemp)"
"$BIN" toolchains --json > "$toolchains_json"
python3 -m json.tool "$toolchains_json" >/dev/null
grep 'maven-repository' "$toolchains_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-toolchains' "$toolchains_json" >/dev/null
rm -f "$toolchains_json"
toolchain_log="$TEST_HOME/toolchains-apply.log"
"$BIN" clean --include-toolchains --apply --trash --yes --log "$toolchain_log" >/dev/null
test ! -e "$TEST_HOME/go/pkg/mod"
test -f "$toolchain_log"
grep $'\ttrash\tok\t' "$toolchain_log" >/dev/null
"$BIN" restore --log "$toolchain_log" --apply --yes >/dev/null
test -e "$TEST_HOME/go/pkg/mod"
"$BIN" containers | grep 'docker-desktop-vms' >/dev/null
containers_json="$(mktemp)"
"$BIN" containers --json > "$containers_json"
python3 -m json.tool "$containers_json" >/dev/null
grep 'podman-storage' "$containers_json" >/dev/null
grep '"safety":"high-impact"' "$containers_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-containers' "$containers_json" >/dev/null
rm -f "$containers_json"
"$BIN" caches | grep 'user-caches' >/dev/null
caches_json="$(mktemp)"
"$BIN" caches --json > "$caches_json"
python3 -m json.tool "$caches_json" >/dev/null
grep 'safe-app-caches' "$caches_json" >/dev/null
grep 'quicklook-caches' "$caches_json" >/dev/null
grep 'font-caches' "$caches_json" >/dev/null
grep 'web-caches' "$caches_json" >/dev/null
grep 'saved-state' "$caches_json" >/dev/null
grep 'project-caches' "$caches_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-app-caches' "$caches_json" >/dev/null
rm -f "$caches_json"
"$BIN" diagnostics | grep 'diagnostic-reports' >/dev/null
diagnostics_json="$(mktemp)"
"$BIN" diagnostics --json > "$diagnostics_json"
python3 -m json.tool "$diagnostics_json" >/dev/null
grep 'crash-reporter' "$diagnostics_json" >/dev/null
grep 'cleanroom clean --apply --trash --include-diagnostics --days 30' "$diagnostics_json" >/dev/null
rm -f "$diagnostics_json"
diagnostics_log="$TEST_HOME/diagnostics-apply.log"
"$BIN" clean --include-diagnostics --days 30 --apply --trash --yes --log "$diagnostics_log" >/dev/null
test ! -e "$TEST_HOME/Library/DiagnosticReports/OldApp.crash"
test -f "$diagnostics_log"
grep $'\ttrash\tok\t' "$diagnostics_log" >/dev/null
"$BIN" restore --log "$diagnostics_log" --apply --yes >/dev/null
test -e "$TEST_HOME/Library/DiagnosticReports/OldApp.crash"
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
grep 'imovie-library' "$protect_json" >/dev/null
grep 'cloudstorage' "$protect_json" >/dev/null
grep 'voice-memos' "$protect_json" >/dev/null
rm -f "$protect_json"
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome/Default" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome/Default/Login Data" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/Application Support/Google/Chrome/Default/Cache" | grep 'allowed' >/dev/null
"$BIN" guard "$HOME/Library/Application Support/MobileSync/Backup" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/CloudStorage" | grep 'refused-protected' >/dev/null
"$BIN" guard "$HOME/Library/Messages" | grep 'refused-protected' >/dev/null
guard_json="$(mktemp)"
"$BIN" guard --json "$HOME/Library/Application Support/Google/Chrome" "$HOME/Library/Application Support/Google/Chrome/Default/Cache" "$HOME/Library/Application Support/MobileSync/Backup" "$HOME/Library/CloudStorage" "$HOME/Library/Messages" > "$guard_json"
python3 -m json.tool "$guard_json" >/dev/null
grep '"status":"refused-protected"' "$guard_json" >/dev/null
grep '"status":"allowed"' "$guard_json" >/dev/null
grep 'MobileSync' "$guard_json" >/dev/null
grep 'CloudStorage' "$guard_json" >/dev/null
grep 'Messages' "$guard_json" >/dev/null
rm -f "$guard_json"
"$BIN" history 2>&1 | grep 'No cleanroom history found' >/dev/null

config_file="$(mktemp)"
rm -f "$config_file"
"$BIN" init-config --config "$config_file" --yes >/dev/null
grep '^preset=dev' "$config_file" >/dev/null
grep '^include_metadata=false' "$config_file" >/dev/null
grep '^include_quicklook=false' "$config_file" >/dev/null
grep '^include_font_caches=false' "$config_file" >/dev/null
grep '^include_web_caches=false' "$config_file" >/dev/null
grep '^include_saved_state=false' "$config_file" >/dev/null
grep '^include_project_caches=false' "$config_file" >/dev/null
grep '^include_updater_caches=false' "$config_file" >/dev/null
grep '^include_browser_caches=false' "$config_file" >/dev/null
grep '^include_device_backups=false' "$config_file" >/dev/null
grep '^include_download_artifacts=false' "$config_file" >/dev/null
grep '^include_screenshots=false' "$config_file" >/dev/null
grep '^include_cleanroom_state=false' "$config_file" >/dev/null
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
redacted_report="$(mktemp)"
"$BIN" report --redact --output "$redacted_report" >/dev/null
grep '# cleanroom report' "$redacted_report" >/dev/null
grep 'Cleanup Candidates' "$redacted_report" >/dev/null
grep '~/' "$redacted_report" >/dev/null
if grep -F "$TEST_HOME" "$redacted_report" >/dev/null; then
  echo "redacted report leaked TEST_HOME" >&2
  exit 1
fi
rm -f "$redacted_report"

json_file="$(mktemp)"
"$BIN" scan --json > "$json_file"
python3 -m json.tool "$json_file" >/dev/null
rm -f "$json_file"

dry_run_output="$("$BIN" clean --preset dev 2>&1)"
grep 'Dry-run mode' <<<"$dry_run_output" >/dev/null
preflight_output="$("$BIN" clean --preset dev --preflight)"
grep 'cleanroom clean preflight' <<<"$preflight_output" >/dev/null
grep 'app-caches' <<<"$preflight_output" >/dev/null
grep 'node-modules' <<<"$preflight_output" >/dev/null
ai_preflight_output="$("$BIN" clean --preset ai --preflight)"
grep 'ai-workspaces' <<<"$ai_preflight_output" >/dev/null
grep 'ai-models' <<<"$ai_preflight_output" >/dev/null
metadata_preflight="$("$BIN" clean --include-metadata --preflight)"
grep 'metadata' <<<"$metadata_preflight" >/dev/null
quicklook_preflight="$("$BIN" clean --include-quicklook --preflight)"
grep 'quicklook' <<<"$quicklook_preflight" >/dev/null
fontcaches_preflight="$("$BIN" clean --include-font-caches --preflight)"
grep 'font-caches' <<<"$fontcaches_preflight" >/dev/null
webcaches_preflight="$("$BIN" clean --include-web-caches --preflight)"
grep 'web-caches' <<<"$webcaches_preflight" >/dev/null
savedstate_preflight="$("$BIN" clean --include-saved-state --preflight)"
grep 'saved-state' <<<"$savedstate_preflight" >/dev/null
projectcaches_preflight="$("$BIN" clean --include-project-caches --preflight)"
grep 'project-caches' <<<"$projectcaches_preflight" >/dev/null
updaters_preflight="$("$BIN" clean --include-updater-caches --preflight)"
grep 'updater-caches' <<<"$updaters_preflight" >/dev/null
browsercaches_preflight="$("$BIN" clean --include-browser-caches --preflight)"
grep 'browser-caches' <<<"$browsercaches_preflight" >/dev/null
devicebackups_preflight="$("$BIN" clean --include-device-backups --preflight)"
grep 'device-backups' <<<"$devicebackups_preflight" >/dev/null
downloadartifacts_preflight="$("$BIN" clean --include-download-artifacts --preflight)"
grep 'download-artifacts' <<<"$downloadartifacts_preflight" >/dev/null
screenshots_preflight="$("$BIN" clean --include-screenshots --preflight)"
grep 'screenshots' <<<"$screenshots_preflight" >/dev/null
cleanroomstate_preflight="$("$BIN" clean --include-cleanroom-state --preflight)"
grep 'cleanroom-state' <<<"$cleanroomstate_preflight" >/dev/null
preflight_json="$(mktemp)"
"$BIN" clean --preset deep --include-ai-models --include-containers --include-user-trash --include-metadata --include-download-artifacts --include-screenshots --include-cleanroom-state --include-quicklook --include-font-caches --include-web-caches --include-saved-state --include-project-caches --include-updater-caches --include-browser-caches --include-device-backups --apply --trash --yes --preflight --json > "$preflight_json"
python3 -m json.tool "$preflight_json" >/dev/null
grep '"apply":true' "$preflight_json" >/dev/null
grep '"trash":true' "$preflight_json" >/dev/null
grep '"id":"containers"' "$preflight_json" >/dev/null
grep '"id":"metadata"' "$preflight_json" >/dev/null
grep '"id":"download-artifacts"' "$preflight_json" >/dev/null
grep '"id":"screenshots"' "$preflight_json" >/dev/null
grep '"id":"cleanroom-state"' "$preflight_json" >/dev/null
grep '"id":"quicklook"' "$preflight_json" >/dev/null
grep '"id":"font-caches"' "$preflight_json" >/dev/null
grep '"id":"web-caches"' "$preflight_json" >/dev/null
grep '"id":"saved-state"' "$preflight_json" >/dev/null
grep '"id":"project-caches"' "$preflight_json" >/dev/null
grep '"id":"updater-caches"' "$preflight_json" >/dev/null
grep '"id":"browser-caches"' "$preflight_json" >/dev/null
grep '"id":"device-backups"' "$preflight_json" >/dev/null
grep '"id":"user-trash"' "$preflight_json" >/dev/null
grep '"safety":"irreversible"' "$preflight_json" >/dev/null
grep 'Container cleanup can remove local containers' "$preflight_json" >/dev/null
grep 'User Trash cleanup is irreversible' "$preflight_json" >/dev/null
rm -f "$preflight_json"

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
download_artifacts_log="$(mktemp)"
rm -f "$download_artifacts_log"
"$BIN" clean --include-download-artifacts --days 30 --apply --trash --yes --log "$download_artifacts_log" >/dev/null 2>&1
grep 'old-download-artifact.tar.gz' "$download_artifacts_log" >/dev/null
test ! -e "$HOME/Downloads/old-download-artifact.tar.gz"
test -e "$HOME/Downloads/old-report.pdf"
"$BIN" restore --log "$download_artifacts_log" --apply --yes >/dev/null
test -e "$HOME/Downloads/old-download-artifact.tar.gz"
rm -f "$download_artifacts_log"
screenshots_log="$(mktemp)"
rm -f "$screenshots_log"
"$BIN" clean --include-screenshots --days 30 --apply --trash --yes --log "$screenshots_log" >/dev/null 2>&1
grep 'Screenshot 2026-06-01 at 10.00.00 PM.png' "$screenshots_log" >/dev/null
grep 'Screen Recording 2026-06-01 at 10.00.00 PM.mov' "$screenshots_log" >/dev/null
test ! -e "$HOME/Desktop/Screenshot 2026-06-01 at 10.00.00 PM.png"
test ! -e "$HOME/Downloads/Screen Recording 2026-06-01 at 10.00.00 PM.mov"
"$BIN" restore --log "$screenshots_log" --apply --yes >/dev/null
test -e "$HOME/Desktop/Screenshot 2026-06-01 at 10.00.00 PM.png"
test -e "$HOME/Downloads/Screen Recording 2026-06-01 at 10.00.00 PM.mov"
rm -f "$screenshots_log"
mkdir -p "$HOME/.local/state/cleanroom/runs" "$HOME/.local/state/cleanroom/snapshots" "$HOME/.Trash/cleanroom-old-state" "$HOME/.Trash/cleanroom-fresh-state"
printf 'old log\n' >"$HOME/.local/state/cleanroom/runs/old-run.log"
printf 'fresh log\n' >"$HOME/.local/state/cleanroom/runs/fresh-run.log"
printf '{"old":true}\n' >"$HOME/.local/state/cleanroom/snapshots/snapshot-old.json"
printf '{"fresh":true}\n' >"$HOME/.local/state/cleanroom/snapshots/snapshot-fresh.json"
printf 'old recoverable\n' >"$HOME/.Trash/cleanroom-old-state/item.txt"
printf 'fresh recoverable\n' >"$HOME/.Trash/cleanroom-fresh-state/item.txt"
touch -t 202001010000 "$HOME/.local/state/cleanroom/runs/old-run.log" "$HOME/.local/state/cleanroom/snapshots/snapshot-old.json" "$HOME/.Trash/cleanroom-old-state" "$HOME/.Trash/cleanroom-old-state/item.txt"
cleanroom_state_preview="$("$BIN" clean --include-cleanroom-state --days 30)"
grep 'old-run.log' <<<"$cleanroom_state_preview" >/dev/null
grep 'snapshot-old.json' <<<"$cleanroom_state_preview" >/dev/null
grep 'cleanroom-old-state' <<<"$cleanroom_state_preview" >/dev/null
cleanroom_state_log="$(mktemp)"
rm -f "$cleanroom_state_log"
"$BIN" clean --include-cleanroom-state --days 30 --apply --yes --log "$cleanroom_state_log" >/dev/null 2>&1
grep 'old-run.log' "$cleanroom_state_log" >/dev/null
grep 'snapshot-old.json' "$cleanroom_state_log" >/dev/null
grep 'cleanroom-old-state' "$cleanroom_state_log" >/dev/null
test ! -e "$HOME/.local/state/cleanroom/runs/old-run.log"
test ! -e "$HOME/.local/state/cleanroom/snapshots/snapshot-old.json"
test ! -e "$HOME/.Trash/cleanroom-old-state"
test -e "$HOME/.local/state/cleanroom/runs/fresh-run.log"
test -e "$HOME/.local/state/cleanroom/snapshots/snapshot-fresh.json"
test -e "$HOME/.Trash/cleanroom-fresh-state/item.txt"
rm -f "$cleanroom_state_log"

venv_log="$(mktemp)"
rm -f "$venv_log"
"$BIN" clean --include-venv-stale --days 30 --apply --trash --yes --log "$venv_log" >/dev/null 2>&1
grep '.venv' "$venv_log" >/dev/null
test ! -e "$HOME/Documents/python-app/.venv"
find "$HOME/.Trash" -name .venv -print -quit | grep .venv >/dev/null
rm -f "$venv_log"

mkdir -p "$HOME/.npm/_cacache"
printf 'cache again\n' >"$HOME/.npm/_cacache/example.cache"
PATH="/usr/bin:/bin:/usr/sbin:/sbin" "$BIN" clean --apply --trash --yes >/dev/null 2>&1
"$BIN" history --limit 1 | grep 'trash_entries=' >/dev/null
"$BIN" restore --apply --yes >/dev/null 2>&1
test -e "$HOME/.npm/_cacache"
rm -f "$apply_log"

rm -f "$config_file"

echo "smoke tests passed"
