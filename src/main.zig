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
    var lines = std.ArrayList([]const u8).init(allocator);
    var readIter = std.mem.tokenizeScalar(u8, content, '\n');
    while (readIter.next()) |line| {
        const l = try allocator.dupe(u8, line);
        try lines.append(l);
    }
    return try lines.toOwnedSlice();
}

pub fn solve(allocator: std.mem.Allocator, grid: []const u8, puzzle: *[81]std.bit_set.StaticBitSet(9)) !bool {
    _ = puzzle;
    _ = allocator;
    for (0..grid.len) |c| {
        std.debug.print("{c}\n", .{grid[c]});
    }
    std.time.sleep(try getRandomCount());
    const t: [81]std.bit_set.StaticBitSet(9) = undefined;
    _ = t;
    return false;
}

pub fn search(allocator: std.mem.Allocator, puzzle: *[81]std.bit_set.StaticBitSet(9)) !bool {
    _ = allocator;
    _ = puzzle;

    return false;
}

pub fn timeSolve(allocator: std.mem.Allocator, grid: []const u8) !u64 {
    std.debug.print("puzzle:   {s}\n", .{grid});
    const start = try std.time.Instant.now();
    var puzzle: [81]std.bit_set.StaticBitSet(9) = undefined;
    _ = try solve(allocator, grid, &puzzle);
    const end = try std.time.Instant.now();
    const duration = std.time.Instant.since(end, start);
    displayGrid(&puzzle);
    return duration;
}

pub fn displayGrid(grid: *[81]std.bit_set.StaticBitSet(9)) void {
    for (grid) |c| {
        _ = c;

        for (0..9) |d| {
            _ = d;
        }
    }
}

pub fn solveAll(allocator: std.mem.Allocator, filename: []const u8) !void {
    const grids = try fromFile(allocator, filename);
    for (grids) |grid| {
        const elapsed = try timeSolve(allocator, grid);
        std.debug.print("({d:.5} seconds)\n", .{@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.00});
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try solveAll(allocator, "puzzles/incredibly-difficult.txt");
    try solveAll(allocator, "puzzles/one.txt");
    try solveAll(allocator, "puzzles/two.txt");
    try solveAll(allocator, "puzzles/easy50.txt");
    try solveAll(allocator, "puzzles/top95.txt");
    try solveAll(allocator, "puzzles/hardest.txt");
    try solveAll(allocator, "puzzles/hardest20.txt");
    try solveAll(allocator, "puzzles/hardest20x50.txt");
    try solveAll(allocator, "puzzles/topn87.txt");
}

fn getRandomCount() !u64 {
    var seed: u64 = undefined;
    try std.os.getrandom(std.mem.asBytes(&seed));
    var random = std.rand.DefaultPrng.init(seed);
    return random.random().uintAtMost(u64, 1_200_000);
}
