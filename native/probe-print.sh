#!/bin/bash
# Developer-only offline stream probe; this script does not send a job.
set -euo pipefail
cd "$(dirname "$0")"
[[ -x build/foo2xqx ]] || { echo 'Run bash native/build.sh first.' >&2; exit 1; }
gs_bin=$(command -v gs) || { echo 'arm64 Ghostscript is required for this probe.' >&2; exit 1; }
[[ "$(/usr/bin/lipo -archs "$gs_bin")" == *arm64* ]] || { echo 'Ghostscript must support arm64.' >&2; exit 1; }
tmp=$(mktemp -d /private/tmp/hp-m1136-native.XXXXXX)
trap 'rm -rf "$tmp"' EXIT
"$gs_bin" -q -dBATCH -dSAFER -dNOPAUSE -dFirstPage=1 -dLastPage=1 \
  -sDEVICE=pbmraw -r600x600 -g4960x7016 \
  -sOutputFile="$tmp/page.pbm" ../test-page.pdf
mkdir -p build
build/foo2xqx -r600x600 -g4960x7016 -p9 -T3 -m1 -s7 -d1 -n1 \
  < "$tmp/page.pbm" > build/test-page.zjs
[[ -s build/test-page.zjs ]] || { echo 'Encoder produced no data.' >&2; exit 1; }
echo 'Wrote native/build/test-page.zjs. This file has not been sent to the printer.'
