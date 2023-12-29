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

pub fn puzzleInit(allocator: std.mem.Allocator, grid: []const u8, puzzle: *[81]u9) !void {
    _ = puzzle;

    _ = allocator;
    _ = grid;
}

pub fn solve(allocator: std.mem.Allocator, puzzle: *[81]u9) ![81]u9 {
    _ = allocator;
    _ = puzzle;
}

pub fn timeSolve(allocator: std.mem.Allocator, grid: []const u8) !u64 {
    std.debug.print("puzzle:   {s}\n", .{grid});
    var puzzle = [_]u9{0} ** 81;
    try puzzleInit(allocator, grid, &puzzle);
    const start = try std.time.Instant.now();
    // for (0..grid.len) |c| {
    //     std.debug.print("{c}\n", .{grid[c]});
    // }
    const solution = try solve(allocator, &puzzle);
    std.time.sleep(1000000);
    const end = try std.time.Instant.now();
    const duration = std.time.Instant.since(end, start);
    displayGrid(solution);
    return duration;
}

pub fn displayGrid(grid: [81]u9) void {
    for (grid) |c| {
        _ = c;

        for (0..9) |d| {
            _ = d;
        }
    }
}

pub fn solveAll(allocator: std.mem.Allocator, filename: []const u8) !void {
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
    try solveAll(allocator, "puzzles/one.txt");
    try solveAll(allocator, "puzzles/three.txt");
    try solveAll(allocator, "puzzles/all.txt");
    try solveAll(allocator, "puzzles/easy50.txt");
    try solveAll(allocator, "puzzles/top95.txt");
    try solveAll(allocator, "puzzles/hardest.txt");
    try solveAll(allocator, "puzzles/hardest20.txt");
    try solveAll(allocator, "puzzles/hardest20x50.txt");
    try solveAll(allocator, "puzzles/topn87.txt");
}
