# Native CUPS Raster Input Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` to implement this plan task by task. Checkboxes track verified work.

**Goal:** Convert macOS CUPS grayscale raster pages into A4 PBM input for the validated arm64 `foo2xqx` encoder, without Ghostscript in the print-time path.

**Architecture:** A small arm64 C program reads CUPS raster through libcups, accepts one 600 dpi A4 8-bit grayscale page, pads its imaging area to the printer's 4960×7016 bitmap, and emits PBM. The encoder remains a separate executable. Unsupported formats fail clearly instead of printing malformed data.

**Tech Stack:** C, Apple clang, libcups, CUPS Raster API.

**Spec:** `docs/superpowers/specs/2026-10-04-native-arm-design.md`.

## Constraints

- Preserve the working compatibility queue; do not install this converter as a system filter until offline output is verified.
- First version handles exactly one A4 page in 8-bit grayscale at 600×600 dpi. Other jobs fail with an explanatory message.
- Use the raster header's imaging box to position pixels on the full page, with white padding outside it.
- Keep the OpenPrinting GPL encoder as a separate binary and preserve source attribution.

## Task 1: Raster converter

**Files:** `native/cups2pbm.c`, `native/build.sh`.

- [x] Read one CUPS raster page using `cupsRasterReadHeader2` and `cupsRasterReadPixels`.
- [x] Validate A4, 600×600 dpi, 8-bit grayscale, dimensions, and imaging-box offsets before writing output.
- [x] Emit a 4960×7016 P4 PBM, padding outside the image in white and thresholding grayscale at 128.
- [x] Reject a second page and truncated input rather than emit a partial print stream.
- [x] Build the converter as arm64 and verify syntax/warnings.

## Task 2: Offline pipeline

**Files:** `native/README.md`, `docs/native-print-test.md`.

- [x] Convert the repository PDF to CUPS raster with `cupsfilter` and inspect its header.
- [x] Run `cups2pbm | foo2xqx` to produce one ZJS stream; decode and confirm A4/600 dpi/automatic feed.
- [x] Compare the generated raster visually with the PDF and record only observed results.

## Task 3: Normal macOS printing

**Files:** `native/HP-M1136-Native.ppd`, `native/rastertozjs`, `native/install-experimental.sh`, `native/uninstall-experimental.sh`, `native/README.md`.

- [x] Write and validate an A4-only PPD whose CUPS raster filter is the new native wrapper.
- [x] Make the wrapper pipe `cups2pbm` into `foo2xqx`; the converter validates and buffers the page before emitting PBM data.
- [x] Install a separate `HP_M1136_Native_Experimental` queue without modifying the compatibility queue or default printer.
- [x] Print a normal PDF job through the CUPS queue and inspect the physical page.
- [x] Remove the experimental queue with its own uninstaller and verify the compatibility queue remains.
- [ ] Test a print submitted from a macOS graphical application.
