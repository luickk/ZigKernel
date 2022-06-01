const std = @import("std");
const warn = @import("std").debug.warn;
const os = @import("std").os;

pub fn build(b: *std.build.Builder) void {

    // zig build solution (not working)
    const exe = b.addExecutable("kernel", "src/aarch64_serial_print.zig");
    exe.setTarget(.{ .cpu_arch = std.Target.Cpu.Arch.aarch64, .os_tag = std.Target.Os.Tag.freestanding, .abi = std.Target.Abi.gnu });
    exe.setBuildMode(std.builtin.Mode.ReleaseSmall);

    exe.setLinkerScriptPath(std.build.FileSource{ .path = "src/linker.ld" });
    exe.addCSourceFile("src/boot.s", &.{});

    exe.install();
}
