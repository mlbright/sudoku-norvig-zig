const std = @import("std");
const ArrayList = std.ArrayList;

pub fn readInputFile(allocator: std.mem.Allocator, filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();
    const stat = try file.stat();
    const fileSize = stat.size;
    return try file.reader().readAllAlloc(allocator, fileSize);
}

pub fn fromFile(allocator: std.mem.Allocator, filename: []const u8) ![][]const u8 {
    const content = try readInputFile(allocator, filename);
    defer _ = allocator.free(content);
    var lines = std.ArrayList([]const u8).init(allocator);
    var readIter = std.mem.tokenize(u8, content, "\n");
    while (readIter.next()) |line| {
        try lines.append(line);
    }
    return lines.toOwnedSlice();
}

//        var it = std.mem.tokenize(u8, line, "");
//        while (it.next()) |char| {
//            std.debug.print("{s}\n", .{char});
//        }

const grid1 = "..3.2.6..9..3.5..1..18.64....81.29..7.......8..67.82....26.95..8..2.3..9..5.1.3..";
const grid2 = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......";
const hard1 = ".....6....59.....82....8....45........3........6..3.54...325..6..................";

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const gridList = try fromFile(allocator, "./puzzles/all.txt");
    defer _ = allocator.free(gridList);
    std.debug.print("{d}\n", .{gridList.len});
    for (0..gridList.len) |i| {
        std.debug.print("{s}\n", .{gridList[i]});
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
