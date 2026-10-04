# v0.1.0-beta.2 — HP M1136 macOS Compatibility Installer

This beta packages the existing USB printing and scanning compatibility installer with both English and Chinese instructions. It also includes the test page and a standalone SHA-256 file for the DMG. There are no changes to the print or scan components in this release.

- USB printing and scanning were confirmed by the owner on one Apple Silicon Mac running macOS 26.6.1.
- Printing uses A4 and automatic paper feed; scanning uses macOS Image Capture.
- The DMG contains double-clickable Terminal installation and removal scripts. The installer downloads the original HP package from Apple, checks its pinned SHA-256, and detects the M1136 USB address.
- No HP binaries are bundled. The original Intel components require Rosetta on Apple Silicon. This is a community compatibility installer, not a native ARM driver or an official HP release.

The DMG is unsigned and unnotarized. The combined installer has not been tested end to end on a clean Mac, and Gatekeeper behavior after a browser download has not been verified. Existing component installations are not overwritten. See the repository README for installation, test, and removal instructions.
