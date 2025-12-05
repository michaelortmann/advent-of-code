/* SPDX-License-Identifier: MIT */
/* Copyright (c) 2025 Michael Ortmann */

/* Description:
 *
 *   https://adventofcode.com/2025/day/2 - part 2
 *
 *   fast enough - 17 s on emulated Amiga 500
 *   input via file
 *
 * Usage / Example:
 *
 *   $ set -gx VBCC /path/to/vbcc
 *   $ set -gx PATH $VBCC/bin $PATH
 *   $ vc +kick13 -O2 day02p02.c -o day02p02
 *   $ xdftool day02p02.adf format day02p02 + boot install + makedir s + write startup-sequence s + write day02p02 + protect day02p02 +er + write input
 *   $ amiberry -0 day02p02.adf -G
 *   $ fs-uae --floppy-drive-0=day02p02.adf
 *   $ cp day02p02.adf /mnt/ROMS/
 *
 * Enjoy,
 * Michael
 */

#include <stdio.h>
#include <stdint.h>
#include <time.h>

// data segment instead of limited stack
int64_t already_counted[1024];

int main(void) {
  time_t start;
  FILE *f;
  char buf[512], *a = buf, *b = buf, *c = buf;
  size_t n;
  int64_t ai, bi, base, x, y = 0;
  int32_t la, lb, mid, i, nibble, nibble2, j;

  start = time(0);
  f = fopen("input", "rb");
  n = fread(buf, 1, sizeof buf, f);
  buf[n] = 0;

  if (buf[n - 1] == '\n')
    buf[n - 1] = 0;

  printf("processing: ");
  fflush(stdout);

  while(*b) {
    // a = first int, b = second int, la = len(a), lb = len(b)
    // a and b are string, ai and bi are int
    for (ai = 0; *b != '-'; ai = ai * 10 + *b++ - '0');
    la = b++ - c;
    c = b;
    for (bi = 0; (*c != ',') && (*c); bi = bi * 10 + *c++ - '0');
    lb = c++ - b;
    printf("%lli-%lli ", ai, bi);
    fflush(stdout);
    mid = (lb >> 1);
    already_counted[0] = 0;
    for (i = 1; i < mid + 1; i++) {
      base = 1;
      if (la != 1) {
        nibble = 0;
        for (j = 0; j < i; j++) {
          base *= 10;
          nibble = nibble * 10 + a[j] - '0';
        }
        while(1) {
          x = 0;
          for (j = 0; j < (la / i); j++)
            x = x * base + nibble;
          if (x <= bi) {
            for (j = 0; already_counted[j]; j++)
              if (x == already_counted[j])
                break;
            if ((x >= ai) && !already_counted[j]) {
              y = y + x;
              already_counted[j++] = x;
              already_counted[j] = 0;
            }
            if (++nibble >= base)
              break;
          }
          else
            break;
        }
      }
      if (lb > la) {
        nibble = 1;
        for (j = 0; j < (i - 1); j++)
          nibble *= 10;
        base = nibble * 10;
        nibble2 = 0;
        for (j = 0; j < i; j++)
          nibble2 = nibble2 * 10 + b[j] - '0';
        while (1) {
          x = 0;
          for (j = 0; j < (lb / i); j++) {
            x = x * base + nibble;
          }
          if (x <= bi) {
            for (j = 0; already_counted[j]; j++)
              if (x == already_counted[j])
                break;
            if ((x >= ai) && !already_counted[j]) {
              y = y + x;
              already_counted[j++] = x;
              already_counted[j] = 0;
            }
          }
          if (++nibble > nibble2)
            break;
        }
      }
    }
    a = c;
    b = c;
  }

  printf("\nadded up all the invalid IDs: %lli\n", y);
  printf("time: %lis\n", time(0) - start);
}
