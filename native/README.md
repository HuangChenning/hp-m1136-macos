# Experimental native ARM printing

This directory builds an **arm64** `foo2xqx` encoder and an experimental CUPS queue for the HP M1136. The separate queue leaves the working compatibility driver in place. `foo2xqx` is OpenPrinting code, not an encoder newly written by this project. Native scanning is not implemented here.

## Source and license

The unmodified files in `third_party/foo2zjs/` come from [OpenPrinting/foo2zjs](https://github.com/OpenPrinting/foo2zjs/tree/80499ed5bf6caa2963ad337e37cfda78a80aab1e), commit `80499ed5bf6caa2963ad337e37cfda78a80aab1e`: `foo2xqx.c`, `xqx.h`, `jbig.c`, `jbig.h`, `jbig_ar.c`, `jbig_ar.h`, and `COPYING`. They are licensed under GPL-2.0-or-later; see the included license and source notices. No HP binary is included in this directory.

## Build and make a test stream

On Apple Silicon with the Xcode command-line tools and an arm64 `gs` (Ghostscript) executable:

```sh
bash native/build.sh
bash native/probe-print.sh
file native/build/foo2xqx
file native/build/test-page.zjs
```

The probe renders the repository's test PDF as one 600 dpi A4 monochrome page, then encodes it with automatic feed. It writes `native/build/test-page.zjs` and **does not print it**. Ghostscript is required only for this development probe; the experimental CUPS queue uses a macOS CUPS raster input path.

OpenPrinting lists the M1136 for `foo2xqx`, but [an M1136 report](https://github.com/OpenPrinting/foo2zjs/issues/6) describes occasional garbled output. Two distinct one-page physical probes have printed clearly on the owner's device; repeated and varied jobs still need validation before release.

## Experimental CUPS queue

The arm64 `cups2pbm` program accepts one A4, 600 dpi, 8-bit grayscale CUPS raster page. The `rastertozjs` wrapper feeds its PBM output to the arm64 encoder. A project-authored PPD restricts the queue to that input. This path does not call Ghostscript or the HP Intel print filter at print time.

To test a normal macOS print job on the connected M1136:

```sh
bash native/build.sh
bash native/install-experimental.sh
lp -d HP_M1136_Native_Experimental -o PageSize=A4 test-page.pdf
bash native/uninstall-experimental.sh
```

The installer creates a separate **HP M1136 Native Experimental** queue and does not change the compatibility queue. It requires administrator authorization and refuses to overwrite an existing native installation. The uninstaller removes only components marked as owned by this native prototype. Inspect the physical page before calling a test successful. This prototype currently rejects multi-page jobs and other paper sizes.
