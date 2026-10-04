#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
version=0.1.0-beta.1
stage=$(mktemp -d /private/tmp/hp-m1136-release.XXXXXX)
trap 'rm -rf "$stage"' EXIT
mkdir -p dist
for file in Install.command Uninstall.command install.sh install-scanner.sh README.md THIRD_PARTY.md test-page.pdf; do
  cp "$file" "$stage/"
done
chmod 755 "$stage/"*.command "$stage/"*.sh
hdiutil create -ov -format UDZO -volname 'HP M1136 macOS' -srcfolder "$stage" "dist/hp-m1136-macos-$version.dmg"
shasum -a 256 "dist/hp-m1136-macos-$version.dmg" > "dist/hp-m1136-macos-$version.dmg.sha256"
