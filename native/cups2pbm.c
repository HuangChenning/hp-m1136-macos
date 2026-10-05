// Convert one 600 dpi A4 grayscale CUPS raster page to full-page PBM.
#include <cups/raster.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

enum { PAGE_WIDTH = 4960, PAGE_HEIGHT = 7016, PAGE_ROW_BYTES = PAGE_WIDTH / 8 };

static int fail(const char *message) {
  fprintf(stderr, "cups2pbm: %s\n", message);
  return 1;
}

int main(void) {
  cups_raster_t *raster = cupsRasterOpen(STDIN_FILENO, CUPS_RASTER_READ);
  cups_page_header2_t header;
  if (!raster || !cupsRasterReadHeader2(raster, &header))
    return fail("no CUPS raster page found");

  if (header.cupsPageSize[0] < 594 || header.cupsPageSize[0] > 596 ||
      header.cupsPageSize[1] < 841 || header.cupsPageSize[1] > 843 ||
      header.HWResolution[0] != 600 || header.HWResolution[1] != 600 ||
      header.cupsColorSpace != CUPS_CSPACE_W ||
      header.cupsBitsPerColor != 8 || header.cupsBitsPerPixel != 8 ||
      header.cupsColorOrder != CUPS_ORDER_CHUNKED)
    return fail("only 600 dpi A4 8-bit grayscale is supported");

  int left = (int)(header.cupsImagingBBox[0] * 600 / 72 + 0.5);
  int top = (int)((header.cupsPageSize[1] - header.cupsImagingBBox[3]) * 600 / 72 + 0.5);
  if (left < 0 || top < 0 || left > PAGE_WIDTH || top > PAGE_HEIGHT ||
      header.cupsWidth == 0 || header.cupsHeight == 0 ||
      header.cupsWidth > PAGE_WIDTH - left || header.cupsHeight > PAGE_HEIGHT - top ||
      header.cupsBytesPerLine < header.cupsWidth || header.cupsBytesPerLine > PAGE_WIDTH * 4)
    return fail("raster image does not fit on an A4 page");

  unsigned char *line = malloc(header.cupsBytesPerLine);
  unsigned char *page = calloc(PAGE_ROW_BYTES * PAGE_HEIGHT, 1);
  if (!line || !page) return fail("out of memory");

  for (unsigned y = 0; y < header.cupsHeight; y++) {
    if (cupsRasterReadPixels(raster, line, header.cupsBytesPerLine) != header.cupsBytesPerLine)
      return fail("truncated CUPS raster page");
    for (unsigned x = 0; x < header.cupsWidth; x++) {
      if (line[x] < 128) {
        unsigned px = left + x;
        page[(top + y) * PAGE_ROW_BYTES + px / 8] |= 0x80 >> (px % 8);
      }
    }
  }
  if (cupsRasterReadHeader2(raster, &header))
    return fail("multiple pages are not supported yet");

  if (fputs("P4\n4960 7016\n", stdout) == EOF ||
      fwrite(page, PAGE_ROW_BYTES, PAGE_HEIGHT, stdout) != PAGE_HEIGHT)
    return fail("could not write PBM output");
  free(line);
  free(page);
  cupsRasterClose(raster);
  return 0;
}
