const std = @import("std");
const ArrayList = std.ArrayList;

pub fn readInputFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const stat = try file.stat();
    return try file.reader().readAllAlloc(allocator, stat.size);
}

pub fn fromFile(allocator: std.mem.Allocator, filename: []const u8) ![][]const u8 {
    const content = try readInputFile(allocator, filename);
    defer allocator.free(content);
    var lines = std.ArrayList([]const u8).init(allocator);
    var readIter = std.mem.tokenizeScalar(u8, content, '\n');
    while (readIter.next()) |line| {
        const l = try allocator.dupe(u8, line);
        try lines.append(l);
    }
    return try lines.toOwnedSlice();
}

pub fn timeSolve(allocator: std.mem.Allocator, grid: []const u8) !u64 {
    _ = allocator;
    std.debug.print("{s}\n", .{grid});
    for (0..grid.len) |c| {
        std.debug.print("{c}\n", .{grid[c]});
    }
    const start = try std.time.Instant.now();
    std.time.sleep(1000000);
    const end = try std.time.Instant.now();
    const duration = std.time.Instant.since(end, start);
    std.debug.print("elapsed time: {d}\n", .{duration});
    return duration;
}

pub fn solveAll(allocator: std.mem.Allocator, filename: []const u8, show_if: ?f64) !void {
    _ = show_if;

    const grids = try fromFile(allocator, filename);
    defer allocator.free(grids);
    std.debug.print("{d}\n", .{grids.len});
    for (grids) |grid| {
        const elapsed = try timeSolve(allocator, grid);
        _ = elapsed;
    }
    for (grids) |grid| {
        allocator.free(grid);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    try solveAll(allocator, "puzzles/one.txt", 0.04);
    try solveAll(allocator, "puzzles/three.txt", 0.04);
    try solveAll(allocator, "puzzles/all.txt", 0.04);
    try solveAll(allocator, "puzzles/easy50.txt", 0.05);
    try solveAll(allocator, "puzzles/top95.txt", 0.05);
    try solveAll(allocator, "puzzles/hardest.txt", 0.05);
    try solveAll(allocator, "puzzles/hardest20.txt", 0.05);
    try solveAll(allocator, "puzzles/hardest20x50.txt", 0.05);
    try solveAll(allocator, "puzzles/topn87.txt", 0.05);
}
