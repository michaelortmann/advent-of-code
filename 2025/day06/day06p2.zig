// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Michael Ortmann

// ~/opt/zig-x86_64-linux-0.16.0-dev.1484+d0ba6642b/zig build-exe day06p2.zig -O ReleaseFast -fsingle-threaded -fstrip

const std = @import("std");

pub fn main() !void {
    // set up our I/O implementation
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    // read input file into data slice
    var buf: [1 << 15]u8 = undefined;
    const a = try std.Io.Dir.cwd().readFile(io, "input", &buf);

    // calculate width and height
    const w = std.mem.indexOfScalar(u8, a, '\n').? + 1;
    const h = a.len / w;

    // operation '+' or '*'
    var op: u8 = undefined;
    var j: u64 = 0;
    var result: u64 = 0;

    // for each column
    for (0..w - 1) |x| {

        // get operation
        var c = a[(h - 1) * w + x];
        if (c != ' ') {
            if (c != op)
                op = c;
            result += j;
            j = 0;
        }

        // for each row
        var i: u16 = 0;
        for (0..h - 1) |y| {
            // get char
            c = a[y * w + x];
            if (c != ' ') {
                if (i > 0)
                    i *= 10;
                i += c - '0';
            }
        }

        if (i != 0) {
            if (op == '+') {
                j += i;
            } else {
                if (j != 0) {
                    j *= i;
                } else {
                    j = i;
                }
            }
        }
    }

    result += j;
    std.debug.print("result {d}\n", .{result});
}
