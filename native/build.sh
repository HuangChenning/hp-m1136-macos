#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build
/usr/bin/clang -arch arm64 -O2 -Wall \
  third_party/foo2zjs/foo2xqx.c \
  third_party/foo2zjs/jbig.c \
  third_party/foo2zjs/jbig_ar.c \
  -o build/foo2xqx
/usr/bin/clang -arch arm64 -O2 -Wall -Werror cups2pbm.c -lcups -o build/cups2pbm
cp rastertozjs build/rastertozjs
chmod 755 build/rastertozjs
/usr/bin/lipo -archs build/foo2xqx
/usr/bin/lipo -archs build/cups2pbm
