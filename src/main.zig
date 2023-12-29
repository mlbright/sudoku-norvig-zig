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

pub fn puzzleInit(allocator: std.mem.Allocator, grid: []const u8, puzzle: *[81]std.bit_set.StaticBitSet(9)) !void {
    _ = puzzle;

    _ = allocator;
    _ = grid;
}

const Contradiction = error{
    AlreadyEliminated,
    RemovedLastValue,
    NoRemainingCandidateSquares,
};

pub fn solve(allocator: std.mem.Allocator, puzzle: *[81]std.bit_set.StaticBitSet(9)) ![81]std.bit_set.StaticBitSet(9) {
    _ = allocator;
    _ = puzzle;
    return Contradiction.AlreadyEliminated;
}

pub fn timeSolve(allocator: std.mem.Allocator, grid: []const u8) !u64 {
    std.debug.print("puzzle:   {s}\n", .{grid});
    var puzzle: [81]std.bit_set.StaticBitSet(9) = undefined;
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

pub fn displayGrid(grid: [81]std.bit_set.StaticBitSet(9)) void {
    for (grid) |c| {
        _ = c;

        for (0..9) |d| {
            _ = d;
        }
    }
}

pub fn solveAll(allocator: std.mem.Allocator, filename: []const u8) !void {
    const grids = try fromFile(allocator, filename);
    std.debug.print("{d}\n", .{grids.len});
    for (grids) |grid| {
        std.debug.print("({d:.5} seconds)\n", .{2.12345});
        // @as(f32, @floatFromInt(partial)) / @as(f32, @floatFromInt(total))
        std.debug.print("({d:.5} seconds)\n", .{ @as(f64, @floatFromInt(1_123_344_123))/1_000_000_000.00});
        const elapsed = try timeSolve(allocator, grid);
        // @as(f32, @floatFromInt(partial)) / @as(f32, @floatFromInt(total))
        std.debug.print("({d:.5} seconds)\n", .{ @as(f64, @floatFromInt(elapsed))/1_000_000_000.00});
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

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
