const std = @import("std");
const warn = @import("std").debug.warn;
const os = @import("std").os;

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const kernel_source = b.addObject("kernel", "src/kernel.zig");
    kernel_source.setBuildMode(mode);

    // building boot elf32 assembly
    _ = b.addSystemCommand(&[_][]const u8{ "as", "-target", "x86_64-pc-none-gnu", "src/boot.s" });
    // _ = std.ChildProcess.exec(.{ .allocator = b.allocator, .argv = &[_][]const u8{ "as", "-target", "x86_64-pc-none-gnu", "src/boot.s" } }) catch unreachable;

    const kernel_main_tests = b.addTest("src/kernel.zig");
    kernel_main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&kernel_main_tests.step);

    std.debug.print("install path: {s} \n", .{b.install_prefix});
}
