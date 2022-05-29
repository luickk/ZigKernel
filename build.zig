const std = @import("std");
const warn = @import("std").debug.warn;
const os = @import("std").os;

pub fn build(b: *std.build.Builder) void {
    const kernel_source = b.addObject("kernel", "src/kernel.zig");
    kernel_source.setBuildMode(b.standardReleaseOptions());
    _ = b.addObject("boot", "src/boot.s");

    // building boot elf32 assembly
    // build_assembler_boot = b.addSystemCommand(&[_][]const u8{ "as", "-target", "x86_64-pc-none-gnu", "src/boot.s" });
    // try build_assembler_boot.step.make();

    // zig build solution (not working)
    // const mode = b.standardReleaseOptions();
    // const exe = b.addStaticLibrary("kernel", "src/kernel.zig");
    // exe.setTarget(.{ .cpu_arch = std.Target.Cpu.Arch.x86_64, .os_tag = std.Target.Os.Tag.freestanding });
    // exe.setLinkerScriptPath(std.build.FileSource{ .path = "src/linker.ld" });
    // exe.addCSourceFile("src/boot.s", &.{});
    // exe.setBuildMode(mode);
    // exe.install();
}
