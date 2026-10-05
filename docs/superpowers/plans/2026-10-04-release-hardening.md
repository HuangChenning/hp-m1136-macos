# Compatibility Release Hardening Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` to implement this plan task by task. Checkboxes track verified work.

**Goal:** Make the published compatibility installer easier to validate and safer to run on a Mac that has not used it before.

**Architecture:** Keep the existing shell installer and Apple-hosted HP download. Add an early, read-only USB check before the 558 MiB download, document a repeatable release test, and leave OS-level installation and physical print/scan checks to a separate clean Mac.

**Tech Stack:** Bash, macOS CUPS, `hdiutil`, `shasum`, GitHub Releases.

**Spec:** `RELEASE_NOTES.md` and the "Install and first use" sections of `README.md` and `README.zh-CN.md` describe the current behavior and known verification gap.

## Global Constraints

- Preserve the working HP print filter, PPD modification, scanner component, queue name, and ownership markers.
- Do not bundle, modify, or re-sign HP binaries.
- Do not overwrite components that are already present.
- Do not claim clean-install compatibility until it is tested on a clean Mac.
- Native ARM printing/scanning is a separate project, not a requirement for this release.

## Review Focus

- No M1136 USB device: fail before downloading, with a useful message.
- Multiple matching M1136 USB devices: fail without choosing one arbitrarily.
- Device disconnects during download: recheck before installing.
- Existing installation: keep the current no-overwrite behavior.
- Download or checksum failure: leave installed components unchanged.

## Task 1: USB preflight

**Files:** `Install.command`, `README.md`, `README.zh-CN.md`.

- [x] Add a read-only USB check before `curl`; require exactly one matching `usb://...M1136...` URI.
- [x] Keep a second check after extraction so a disconnected or changed device cannot silently use the earlier URI.
- [x] Update both READMEs to say that the device is checked before the large download.
- [x] Verify Bash syntax and test no, one, and multiple USB matches plus `lpinfo` failure; CUPS listed the connected M1136; inspect the diff for unchanged install/uninstall behavior.

## Task 2: Release verification record

**Files:** `build-dmg.sh`, `docs/release-test.md`.

- [x] Set the new local build version to `0.1.1-rc.1` so it cannot be mistaken for the published v0.1.0 asset.
- [x] Record the exact steps to download the DMG from GitHub, verify SHA-256, install, print a bilingual page, scan and save, and uninstall on a clean Mac.
- [x] Include spaces to record architecture, macOS version, Gatekeeper result, and physical print/scan result; do not mark unrun checks as passed.
- [x] Build the `0.1.1-rc.1` DMG and verify its checksum, image integrity, contents, and script permissions.

## Task 3: Clean-Mac acceptance

**Files:** `docs/release-test.md`, `README.md`, `README.zh-CN.md`, `RELEASE_NOTES.md`.

- [ ] Run Task 2's procedure on a Mac without this project's components.
- [ ] Fix any failure found, then repeat the affected step.
- [ ] Update compatibility claims only with observed results.

## Later decisions

- Choose a license for this project's own scripts and documentation. Do not infer permission to relicense HP or Apple components.
- Assess Developer ID signing and notarization after the unsigned clean-install path is known to work. These steps require appropriate Apple credentials and separate compatibility verification.
- Scope a native ARM implementation independently, with separate USB protocol research and physical printer/scanner tests.
