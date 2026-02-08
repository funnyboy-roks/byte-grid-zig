const std = @import("std");

const THIRDPARTY_DIR = "thirdparty";

pub fn build(b: *std.Build) !void {
    const exe = b.addExecutable(.{
        .name = "render",
        .root_module = b.createModule(.{
            .root_source_file = b.path("render.zig"),
            .target = b.graph.host,
            .link_libc = true,
        }),
    });
    exe.addAfterIncludePath(b.path(THIRDPARTY_DIR));
    exe.addCSourceFile(.{
        .file = try b.path(THIRDPARTY_DIR).join(b.allocator, "stb_image_write.h"),
        .flags = &[_][]const u8{ "-DSTB_IMAGE_WRITE_IMPLEMENTATION" },
        .language = std.Build.Module.CSourceLanguage.c,
    });

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
