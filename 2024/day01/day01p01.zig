// SPDX-License-Identifier: MIT
// Copyright (c) 2024 Michael Ortmann

const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const buf = try std.fs.cwd().readFileAlloc(allocator, "input", 16384);
    var tokens = std.mem.tokenizeAny(u8, buf, " \n"); // chars ordered by likelyhood
    var l0 = std.ArrayList(i32).init(allocator);
    var l1 = std.ArrayList(i32).init(allocator);
    while (tokens.next()) |word| {
        const a = try std.fmt.parseInt(i32, word, 10);
        const b = try std.fmt.parseInt(i32, tokens.next().?, 10);
        try l0.append(a);
        try l1.append(b);
    }
    std.mem.sortUnstable(i32, l0.items, {}, std.sort.asc(i32));
    std.mem.sortUnstable(i32, l1.items, {}, std.sort.asc(i32));
    var y: u32 = 0;
    for (l0.items, l1.items) |a, b|
        y += @abs(a - b);
    std.debug.print("y = {any}\n", .{y});
}
