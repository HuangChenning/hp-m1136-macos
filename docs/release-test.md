# Release test record

Use a Mac that has never installed this project's print or scan components. Fill in the result for each step; an unchecked box means it has not been verified. Testing the locally built candidate and testing the file downloaded from GitHub are separate runs.

## Test environment

| Field | Record |
| --- | --- |
| Date and tester |  |
| Mac model and architecture |  |
| macOS version |  |
| Candidate source (local DMG or GitHub release URL) |  |
| DMG filename and SHA-256 |  |
| Rosetta installed before test? |  |
| Printer connected directly by USB? |  |

## Procedure

- [ ] Confirm `/Library/Printers/hp-m1136-compat` and `/Library/Image Capture/Devices/HP M1130_M1210 Scanner.app` do not already exist. Do not remove unrelated drivers to make this test pass.
- [ ] Obtain both the candidate DMG and its `.sha256` file. For a published release, download both from its GitHub Releases page; record the release URL above. From their directory, run `shasum -a 256 -c hp-m1136-macos-0.1.1-rc.1.dmg.sha256` for this candidate (use the matching filename for another version) and record the output.
- [ ] Open the DMG and double-click `Install.command`. Record the exact Gatekeeper prompt or error, if any. Do not change system security settings as part of this test.
- [ ] Confirm installation finishes without errors. Record whether Rosetta or administrator authorization was requested and whether the HP download completed.
- [ ] Run `lpstat -p HP_M1136_Compat -v HP_M1136_Compat`. Print `test-page.pdf` with `lp -d HP_M1136_Compat -o PageSize=A4 -o InputSlot=Auto test-page.pdf`. Confirm the **physical page** has readable English and Chinese text and feeds automatically.
- [ ] Open Image Capture, select the M1136, scan at 150 dpi in grayscale, save a PDF, then open it and confirm the content is complete.
- [ ] Double-click `Uninstall.command`. Confirm `lpstat -p HP_M1136_Compat` no longer finds the queue, and both component paths from the first step are absent.

## Observed results

| Check | Result and exact error text if failed |
| --- | --- |
| Checksum |  |
| Gatekeeper |  |
| Install |  |
| Physical printing and paper feed |  |
| Image Capture scan and saved file |  |
| Uninstall |  |

## Local build check — 2026-10-04

These checks were run on the developer's existing Mac, **not** on a clean Mac. They do not establish end-to-end installer compatibility.

| Check | Result |
| --- | --- |
| `bash build-dmg.sh` | Passed; produced `dist/hp-m1136-macos-0.1.1-rc.1.dmg`. |
| `shasum -a 256 -c hp-m1136-macos-0.1.1-rc.1.dmg.sha256` | Passed; SHA-256 `824aff5ff8c21d1928d3d0c80f12bf4af0eae878a00ae2daff07fe09ff44f6df`. |
| `hdiutil verify dist/hp-m1136-macos-0.1.1-rc.1.dmg` | Passed; image checksum valid. |
| Mount and inspect contents | Passed; eight expected files matched the repository byte for byte. The four scripts were executable. No HP binaries appeared among the packaged files. |

Do not mark any procedure item complete from the local build checks alone.

An earlier local build used the published `0.1.0` filename with unpublished changes. Do not distribute that local file as v0.1.0; use the `0.1.1-rc.1` candidate above for further testing.

## Clean-Mac test availability

As of 2026-10-04, the current Mac already has this project's print and scanner components, so it is not a clean-install target. No local macOS virtual machine was found. The procedure above remains unrun until a separate clean Mac or a suitable USB-capable macOS VM is available.
