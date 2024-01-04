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

pub fn solve(grid: []const u8, puzzle: *[81]std.bit_set.StaticBitSet(9)) !bool {
    for (0..81) |square| {
        if (std.ascii.isDigit(grid[square]) and grid[square] != '0') {
            const d: usize = try std.fmt.charToDigit(grid[square], 10);
            if (!assign(puzzle, square, d - 1)) {
                return false;
            }
        }
    }
    return search(puzzle);
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

    // (1) If a square s is reduced to one value 'val', then eliminate 'val' from the peers.
    if (puzzle.*[square].count() == 1) {
        const val = puzzle.*[square].findFirstSet().?;
        for (peers[square]) |peer| {
            if (!eliminate(puzzle, peer, val)) {
                return false;
            }
        }
    }

    // (2) If a unit u is reduced to only one spot for the value 'd', then put it there.
    check_units: for (units[square]) |unit| {
        var spots: [9]usize = undefined;
        var spots_length: usize = 0;
        for (unit) |s| {
            if (puzzle.*[s].isSet(d)) {
                spots[spots_length] = s;
                spots_length += 1;
            }

            if (spots_length >= 2) {
                continue :check_units;
            }
        }

        if (spots_length == 1) {
            if (!assign(puzzle, spots[0], d)) {
                return false;
            }
        }

        if (spots_length == 0) {
            return false; // contradiction
        }
    }

    return true;
}

pub fn search(puzzle: *[81]std.bit_set.StaticBitSet(9)) !bool {
    var square_with_fewest_possibilities: usize = 82;
    var number_of_possibilities: usize = 10;
    for (0..81) |square| {
        const t = puzzle.*[square].count();
        if (t > 1) {
            if (t < number_of_possibilities) {
                number_of_possibilities = t;
                square_with_fewest_possibilities = square;
                if (number_of_possibilities == 2) {
                    break;
                }
            }
        }
    }

    if (square_with_fewest_possibilities == 82) {
        return true;
    }

    for (0..9) |b| {
        if (puzzle.*[square_with_fewest_possibilities].isSet(b)) {
            var duplicate: [81]std.bit_set.StaticBitSet(9) = puzzle.*;
            if (assign(&duplicate, square_with_fewest_possibilities, b)) {
                const result = try search(&duplicate);
                if (result) {
                    puzzle.* = duplicate;
                    return true;
                }
            }
        }
    }

    return false;
}

pub fn timeSolve(grid: []const u8) !u64 {
    std.debug.print("puzzle:   {s}\n", .{grid});
    // initialize starting puzzle
    var puzzle: [81]std.bit_set.StaticBitSet(9) = undefined;
    for (0..81) |square| {
        puzzle[square] = std.bit_set.StaticBitSet(9).initFull();
    }
    const start = try std.time.Instant.now();
    const result = try solve(grid, &puzzle);
    _ = result;
    const end = try std.time.Instant.now();
    const duration = end.since(start);
    displayGrid(&puzzle);
    return duration;
}

pub fn displayGrid(puzzle: *[81]std.bit_set.StaticBitSet(9)) void {
    std.debug.print("solution: ", .{});
    for (0..81) |square| {
        const d = puzzle.*[square].findFirstSet();
        if (d) |digit| {
            std.debug.print("{d}", .{digit + 1});
        } else {
            std.debug.print(".", .{});
        }
    }
    std.debug.print("\n", .{});
}

pub fn solveAll(allocator: std.mem.Allocator, filename: []const u8, name: []const u8) !void {
    const grids = try fromFile(allocator, filename);
    var times: u64 = 0;
    var max_time: u64 = 0;
    for (grids) |grid| {
        const elapsed = try timeSolve(grid);
        std.debug.print("({d:.5} seconds)\n", .{@as(f64, @floatFromInt(elapsed)) / 1_000_000_000.00});
        times += elapsed;
        if (elapsed > max_time) {
            max_time = elapsed;
        }
    }
    const avg = @as(f64, @floatFromInt(times)) / (1_000_000_000 * @as(f64, @floatFromInt(grids.len)));
    const hz = @as(f64, @floatFromInt(grids.len)) / (@as(f64, @floatFromInt(times)) / 1_000_000_000);
    const max = @as(f64, @floatFromInt(max_time)) / 1_000_000_000;
    std.debug.print("Solved {d} of {d} {s} puzzles (avg {d:.5} secs ({d:.5} Hz), max {d:.5} secs).\n", .{
        grids.len,
        grids.len,
        name,
        avg,
        hz,
        max,
    });
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.c_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    try solveAll(allocator, "puzzles/easy1.txt", "easy");
    try solveAll(allocator, "puzzles/incredibly-difficult.txt", "incredibly-difficult");
    try solveAll(allocator, "puzzles/one.txt", "one");
    try solveAll(allocator, "puzzles/two.txt", "two");
    try solveAll(allocator, "puzzles/easy50.txt", "easy");
    try solveAll(allocator, "puzzles/top95.txt", "hard");
    try solveAll(allocator, "puzzles/hardest.txt", "hardest");
    try solveAll(allocator, "puzzles/hardest20.txt", "hardest20");
    try solveAll(allocator, "puzzles/hardest20x50.txt", "hardest20x50");
    try solveAll(allocator, "puzzles/topn87.txt", "topn87");
}
