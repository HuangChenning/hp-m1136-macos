#!/bin/bash
# Uses the original HP binaries extracted from Apple's driver package.
set -euo pipefail
export PATH=/usr/bin:/bin:/usr/sbin:/sbin
queue=HP_M1136_Compat
target=/Library/Printers/hp-m1136-compat
marker="$target/.installed-by-hp-m1136-compat"

die() { echo "ERROR: $*" >&2; exit 1; }
automatic_feed() {
    sed -e 's/^\*DefaultInputSlot: Manual$/*DefaultInputSlot: Auto/' \
        -e '/^\*InputSlot Manual\//i\
*InputSlot Auto/Automatic Feed: "<</MediaPosition 7 /ManualFeed false>>setpagedevice"\
*de.InputSlot Auto/Automatisch: ""\
*es.InputSlot Auto/Automatica: ""\
*fr.InputSlot Auto/Automatique: ""\
*it.InputSlot Auto/Automatica: ""\
*nl.InputSlot Auto/Automatisch: ""'
}
[[ $(uname -s) == Darwin ]] || die 'macOS required'
[[ $EUID == 0 ]] || die "Run with sudo: $0 install PAYLOAD USB_URI (or fix-feed / uninstall)"
case "${1:-}" in
  fix-feed)
    [[ -f "$marker" ]] || die 'No installation owned by this tool was found'
    if ! /usr/bin/grep -q '^\*InputSlot Auto/' "$target/hp1130.ppd"; then
      automatic_feed < "$target/hp1130.ppd" > "$target/hp1130.ppd.new"
      cupstestppd -q "$target/hp1130.ppd.new"
      mv "$target/hp1130.ppd.new" "$target/hp1130.ppd"
    fi
    lpadmin -p "$queue" -P "$target/hp1130.ppd" -o InputSlot=Auto -o PageSize=A4
    lpoptions -p "$queue" -l
    ;;
  uninstall)
    [[ -f "$marker" ]] || die 'No installation owned by this tool was found'
    if lpstat -p "$queue" >/dev/null 2>&1; then lpadmin -x "$queue"; fi
    rm -rf "$target"
    echo 'Compatibility driver and queue removed.'
    ;;
  install)
    [[ $# == 3 ]] || die 'Usage: sudo ./install.sh install PAYLOAD USB_URI'
    payload=$2
    uri=$3
    [[ "$uri" == usb://*M1136* ]] || die 'Supply the M1136 USB URI reported by lpinfo -v'
    [[ ! -e "$target" ]] || die 'Destination already exists; uninstall this tool first'
    if lpstat -p "$queue" >/dev/null 2>&1; then die 'Queue already exists'; fi
    bundle="$payload/Library/Printers/hp/laserjet/M1130_1210series/HPM1210_1130Raster.bundle"
    ppd="$payload/Library/Printers/PPDs/Contents/Resources/hp1130.ppd.gz"
    [[ -f "$ppd" && -x "$bundle/Contents/MacOS/rastertozjs" ]] || die 'Incorrect expanded HP package payload'
    # Fail before installation if Rosetta or a required library is unavailable.
    set +e
    "$bundle/Contents/MacOS/rastertozjs" </dev/null >/dev/null 2>&1
    probe=$?
    set -e
    [[ $probe == 1 ]] || die "HP filter could not start (exit $probe)"
    mkdir -p "$target"
    touch "$marker"
    trap 'echo "Installation failed. Run sudo ./install.sh uninstall to clean up." >&2' ERR
    ditto "$bundle" "$target/HPM1210_1130Raster.bundle"
    gzip -dc "$ppd" | sed \
      -e 's|/Library/Printers/hp/laserjet/M1130_1210series/HPM1210_1130Raster.bundle|/Library/Printers/hp-m1136-compat/HPM1210_1130Raster.bundle|g' \
      -e '/^\*APPrinterIconPath:/d' \
      -e '/^\*APPrinterUtilityPath:/d' | automatic_feed > "$target/hp1130.ppd"
    chown -R root:wheel "$target"
    chmod -R go-w "$target"
    cupstestppd -q "$target/hp1130.ppd"
    lpadmin -p "$queue" -E -v "$uri" -P "$target/hp1130.ppd" -D 'HP M1136 (Compatibility)' -o printer-is-shared=false -o PageSize=A4 -o InputSlot=Auto
    lpstat -p "$queue" -v "$queue"
    echo 'Queue installed. Printing still requires a successful physical test.'
    ;;
  *) die 'Usage: sudo ./install.sh install PAYLOAD USB_URI | fix-feed | uninstall' ;;
esac
