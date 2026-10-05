# Native ARM scanning investigation plan

**Goal:** Determine whether M1136 scanning can be implemented on Apple Silicon without HP's Intel scanner component or a redistributed HP plug-in.

**Known facts:** The device exposes a vendor-specific `HP SCAN` USB interface. HPLIP 3.25.8 marks the model `MARVELL2`, and its open scanner backend loads a missing `bb_marvell` library for scan operations. See `docs/native-scanner-research.md`.

1. [x] Identify the physical USB scan interface and HPLIP model protocol selection. Verify with `ioreg` and the official HPLIP source archive.
2. [ ] Map the public Marvell2 transport, scan request/response framing, and `bb_*` boundary. Verify each claim against source or a reproducible observation; keep unrelated USB interfaces untouched.
3. [ ] If enough protocol behavior is documented, write the smallest arm64 command that scans one flatbed grayscale page to a file. Verify the file opens and the physical page content is complete.
4. [ ] Only after step 3, assess macOS Image Capture integration and packaging. Preserve the working compatibility scanner throughout.

If step 2 cannot establish the necessary behavior without proprietary code, record the missing protocol details and keep native scanning out of the release.
