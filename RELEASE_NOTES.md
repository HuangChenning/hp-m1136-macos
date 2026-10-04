# v0.1.0 — HP M1136 macOS Compatibility Installer

The first GitHub Latest release packages USB printing and scanning support for the HP LaserJet M1136 MFP, with English and Chinese instructions. The driver components and installation flow are unchanged from v0.1.0-beta.2.

- The printer owner confirmed printing a bilingual test page and saving a scan with Image Capture on one Apple Silicon Mac running macOS 26.6.1.
- The DMG contains Terminal-based installation and removal scripts, both READMEs, and a test page.
- The installer downloads the original HP package from Apple and verifies a pinned SHA-256. HP binaries are not bundled.

**Experimental limitations:** The DMG is unsigned and unnotarized. The combined installer has not been tested end to end on a clean Mac, and Gatekeeper behavior after a browser download has not been verified. The HP Intel components require Rosetta on Apple Silicon. This is a community compatibility installer, not a native ARM driver or an official HP release. See the README before installation.
