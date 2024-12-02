// SPDX-License-Identifier: MIT
// Copyright (c) 2024 Michael Ortmann

const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buf = try std.fs.cwd().readFileAlloc(allocator, "input", 16384);
    var tokens = std.mem.tokenizeAny(u8, buf, " \n"); // chars ordered by likelyhood
    var l0 = std.ArrayList(u32).init(allocator);
    var map = std.AutoHashMap(u32, u32).init(allocator);
    while (tokens.next()) |word| {
        const a = try std.fmt.parseInt(u32, word, 10);
        const b = try std.fmt.parseInt(u32, tokens.next().?, 10);
        try l0.append(a);
        if (map.getPtr(b)) |ptr| {
            ptr.* += 1;
        } else try map.put(b, 1);
    }
    var y: u32 = 0;
    for (l0.items) |a| {
        const ptr = map.getPtr(a);
        if (ptr != null)
            y += a * ptr.?.*;
    }
    std.debug.print("y = {any}\n", .{y});
}
