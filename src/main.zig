const std = @import("std");
const ArrayList = std.ArrayList;

pub fn readInputFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const stat = try file.stat();
    return try file.reader().readAllAlloc(allocator, stat.size);
}

pub fn fromFile(allocator: std.mem.Allocator, content: []const u8) ![][]const u8 {
    var lines = std.ArrayList([]const u8).init(allocator);
    var readIter = std.mem.tokenizeScalar(u8, content, '\n');
    while (readIter.next()) |line| {
        try lines.append(line);
    }
    return try lines.toOwnedSlice();
}

//        var it = std.mem.tokenize(u8, line, "");
//        while (it.next()) |char| {
//            std.debug.print("{s}\n", .{char});
//        }

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const content = try readInputFile(allocator, "./puzzles/all.txt");
    defer allocator.free(content);
    const gridList = try fromFile(allocator, content);
    defer allocator.free(gridList);
    std.debug.print("{d}\n", .{gridList.len});
    for (gridList) |grid| {
        std.debug.print("{s}\n", .{grid});
    }
    // solve_all(from_file("puzzles/easy50.txt"), "easy", null);
    // solve_all(from_file("puzzles/top95.txt"), "hard", 0.04);
    // solve_all(from_file("puzzles/hardest.txt"), "hardest", null);
    // solve_all(from_file("puzzles/hardest20.txt"), "hardest20", null);
    // solve_all(from_file("puzzles/hardest20x50.txt"), "hardest20x50", null);
    // solve_all(from_file("puzzles/topn87.txt"), "topn87", null);
}

pub fn solve_all(grids: [][]const u8, name: []const u8, showif: f64) !void {
    _ = name;
    _ = showif;

    for (grids) |grid| {
        std.debug.print("{s}\n", grid);
    }
}
