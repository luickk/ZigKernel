const std = @import("std");
const warn = @import("std").debug.warn;
const os = @import("std").os;

pub fn build(b: *std.build.Builder) void {
    // const kernel_source = b.addObject("kernel", "src/kernel.zig");
    // kernel_source.setBuildMode(mode);

    // building boot elf32 assembly
    // _ = b.addSystemCommand(&[_][]const u8{ "as", "-target", "x86_64-pc-none-gnu", "src/boot.s" });
    // _ = std.ChildProcess.exec(.{ .allocator = b.allocator, .argv = &[_][]const u8{ "as", "-target", "x86_64-pc-none-gnu", "src/boot.s" } }) catch unreachable;

    const mode = b.standardReleaseOptions();
    const exe = b.addStaticLibrary("kernel", "src/kernel.zig");

    exe.setTarget(.{
        .cpu_arch = std.Target.Cpu.Arch.x86_64,
        .os_tag = std.Target.Os.Tag.windows,
        .abi = std.Target.Abi.none,
    });
    exe.setLinkerScriptPath(std.build.FileSource{ .path = "src/linker.ld" });

    exe.addCSourceFile("src/boot.s", &.{});
    exe.setBuildMode(mode);

    exe.install();
}
