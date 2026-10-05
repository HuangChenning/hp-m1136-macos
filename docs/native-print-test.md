# Native ARM print probe — 2026-10-04

This is a development probe, not a completed driver test. The published compatibility installer and its CUPS queue were not changed.

| Check | Observation |
| --- | --- |
| Encoder source | OpenPrinting `foo2zjs` commit `80499ed5bf6caa2963ad337e37cfda78a80aab1e`, with bundled JBIG-KIT. |
| Encoder architecture | `native/build/foo2xqx` is Mach-O arm64; SHA-256 `3c82a7f1a1882d8af3c7bbe5b6274b5b99cedcaab6b676cda22ee0cbdd0eeced`. |
| Rasterizer architecture | `/opt/homebrew/bin/gs` reports arm64. |
| Test stream | `native/build/test-page.zjs` is 4,340 bytes; SHA-256 `cd34347743c4d16d4eaafc64d17448a882cab1a38bcf469931c83527e5d6bd97`. |
| Stream decode | OpenPrinting `xqxdecode` reports one page, A4 paper code 9, 600×600 dpi, automatic source code 7, and normal end-of-page/end-of-document records. |
| Raw queue creation | macOS 26 refused `lpadmin -m raw` with `macOS不再支持原始队列`; no queue was created. |
| USB backend submission | macOS arm64e USB backend returned exit code 0 and logged `Sent 4340 bytes` and `PAGE: 1 1`. |
| Physical page | Printer owner confirmed one A4 test page physically printed with readable English and Chinese text and automatic feed. |

This confirms the single-page native print probe on the owner's M1136. It does not prove that repeated jobs are reliable. The known [M1136 garbling report](https://github.com/OpenPrinting/foo2zjs/issues/6) requires varied-page testing before release.

## CUPS raster conversion probe

An arm64 `cups2pbm` converter read macOS's 600 dpi, 8-bit grayscale CUPS raster for the test PDF, padded the imaging area to a 4960×7016 A4 bitmap, and fed that bitmap to the arm64 encoder. A preview of the bitmap showed the English and Chinese text in the expected area. A second USB backend submission returned success and logged `Sent 4362 bytes`; the printer owner confirmed the second physical page printed clearly. Multi-page, truncated, and Letter-size raster inputs were rejected without emitting PBM output. This remains a developer pipeline, not yet a normal application print queue.

## Experimental CUPS queue — 2026-10-05

The separate `HP_M1136_Native_Experimental` queue was installed without replacing `HP_M1136_Compat`. Its PPD passed `cupstestppd`; installed `foo2xqx` and `cups2pbm` are Mach-O arm64. A PDF submitted with `lp -d HP_M1136_Native_Experimental -o PageSize=A4 test-page.pdf` became job 79. CUPS marked it completed, and the printer owner confirmed one A4 page printed with clear English and Chinese text and automatic feed.

The earlier queue attempts did not validate the filter: the printer was initially offline, then jobs 77 and 78 failed because the CUPS filter sandbox refused a temporary directory in `/private/tmp` and reopening `/dev/stdin`. The wrapper now pipes directly and reads its inherited standard input; offline checks of both standard-input and file-argument modes produced a 4,362-byte stream. Failed jobs were canceled before the successful retry. This is one successful CUPS queue job, not evidence of repeated-job reliability or graphical-app printing.

After the test, the project's uninstaller removed `HP_M1136_Native_Experimental` and `/Library/Printers/hp-m1136-native`. `HP_M1136_Compat` remained installed and idle.
