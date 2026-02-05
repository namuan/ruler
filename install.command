#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Ruler"

BUILD_DIR="$ROOT_DIR/build"
APP_DIR="$BUILD_DIR/${APP_NAME}.app"

INSTALL_DIR="$HOME/Applications"
INSTALL_APP="$INSTALL_DIR/${APP_NAME}.app"

echo "Building (Release)..."
cd "$ROOT_DIR"
swift build -c release --product "$APP_NAME"

BIN_PATH="$ROOT_DIR/.build/release/$APP_NAME"
if [[ ! -f "$BIN_PATH" ]]; then
  echo "Build output not found: $BIN_PATH" >&2
  exit 1
fi

echo "Assembling app bundle..."
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/$APP_NAME"
cp "$ROOT_DIR/App/Info.plist" "$APP_DIR/Contents/Info.plist"

if command -v codesign >/dev/null 2>&1; then
  echo "Code signing (ad-hoc)..."
  codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true
fi

echo "Installing to ~/Applications..."
mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_APP"
mv "$APP_DIR" "$INSTALL_APP"

echo "Installed: $INSTALL_APP"
