cask "keepmacawake" do
  version "1.0.5"
  sha256 "cf8d41c32e665ae4b7ff7e0ee1bde941ed442b9611131440deb84e420bac7bc0"

  url "https://github.com/bartdudzic/keepmacawake/releases/download/v#{version}/KeepMacAwake-#{version}-arm64.pkg"
  name "Keep Mac Awake"
  desc "Keeps a MacBook awake with the lid closed, without an external display"
  homepage "https://keepmacawake.com/"

  livecheck do
    url :url
    strategy :github_latest
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :tahoe

  pkg "KeepMacAwake-#{version}-arm64.pkg"

  # The installed set has no uninstall script, so this runs the first steps of
  # the uninstaller package (Packaging/UninstallScripts/postinstall in
  # bartdudzic/keepmacawake) before pkgutil removes the files: quit the app,
  # stop the coordinator in every logged-in session, stop both services and
  # restore the sleep setting from their journal. If the restore fails, nothing
  # is removed, so it can run again. The first-session record stays, as with
  # the uninstaller package.
  uninstall script:  {
              executable: "/bin/bash",
              args:       ["-c", <<~'SH'],
                set -euo pipefail
                helper_dir=/Library/PrivilegedHelperTools/com.keepmacawake
                state='/Library/Application Support/KeepMacAwake'
                app='/Applications/Keep Mac Awake.app'
                for path in "$helper_dir" "$state" "$app"; do
                  [ ! -L "$path" ] || { echo 'Unexpected symbolic link; removal cancelled.' >&2; exit 1; }
                done
                pattern='^/Applications/Keep Mac Awake\.app/Contents/MacOS/Keep Mac Awake( |$)'
                if /usr/bin/pgrep -f "$pattern" >/dev/null 2>&1; then
                  /usr/bin/pkill -TERM -f "$pattern" >/dev/null 2>&1 || true
                  waited=0
                  while [ "$waited" -lt 50 ] && /usr/bin/pgrep -f "$pattern" >/dev/null 2>&1; do
                    /bin/sleep 0.2
                    waited=$((waited + 1))
                  done
                  /usr/bin/pkill -KILL -f "$pattern" >/dev/null 2>&1 || true
                fi
                for uid in $(/bin/ps -axo uid=,comm= | /usr/bin/awk '$2 ~ /loginwindow$/ && $1 != 0 {print $1}' | /usr/bin/sort -u); do
                  /bin/launchctl bootout "gui/$uid/com.keepmacawake.Coordinator" >/dev/null 2>&1 || true
                done
                for label in com.keepmacawake.Helper com.keepmacawake.Watchdog; do
                  if /bin/launchctl print "system/$label" >/dev/null 2>&1; then
                    /bin/launchctl kill SIGKILL "system/$label" >/dev/null 2>&1 || true
                    /bin/launchctl bootout "system/$label"
                  fi
                  if /bin/launchctl print "system/$label" >/dev/null 2>&1; then exit 1; fi
                done
                if [ -x "$helper_dir/KeepMacAwakeHelper" ]; then "$helper_dir/KeepMacAwakeHelper" --recover; fi
                link=/usr/local/bin/keepmacawake
                if [ -L "$link" ] && [ "$(/usr/bin/readlink "$link")" = "$app/Contents/MacOS/keepmacawake" ]; then
                  /bin/rm -f "$link"
                fi
                /bin/rm -f "$state/controller-heartbeat.json" "$state/watchdog-heartbeat.json" \
                  "$state/transaction.lock" "$state/relaunch-app"
                /bin/rm -rf "$state/update"
                /bin/rmdir "$state" 2>/dev/null || true
              SH
              sudo:       true,
            },
            pkgutil: "com.keepmacawake"

  zap trash: "~/Library/Preferences/com.keepmacawake.plist"
end
