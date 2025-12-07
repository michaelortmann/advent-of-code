// SPDX-License-Identifier: MIT
// Copyright (c) 2025 Michael Ortmann

// ~/opt/zig-x86_64-linux-0.16.0-dev.1484+d0ba6642b/zig build-exe day05p2.zig -O ReleaseFast -fsingle-threaded -fstrip
// 0.267 (six seven) ms on AMD Ryzen 7 5700G

const std = @import("std");

const Range = struct { a: u64, b: u64 };

pub fn main() !void {
    // set up our I/O implementation
    var threaded: std.Io.Threaded = .init_single_threaded;
    defer threaded.deinit();
    const io = threaded.io();

    // read input file into data slice
    var buf: [1 << 15]u8 = undefined;
    const data = try std.Io.Dir.cwd().readFile(io, "input", &buf);

    // tokenize data into lines
    var lines = std.mem.splitAny(u8, data, "\n");

    // array of ranges
    var r_buf: [256]Range = undefined;
    var r = std.ArrayListUnmanaged(Range).initBuffer(&r_buf);

    // parse lines into array of ranges until blank line
    while (lines.next()) |line| {
        if (line.len == 0) // blank line
            break;
        var s = std.mem.splitAny(u8, line, "-");
        r.appendAssumeCapacity(.{
            .a = try std.fmt.parseUnsigned(u64, s.next().?, 10),
            .b = try std.fmt.parseUnsigned(u64, s.next().?, 10),
        });
    }

    // sort ranges by start value
    std.mem.sortUnstable(Range, r.items, {}, struct {
        pub fn inner(_: void, a: Range, b: Range) bool {
            return (a.a < b.a);
        }
    }.inner);

    // merge and sum
    var last: *Range = &r.items[0];
    var y: u64 = 0;
    for (r.items[1..]) |*curr| {
        if (curr.a <= last.b) {
            last.b = @max(last.b, curr.b);
        } else {
            y += last.b - last.a + 1;
            last = curr;
        }
    }
    y += last.b - last.a + 1;

    std.debug.print("{d}\n", .{y});
}
