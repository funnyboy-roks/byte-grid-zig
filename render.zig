const std = @import("std");
const print = std.debug.print;
const Limit = std.Io.Limit;

const stbi = @cImport({
    @cInclude("./stb_image_write.h");
});

const Colour = packed struct(u32) {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

pub fn main() !void {
    const alloc = std.heap.c_allocator;

    const args = try std.process.argsAlloc(alloc);
    defer std.process.argsFree(alloc, args);

    if (args.len != 2 and args.len != 3) {
        print("Usage: {s} <file> <output=out.png>\n", .{args[0]});
        return error.InvalidParam;
    }

    var out_path: [:0]const u8 = undefined;
    if (args.len == 3) {
        out_path = args[2];
    } else {
        out_path = "out.png";
    }

    const f = try std.fs.cwd().openFile(args[1], .{ .mode = .read_only });
    defer f.close();

    var content: std.ArrayList(u8) = .{};
    defer content.deinit(alloc);

    var buf: [1024]u8 = undefined;
    var buf_reader = f.reader(&buf);
    try buf_reader.interface.appendRemaining(alloc, &content, Limit.unlimited);

    var grid: [256][256]u32 = .{.{0} ** 256} ** 256;

    //  vvvv  vvvv  vvvv
    // [1, 2, 3, 4, 5, 6]
    //  ^  ^
    //     ^  ^
    //        ^  ^

    for (content.items[0..content.items.len-1], content.items[1..]) |x, y| {
        grid[y][x] += 1;
    }

    var max: u32 = 0;
    for (grid) |row| {
        for (row) |c| {
            if (c > max) max = c;
        }
    }

    var out_grid: [256][256]Colour = .{.{Colour { .r = 0, .g = 0, .b = 0, .a = 0 }} ** 256} ** 256;

    for (grid, 0..) |row, y| {
        for (row, 0..) |_, x| {
            const cell: f32 = @floatFromInt(grid[y][x]);
            var brightness = cell / @as(f32, @floatFromInt(max));
            brightness = std.math.cbrt(brightness);

            out_grid[y][x] = Colour {
                .r = 0,
                .g = @intFromFloat(brightness * 255),
                .b = @intFromFloat(brightness * 255),
                .a = 0xff,
            };
        }
    }

    _ = stbi.stbi_write_png(out_path.ptr, 256, 256, @sizeOf(Colour), &out_grid, 256 * @sizeOf(Colour));
    print("Generated {s}\n", .{out_path});
}
