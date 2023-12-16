const std = @import("std");

pub fn from_file() !void {
    var file = try std.fs.cwd().openFile("puzzles/all.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenize(u8, line, "");
        while (it.next()) |char| {
            std.debug.print("{s}\n", .{char});
        }
    }
}

pub fn main() !void {
    try from_file();
}
