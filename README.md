# HP M1136 for macOS

**USB printing and scanning for an HP LaserJet M1136 MFP on modern macOS.**

English · [简体中文](README.zh-CN.md)

[Download the DMG](https://github.com/HuangChenning/hp-m1136-macos/releases/tag/v0.1.0) · [Release notes](RELEASE_NOTES.md) · [Report an issue](https://github.com/HuangChenning/hp-m1136-macos/issues)

## Overview

A community compatibility installer that reuses the original HP printing and scanning components distributed by Apple. It is not an official HP release. The released DMG still uses Intel components; the repository also contains a separate [experimental native ARM printing path](native/README.md) that has printed one CUPS test job on the owner's Mac. Native scanning is not implemented.

> **Experimental:** the DMG is unsigned and unnotarized. The individual components work on the tested Mac; the combined installer has not been tested end to end on a clean Mac.

## Verified results

Confirmed by the printer owner on **one Apple Silicon Mac running macOS 26.6.1**, connected by USB:

| Function | Observed result |
| --- | --- |
| Printing | Test page printed correctly, including English and Chinese text |
| Paper feed | Automatic feed worked with paper already in the tray |
| Scanning | macOS Image Capture scanned and saved a file successfully |

Other Macs and macOS versions are unverified. A completed print queue alone does not prove that the page printed correctly.

## How it works

The installer downloads Apple's original HP 5.1.1 package (about **558 MiB**), verifies a pinned SHA-256, and extracts the M1136 components locally. It checks for exactly one connected M1136 before the download, checks its USB address again afterward, and installs:

- A separate **HP M1136 (Compatibility)** print queue, with **A4** and **automatic paper feed** as defaults. Your existing default printer is unchanged.
- The M1130/M1210 ICA scanner component, used by macOS **Image Capture**.

The release DMG contains our scripts, documentation, and a test page. The repository also includes attributed GPL source for the experimental native encoder. **HP binaries are not bundled.** The released Intel components require **Rosetta on Apple Silicon**.

## Install and first use

### Before you start

Connect exactly one powered-on M1136 by USB, install Rosetta if using Apple Silicon, and have an administrator password available. Internet access is required for the Apple download. Existing components are not overwritten.

### Install from the DMG

1. Download and open the [release DMG](https://github.com/HuangChenning/hp-m1136-macos/releases/tag/v0.1.0).
2. Double-click `Install.command`. It opens Terminal; it is not a graphical setup wizard.
3. Wait for the download and verification, then enter your administrator password when prompted.
4. Reconnect USB after installation. If the scanner is not detected, restart the Mac.

If macOS blocks the downloaded file or reports an error, record the exact message and [open an issue](https://github.com/HuangChenning/hp-m1136-macos/issues). Browser-download Gatekeeper behavior has not been verified; the scripts do not change system security settings.

### Print a test page

Choose **HP M1136 (Compatibility)** in an application's print dialog, or run this from the repository or mounted DMG directory:

```sh
lp -d HP_M1136_Compat -o PageSize=A4 -o InputSlot=Auto test-page.pdf
lpstat -p HP_M1136_Compat
```

Check the physical page for readable English and Chinese text. For everyday printing, use the same queue.

### Scan a document

Open **Image Capture**, select the M1136, and place the document face down on the scanner glass. Start with an overview, then try a **150 dpi grayscale scan** saved as PDF. Open the saved file and check that the content is complete.

## Troubleshooting

| Symptom | Next step |
| --- | --- |
| `Manual Feed` despite paper in the tray | For an earlier installation, run `sudo bash ./install.sh fix-feed` from the repository or DMG. Cancel affected jobs and resubmit; jobs retain their original paper-source setting. |
| Scanner missing from Image Capture | Reconnect USB, quit and reopen Image Capture, then restart the Mac if needed. |
| Existing components detected | Use this tool's uninstaller first. It does not overwrite unrelated drivers. |
| Security prompt or scan error | Report the exact message, Mac architecture, macOS version, and installation method. |

## Uninstall

Double-click `Uninstall.command` in the DMG. Alternatively, from the repository:

```sh
sudo bash ./install-scanner.sh uninstall
sudo bash ./install.sh uninstall
```

Only the queue and components marked as owned by this tool are removed. The two components can also be removed independently.

## Build from source

```sh
git clone https://github.com/HuangChenning/hp-m1136-macos.git
cd hp-m1136-macos
bash build-dmg.sh
```

The build produces a DMG and SHA-256 file under `dist/`. Building the DMG does not install drivers.

<details>
<summary>Advanced: manually install the original components</summary>

Download HP 5.1.1 from [Apple's official page](https://support.apple.com/en-us/106385). The following extraction directories must not already exist. Adjust the download path if necessary:

```sh
hdiutil attach ~/Downloads/HewlettPackardPrinterDrivers.dmg -readonly -nobrowse -mountpoint /tmp/hp-driver-volume
pkgutil --expand-full /tmp/hp-driver-volume/HewlettPackardPrinterDrivers.pkg /tmp/hp-expanded
lpinfo -v
```

Use the complete M1136 `usb://` address reported by `lpinfo -v` in place of `USB_URI`, then run these from the repository:

```sh
sudo bash ./install.sh install '/tmp/hp-expanded/HewlettPackardPrinterDrivers.pkg/Payload' 'USB_URI'
sudo bash ./install-scanner.sh install '/tmp/hp-expanded/HewlettPackardPrinterDrivers.pkg/Payload'
```

Printing components go into `/Library/Printers/hp-m1136-compat`. The scanner goes into `/Library/Image Capture/Devices/HP M1130_M1210 Scanner.app`. Other model drivers and old HP utilities are not installed.

</details>

## Limitations and third-party terms

Apple does not support this old package on modern macOS, and the tested system reports its old signature as invalid. Matching the download checksum does not replace signature validation. The tool does not remove quarantine attributes, re-sign HP components, or run the original installer.

HP components remain subject to their applicable terms. See [THIRD_PARTY.md](THIRD_PARTY.md) for provenance and limitations. Future macOS updates may break compatibility with the legacy components or CUPS drivers.
