/* SPDX-License-Identifier: MIT */
/* Copyright (c) 2023 Michael Ortmann */

/* Description:
 *
 *   https://adventofcode.com/2023/day/8 - part 2
 *
 *   fast enough - 0.666 ms on AMD Ryzen 7 5700G
 *   input via stdin
 *   bulk memory allocation
 *   cycle iterate over instructions via modulo operation
 *   suckless lcm()
 *
 * Usage / Example:
 *
 *   $ clang -Wall -pedantic -march=native -O2 -s day08p2.c -o day08p2
 *   $ ./day08p2 < input
 *   14449445933179 0.666 ms
 *
 * Enjoy,
 * Michael
 */

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(void) {
  int c, l = 0, *instructions, *network, *p, *p2, *p3, *startingnodes, *factors, y, i, found;
  int64_t z = 1;
  struct timespec start, end;

  clock_gettime(CLOCK_MONOTONIC, &start);

  instructions = malloc(2 << 13); /* bulk memory allocation */

  while ((c = getc(stdin)) != '\n')
    instructions[l++] = (c == 'L') ? 0 : 1;

  getc(stdin); /* skip '\n' */
  network = instructions + l;
  p = network;

  while ((c = getc(stdin)) != EOF) {
    p2 = p;
    *p++ = (c << 16) + (getc(stdin) << 8) + getc(stdin);
    getc(stdin); /* skip ' ' */
    getc(stdin); /* skip '=' */
    getc(stdin); /* skip ' ' */
    getc(stdin); /* skip '(' */
    *p++ = (getc(stdin) << 16) + (getc(stdin) << 8) + getc(stdin);
    getc(stdin); /* skip ',' */
    getc(stdin); /* skip ' ' */
    *p++ = (getc(stdin) << 16) + (getc(stdin) << 8) + getc(stdin);
    getc(stdin); /* skip ')' */
    getc(stdin); /* skip '\n' */
    p3 = network;

    while (p3 <= p2) {
      if (*p2 == *(p3 + 1))
        *(p3 + 1) = p2 - network;
      if (*p2 == *(p3 + 2))
        *(p3 + 2) = p2 - network;
      if (*p3 == *(p2 + 1))
        *(p2 + 1) = p3 - network;
      if (*p3 == *(p2 + 2))
        *(p2 + 2) = p3 - network;
      p3 += 3;
    }
  }

  *p++ = -1;
  startingnodes = p;
  p2 = startingnodes;

  for (p = network; *p > -1; p += 3)
    if ((*p & 0xff) == 'Z')
      *p = 1;
    else {
      if ((*p & 0xff) == 'A')
        *p2++ = p - network;
      *p = 0;
    }

  *p2++ = -1;
  factors = p2;
  *factors = 0;

  for (p = startingnodes; *p != -1; p++) {
    y = 0;

    while (!network[*p])
      *p = network[*p + (instructions[y++ % l] ? 2 : 1)]; /* cycle iterate over instructions via modulo operation */

    while (y > 1) { /* suckless lcm() */
      i = 2;

      while (i <= y) {
        if (!(y % i)) {
          found = 0;

          for (p2 = factors; *p2; p2++) {
            if (i == *p2) {
              found = 1;
              break;
            }
          }

          if (!found) {
            *p2++ = i;
            *p2 = 0;
            z *= i;
          }

          y /= i;
        }
        i++;
      }
    }
  }

  clock_gettime(CLOCK_MONOTONIC, &end);
  printf("%" PRId64 " %.3f ms\n", z,
         (((double) end.tv_sec + 1.0e-9 * end.tv_nsec) -
          ((double) start.tv_sec + 1.0e-9 * start.tv_nsec)) * 1000.0);
}
