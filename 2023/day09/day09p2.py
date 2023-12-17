#!/usr/bin/python
# SPDX-License-Identifier: MIT
# Copyright (c) 2023 Michael Ortmann

import sys

def next(x):
  return x[0] if len({s for s in x}) == 1 else x[0] - next([(x[i + 1] - x[i]) for i in range(0, len(x) - 1)])

y = 0

for x in [[int(x) for x in line.split(" ")] for line in sys.stdin.read().splitlines()]:
  y += next(x)

print(y)
