# v0.1.0-beta.1 — HP M1136 macOS Compatibility Installer

- USB printing and scanning confirmed by the owner on an Apple Silicon Mac running macOS 26.6.1.
- Printing uses A4 and automatic paper feed; scanning uses macOS Image Capture.
- A DMG includes double-clickable Terminal installation and removal scripts.
- Installation downloads the original HP package from Apple, verifies its pinned SHA-256, and detects the connected M1136 USB URI.
- No HP binaries are bundled. This is a community compatibility installer, not a native ARM driver or an official HP release.

This is an unsigned, unnotarized beta. The component installation scripts were tested on the owner's Mac. The new combined installer has not been tested end to end on a clean Mac; Gatekeeper behavior after a browser download has not been verified. Rosetta is required on Apple Silicon. Existing component installations are not overwritten. Please report installation and device-discovery errors before changing security settings.
