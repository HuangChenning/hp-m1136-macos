#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
cd "$(dirname "$0")"
work=$(mktemp -d /private/tmp/hp-m1136-install.XXXXXX)
mounted=false
cleanup() {
  if $mounted; then hdiutil detach "$work/volume" >/dev/null || true; fi
  rm -rf "$work"
}
trap cleanup EXIT
trap 'echo "Installation failed. See the error above." >&2' ERR
echo 'HP M1136 macOS Compatibility Installer'
echo 'Downloads the original HP package from Apple (about 558 MiB).'
echo 'Requires Rosetta on Apple Silicon. No HP binaries are included in this release.'
if [[ -e /Library/Printers/hp-m1136-compat || -e '/Library/Image Capture/Devices/HP M1130_M1210 Scanner.app' ]]; then
  echo 'Existing components detected. Uninstall this tool first; existing drivers will not be overwritten.' >&2
  exit 1
fi
curl --fail --location --proto '=https' --proto-redir '=https' \
  --connect-timeout 30 --max-time 1200 \
  -o "$work/hp.dmg" \
  'https://updates.cdn-apple.com/2021/macos/071-46903-20211101-0BD2764A-901C-41BA-9573-C17B8FDC4D90/HewlettPackardPrinterDrivers.dmg'
printf '%s  %s\n' '523836b630431bc39b0170a17099099d6f821ef62ff29e6ec64ebb69b9954133' "$work/hp.dmg" | shasum -a 256 -c -
hdiutil attach "$work/hp.dmg" -readonly -nobrowse -mountpoint "$work/volume"
mounted=true
pkgutil --expand-full "$work/volume/HewlettPackardPrinterDrivers.pkg" "$work/expanded"
payload="$work/expanded/HewlettPackardPrinterDrivers.pkg/Payload"
uri=$(lpinfo -v | awk '$1 == "direct" && $2 ~ /^usb:\/\// && $2 ~ /M1136/ { print $2 }')
[[ -n "$uri" && "$uri" != *$'\n'* ]] || { echo 'Connect exactly one powered-on M1136 via USB and try again.' >&2; exit 1; }
echo 'Administrator password is required to install the two components.'
sudo -v
sudo /bin/bash ./install.sh install "$payload" "$uri"
if ! sudo /bin/bash ./install-scanner.sh install "$payload"; then
  echo 'Scanner installation failed; rolling back this installation.' >&2
  if [[ -f '/Library/Image Capture/Devices/.hp-m1136-compat-scanner' ]]; then
    sudo /bin/bash ./install-scanner.sh uninstall
  fi
  sudo /bin/bash ./install.sh uninstall
  exit 1
fi
echo 'Installed. Select HP M1136 (Compatibility) to print.'
echo 'Reconnect USB and open Image Capture to scan. If not detected, restart your Mac.'
echo 'See README.md for test steps and limitations.'
read -r -p 'Press Enter to close.'
