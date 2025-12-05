#!/usr/bin/python
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Michael Ortmann

f = open("input")
a = []

for line in f:
  a = a + ["." + line.rstrip() + "."]

l = len(a[0])
a = ["." * l] + a + ["." * l]
z = 0
found = 1

while found > 0:
  found = 0
  for y in range(1, len(a) - 1):
    for x in range(1, len(a[0]) - 1):
        if a[y][x] == '.':
            continue
        count = 0
        for i in range(y - 1, y + 2):
            for j in range(x - 1, x + 2):
                if a[i][j] == "@":
                    count = count + 1
        if count < 5:
            z = z + 1
            a[y] = a[y][:x] + "." + a[y][x+1:]
            found = found + 1

print(z)
