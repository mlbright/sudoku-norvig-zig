const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var file = try std.fs.cwd().openFile("example.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    while (try buf_reader.readUntilDelimiterOrEof(allocator, '\n')) |line| : (buf_reader = buf_reader.save()) {
        var it = std.mem.tokenize(line, "");
        while (it.next()) |char| {
            std.debug.print("{}\n", .{char});
        }
    }
}
