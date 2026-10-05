# Native ARM Printing Probe Implementation Plan

> **For agentic workers:** Use `superpowers:executing-plans` to implement this plan task by task. Checkboxes track verified work.

**Goal:** Produce and physically test an arm64 ZJS print stream for the M1136 without the HP Intel print filter.

**Architecture:** Build a pinned OpenPrinting `foo2xqx` encoder with its bundled JBIG source. Render a test PDF to PBM with arm64 Ghostscript for the first device probe, then send the encoded stream via a separate experimental CUPS USB queue.

**Tech Stack:** Apple clang, C, Bash, Ghostscript (probe only), CUPS, USB.

**Spec:** `docs/superpowers/specs/2026-10-04-native-arm-design.md`.

## Constraints

- Preserve the current compatibility installation and its queue.
- Do not include HP binaries in the native module.
- Keep upstream GPL notices and exact commit attribution.
- No release or claim of native scanning from this print probe.

## Task 1: Reproducible arm64 encoder

**Files:** `native/third_party/foo2zjs/*`, `native/build.sh`, `native/README.md`.

- [x] Copy only `foo2xqx.c`, `xqx.h`, `jbig.c`, `jbig.h`, `jbig_ar.c`, `jbig_ar.h`, and `COPYING` from the pinned upstream commit; record provenance.
- [x] Build with `clang -arch arm64`; write the binary under an ignored local build directory.
- [x] Verify architecture and command-line help without Rosetta.

## Task 2: Offline A4 stream

**Files:** `native/probe-print.sh`, `native/README.md`.

- [x] Render `test-page.pdf` to 4960×7016 PBM at 600 dpi with arm64 Ghostscript.
- [x] Encode one A4 page with `foo2xqx -r600x600 -g4960x7016 -p9 -T3 -m1 -s7 -d1 -n1`.
- [x] Verify the output is nonempty and begins with a PJL job; decode its page attributes and record the generated file hash and size.

## Task 3: Physical print probe

**Files:** `native/README.md`, `docs/native-print-test.md`.

- [x] Confirm the M1136 USB URI. macOS 26 rejected creation of a raw CUPS queue, so use the system USB backend directly for this one-page probe; do not modify the compatibility queue.
- [x] Send only the generated test stream through the arm64e system USB backend and inspect the physical A4 page, including automatic feed and readable English/Chinese text.
- [x] Record the observed result: owner confirmed normal physical output. No experimental queue needs removal because none was created.

## Later work

- Implement a CUPS raster-to-encoder path only after a successful physical stream test.
- Scope native scanning from USB protocol findings in a separate plan.
