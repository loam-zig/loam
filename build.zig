const std = @import("std");

const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{ .rp2xxx = true });

pub fn build(b: *std.Build) void {
    const loam_mod = b.addModule("loam", .{
        .root_source_file = b.path("src/root.zig"),
    });

    // A test firmware that compiles loam as a consumer would
    const mz_dep = b.lazyDependency("microzig", .{}) orelse return;
    const mb = MicroBuild.init(b, mz_dep) orelse return;

    const check_fw = mb.add_firmware(.{
        .name = "loam-check",
        .target = mb.ports.rp2xxx.boards.raspberrypi.pico2_arm,
        .optimize = .ReleaseSmall,
        .root_source_file = b.path("test/check.zig"),
    });
    check_fw.add_app_import("loam", loam_mod, .{ .depend_on_microzig = true });

    mb.install_firmware(check_fw, .{});
}
