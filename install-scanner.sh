#!/bin/bash
# Install only the original M1130/M1210 ICA scanner from Apple's HP package.
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
devices='/Library/Image Capture/Devices'
name='HP M1130_M1210 Scanner.app'
target="$devices/$name"
marker="$devices/.hp-m1136-compat-scanner"
die() { echo "ERROR: $*" >&2; exit 1; }
[[ $(uname -s) == Darwin ]] || die 'macOS required'
[[ $EUID == 0 ]] || die 'Run with sudo'
case "${1:-}" in
  install)
    [[ $# == 2 ]] || die 'Usage: sudo bash install-scanner.sh install PAYLOAD'
    source="$2/Library/Image Capture/Devices/$name"
    [[ -x "$source/Contents/MacOS/HP Scanner" ]] || die 'Expanded HP scanner payload not found'
    [[ ! -e "$target" && ! -e "$marker" ]] || die 'Scanner destination already exists; no files overwritten'
    plutil -lint "$source/Contents/Info.plist"
    plutil -lint "$source/Contents/Resources/DeviceMatchingInfo.plist"
    mkdir -p "$devices"
    touch "$marker"
    trap 'echo "Install failed; use this script with uninstall to clean up." >&2' ERR
    ditto "$source" "$target"
    chown -R root:wheel "$target"
    chmod -R go-w "$target"
    echo 'ICA scanner installed. Reconnect USB, then open Image Capture and test scanning.'
    ;;
  uninstall)
    [[ -f "$marker" ]] || die 'No scanner installation owned by this tool was found'
    rm -rf "$target"
    rm "$marker"
    echo 'Compatibility scanner removed. Printing configuration unchanged.'
    ;;
  *) die 'Usage: sudo bash install-scanner.sh install PAYLOAD | uninstall' ;;
esac
