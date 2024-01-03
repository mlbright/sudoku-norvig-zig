const std = @import("std");

pub fn generateUnitList() [27][9]usize {
    var horizontal_units: [9][9]usize = undefined;
    for (0..9) |i| {
        for (0..9) |j| {
            horizontal_units[i][j] = (i * 9) + j;
        }
    }

    var vertical_units: [9][9]usize = undefined;
    for (0..9) |i| {
        for (0..9) |j| {
            vertical_units[i][j] = i + (9 * j);
        }
    }

    // box units
    const box_indices = comptime [3][3]usize{
        [_]usize{ 0, 1, 2 },
        [_]usize{ 3, 4, 5 },
        [_]usize{ 6, 7, 8 },
    };

    var box_units: [9][9]usize = undefined;
    var x: usize = 0;
    var y: usize = 0;
    for (box_indices) |r| {
        for (box_indices) |c| {
            for (r) |i| {
                for (c) |j| {
                    box_units[x][y] = i + (9 * j);
                    y += 1;
                }
            }
            x += 1;
            y = 0;
        }
    }

    return horizontal_units ++ vertical_units ++ box_units;
}

const unit_list = generateUnitList();

test "unitlist" {
    const unitlist_test = generateUnitList();
    var v = unitlist_test[0][8];
    try std.testing.expectEqual(@as(usize, 8), v);
    v = unitlist_test[1][4];
    try std.testing.expectEqual(@as(usize, 13), v);
    v = unitlist_test[10][5];
    try std.testing.expectEqual(@as(usize, 46), v);
    v = unitlist_test[25][4];
    try std.testing.expectEqual(@as(usize, 43), v);
    v = unitlist_test[26][1];
    try std.testing.expectEqual(@as(usize, 69), v);
}

const units: [81][3][9]usize = determineUnits();

pub fn determineUnits() [81][3][9]usize {
    @setEvalBranchQuota(100000);
    var t: [81][3][9]usize = undefined;
    var count: usize = 0;
    for (0..81) |square| {
        outer: for (unit_list) |unit| {
            for (unit) |u| {
                if (square == u) {
                    for (0..9) |i| {
                        t[square][count][i] = unit[i];
                    }
                    count += 1;
                    if (count < 3) {
                        break;
                    } else {
                        count = 0;
                        break :outer;
                    }
                }
            }
        }
    }

    return t;
}

test "units" {
    // std.debug.print("\n", .{});
    // for (units[19]) |group| {
    //     for (group) |d| {
    //         std.debug.print("{d} ", .{d});
    //     }
    //     std.debug.print("\n", .{});
    // }
    try std.testing.expectEqual(@as(usize, 28), units[19][1][3]);
    try std.testing.expectEqual(@as(usize, 18), units[19][2][2]);
}

const peers: [81][20]usize = determinePeers();

pub fn determinePeers() [81][20]usize {
    @setEvalBranchQuota(100000);
    var t = std.mem.zeroes([81][20]usize);
    for (0..81) |square| {
        for (0..20) |p| {
            t[square][p] = 82;
        }
    }
    for (0..81) |square| {
        var count = 0;
        for (units[square]) |unit| {
            for (unit) |u| {
                if (u == square) {
                    continue;
                }
                var already_included = false;

                already_included = for (0..20) |i| {
                    if (t[square][i] == u) {
                        break true;
                    }
                } else false;

                if (!already_included) {
                    t[square][count] = u;
                    count += 1;
                }
            }
        }
    }
    return t;
}

test "peers" {
    std.debug.print("\n", .{});
    // for (peers[53]) |p| {
    //     std.debug.print("{d} ", .{p});
    // }
    try std.testing.expectEqual(@as(usize, 43), peers[53][19]);
    try std.testing.expectEqual(@as(usize, 11), peers[19][19]);
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
