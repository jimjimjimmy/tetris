#!/bin/sh

# ci_post_clone.sh -- Xcode Cloud post-clone build step.
#
# Xcode Cloud clones a fresh copy of the repo, then resolves Swift Package
# Manager dependencies and archives. Capacitor's iOS integration
# (ios/App/CapApp-SPM/Package.swift, which is CLI-managed -- do not edit it)
# references the plugin packages by LOCAL path into node_modules/@capacitor/*:
#
#   .package(name: "CapacitorHaptics",     path: "../../../node_modules/@capacitor/haptics")
#   .package(name: "CapacitorSplashScreen", path: "../../../node_modules/@capacitor/splash-screen")
#   .package(name: "CapacitorStatusBar",   path: "../../../node_modules/@capacitor/status-bar")
#
# node_modules is gitignored, so those paths don't exist on a fresh clone and
# SPM resolution fails. This script restores them by installing the npm
# dependencies and running `cap sync ios` BEFORE Xcode Cloud resolves packages
# and archives. (The plugins are subdirectory packages inside their npm
# tarballs, so they cannot be referenced as remote `.package(url:)` git deps --
# regenerating the local node_modules is the supported fix.)

set -e

# Xcode Cloud sets CI_PRIMARY_REPOSITORY_PATH to the cloned repo root (where
# package.json lives). Fall back to one level up from this script otherwise.
REPO_ROOT="${CI_PRIMARY_REPOSITORY_PATH:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$REPO_ROOT"
echo "[ci_post_clone] repo root: $REPO_ROOT"

# Xcode Cloud build images do not ship Node. Install it via the preinstalled
# Homebrew if it is not already on PATH.
if ! command -v node >/dev/null 2>&1; then
  echo "[ci_post_clone] Node not found -- installing via Homebrew"
  export HOMEBREW_NO_INSTALL_CLEANUP=1
  export HOMEBREW_NO_AUTO_UPDATE=1
  brew install node
fi
echo "[ci_post_clone] using node $(node -v), npm $(npm -v)"

# Install JS deps from the committed lockfile (reproducible), then regenerate
# the native iOS project + plugin SPM references against the restored
# node_modules.
npm ci
npx cap sync ios

echo "[ci_post_clone] done -- node_modules restored, cap sync ios complete"
