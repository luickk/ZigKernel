const std = @import("std");
const warn = @import("std").debug.warn;
const os = @import("std").os;

pub fn build(b: *std.build.Builder) void {
    const kernel_source = b.addObject("kernel", "src/kernel.zig");
    const kernel_boot = b.addObject("boot", "src/boot.S");
    kernel_source.setBuildMode(b.standardReleaseOptions());
    kernel_boot.setBuildMode(b.standardReleaseOptions());

    // b.installArtifact(kernel_source);
    // b.installArtifact(kernel_boot);

    // var build_target = .{ .cpu_arch = std.Target.Cpu.Arch.x86_64, .os_tag = std.Target.Os.Tag.e };
    // kernel_source.setTarget(build_target);
    // kernel_boot.setTarget(build_target);

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
