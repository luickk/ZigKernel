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

    const start_emulation = b.addSystemCommand(&.{ "qemu-system-aarch64", "-machine", "virt", "-cpu", "cortex-a57", "-kernel", "zig-out/bin/kernel", "-nographic" });
    start_emulation.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        start_emulation.addArgs(args);
    }

    const run_step = b.step("run", "emulate the kernel");
    run_step.dependOn(&start_emulation.step);
}
