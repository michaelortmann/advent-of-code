#!/usr/bin/env python
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Michael Ortmann

f = open("input")
a = []

for line in f:
  a += [line.split()]

y = 0

for i in range(0, len(a[0])):
    op = a[-1][i]
    if a[-1][i] == '*':
        x = int(a[0][i])
        for j in range(1, len(a) - 1):
            x *= int(a[j][i])
        y += x
    else:
        for j in range(0, len(a) - 1):
            y += int(a[j][i])

print(y)
