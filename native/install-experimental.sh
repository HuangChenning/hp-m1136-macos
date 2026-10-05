#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
target=/Library/Printers/hp-m1136-native
queue=HP_M1136_Native_Experimental
marker="$target/.installed-by-hp-m1136-native"
[[ $(uname -m) == arm64 ]] || { echo 'Apple Silicon is required.' >&2; exit 1; }
[[ ! -e "$target" ]] || { echo 'Native target already exists; no files overwritten.' >&2; exit 1; }
if lpstat -p "$queue" >/dev/null 2>&1; then echo 'Experimental queue already exists.' >&2; exit 1; fi
for file in build/foo2xqx build/cups2pbm build/rastertozjs; do
  [[ -x "$file" ]] || { echo "Missing $file; run bash native/build.sh first." >&2; exit 1; }
done
uri=$(lpinfo -v | awk '$1 == "direct" && $2 ~ /^usb:\/\// && $2 ~ /M1136/ { print $2 }')
[[ -n "$uri" && "$uri" != *$'\n'* ]] || { echo 'Connect exactly one M1136 by USB.' >&2; exit 1; }
sudo -v
sudo mkdir -p "$target"
rollback() { sudo lpadmin -x "$queue" >/dev/null 2>&1 || true; sudo rm -rf "$target"; }
trap rollback ERR
sudo touch "$marker"
sudo cp build/foo2xqx build/cups2pbm build/rastertozjs HP-M1136-Native.ppd "$target/"
sudo chown -R root:wheel "$target"
sudo chmod 755 "$target/foo2xqx" "$target/cups2pbm" "$target/rastertozjs"
sudo chmod 644 "$target/HP-M1136-Native.ppd"
sudo lpadmin -p "$queue" -E -v "$uri" -P "$target/HP-M1136-Native.ppd" -D 'HP M1136 Native Experimental' -o printer-is-shared=false -o PageSize=A4
trap - ERR
echo 'Experimental native queue installed. It supports one A4 page per job.'
