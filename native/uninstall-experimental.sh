#!/bin/bash
set -euo pipefail
target=/Library/Printers/hp-m1136-native
queue=HP_M1136_Native_Experimental
[[ -f "$target/.installed-by-hp-m1136-native" ]] || { echo 'No native installation owned by this project was found.' >&2; exit 1; }
sudo -v
if lpstat -p "$queue" >/dev/null 2>&1; then sudo lpadmin -x "$queue"; fi
sudo rm -rf "$target"
echo 'Experimental native queue and components removed.'
