#!/bin/bash
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
cd "$(dirname "$0")"
sudo -v
if [[ -f '/Library/Image Capture/Devices/.hp-m1136-compat-scanner' ]]; then
  sudo /bin/bash ./install-scanner.sh uninstall
fi
if [[ -f /Library/Printers/hp-m1136-compat/.installed-by-hp-m1136-compat ]]; then
  sudo /bin/bash ./install.sh uninstall
fi
echo 'Removal complete. Only components owned by this tool were removed.'
read -r -p 'Press Enter to close.'
