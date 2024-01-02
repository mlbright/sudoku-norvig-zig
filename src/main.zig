const std = @import("std");
const ArrayList = std.ArrayList;

pub fn generateUnits() [27][9]usize {
    var units: [27][9]usize = undefined;

    // horizontal units
    for (0..9) |i| {
        for (0..9) |j| {
            units[i][j] = (i * 9) + j;
        }
    }

    // vertical units
    for (0..9) |i| {
        for (0..9) |j| {
            units[i + 9][j] = i + (9 * j);
        }
    }

    // box units
    const box_indices = comptime [3][3]usize{
        [_]usize{ 0, 1, 2 },
        [_]usize{ 3, 4, 5 },
        [_]usize{ 6, 7, 8 },
    };

    for (box_indices) |row| {
        for (box_indices) |column| {
            for (row) |i| {
                for (column) |j| {
                    units[i + 18][j] = i + (9 * j);
                }
            }
        }
    }

    return units;
}

const unitlist = generateUnits();

test "units" {
    const unitlist_test = generateUnits();
    var v = unitlist_test[0][8];
    try std.testing.expectEqual(@as(usize, 8), v);
    v = unitlist_test[1][4];
    try std.testing.expectEqual(@as(usize, 13), v);
    v = unitlist_test[10][5];
    try std.testing.expectEqual(@as(usize, 46), v);
    for (0..9) |i| {
        std.debug.print("{d}\n", .{unitlist_test[25][i]});
    }
    v = unitlist_test[26][1];
    try std.testing.expectEqual(@as(usize, 61), v);
}

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
    for (grid, 0..grid.len) |c, square| {
        // std.debug.print("{c}\n", .{grid[c]});
        if (std.ascii.isDigit(c) and c != '0') {
            const d: usize = try std.fmt.charToDigit(c, 10);
            if (!assign(puzzle, square, d)) {
                return false;
            }
        }
    }
    return search(allocator, puzzle);
}

pub fn assign(puzzle: *[81]std.bit_set.StaticBitSet(9), square: usize, d: usize) bool {
    for (0..9) |v| {
        if (puzzle.*[square].isSet(v) and v != d) {
            if (!eliminate(puzzle, square, v)) {
                return false;
            }
        }
    }
    return true;
}

pub fn eliminate(puzzle: *[81]std.bit_set.StaticBitSet(9), square: usize, d: usize) bool {
    if (!puzzle.*[square].isSet(d)) {
        return true;
    }
    puzzle.*[square].unset(d);
    if (puzzle.*[square].count() == 0) {
        return false; // contradiction
    }

    // (1) If a square s is reduced to one value d2, then eliminate d2 from the peers.
    if (puzzle.*[square].count() == 1) {
        return false;
    }

    return true;
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
