#!/usr/bin/python
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Michael Ortmann

f = open("input")
b = list(f.read())
len = len(b)
x = []

for i in range(0, len):
   if (b[i] == 'S'):
        x.append(1)
   elif (b[i] == '^'):
        x.append(-1)
   else:
        x.append(0)

w = b.index('\n') + 1
count = 1 # start with 1 to also count initial 'S'

for i in range(0, len - w):
    if x[i] > 0:
        if (x[i + w]) == -1:
            x[i + w - 1] += x[i]
            x[i + w    ] = 0
            x[i + w + 1] += x[i]
            count += x[i]
        else:
            x[i + w    ] += x[i]

print(count)
