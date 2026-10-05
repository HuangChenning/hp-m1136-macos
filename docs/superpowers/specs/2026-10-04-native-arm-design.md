# Native Apple Silicon Development Design

## Goal and scope

Build an Apple Silicon print path for the HP LaserJet M1136 MFP that does not execute the original HP Intel print filter or require Rosetta. Keep the published compatibility installer intact while the native path is experimental. Native scanning is a separate phase because the scanner USB protocol and macOS integration have not yet been established.

## Printing approach

Use the `foo2xqx` monochrome ZJS encoder from OpenPrinting's `foo2zjs` repository at commit `80499ed5bf6caa2963ad337e37cfda78a80aab1e`. Its model database lists the M1136 and its source includes JBIG-KIT. Build the encoder as an arm64 executable. For the first hardware probe, render one A4 PDF to PBM with arm64 Ghostscript, encode it with A4/automatic-feed settings, and submit the resulting stream through the macOS USB backend directly. macOS 26 rejects raw CUPS queue creation. This probe is a developer tool, not a user installer or a claim of reliable printing.

If the physical page succeeds, implement a native CUPS raster input path so normal macOS print jobs need neither Ghostscript nor Rosetta at runtime. Do not replace the existing compatibility queue during development.

## Boundaries and attribution

Keep upstream GPL-2.0-or-later source and its license notice together in `native/third_party/foo2zjs`. Record the exact upstream commit and file list. The new native module is separate from the HP compatibility installer; no HP binary is copied into it. Distribution of a compiled native binary must include corresponding source and license information. Do not call the encoder newly written by this project.

## Validation

- `file` or `lipo -archs` reports arm64 for the encoder.
- A known A4 PDF produces a nonempty ZJS stream without invoking an Intel process.
- A directly connected M1136 physically prints a readable A4 test page with automatic feed; inspect the page, not only the queue status.
- Repeat with varied pages before treating the path as reliable, because an M1136 user has reported occasional garbling with `foo2xqx`.
- Keep the native build artifacts separate from the published `v0.1.0` compatibility release; leave the compatibility queue unchanged.

## Native scanning phase

First identify the USB scanner interface and capture a reproducible read-only capability exchange. Then implement an arm64 scan command that saves a complete file, followed by macOS Image Capture integration if a supported interface is available. This phase needs its own protocol findings, plan, and physical tests; no scanning claim follows from a successful print probe.

## Sources

- OpenPrinting model entry: https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/foomatic-db/printer/HP-LaserJet_Pro_M1136_MFP.xml
- Encoder source: https://github.com/OpenPrinting/foo2zjs/blob/main-fixes/foo2xqx.c
- M1136 garbling report: https://github.com/OpenPrinting/foo2zjs/issues/6
