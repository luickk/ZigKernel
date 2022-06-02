const std = @import("std");
const warn = @import("std").debug.warn;
const os = @import("std").os;

pub fn build(b: *std.build.Builder) void {

    // zig build solution (not working)
    const exe = b.addExecutable("kernel", "src/kernel.zig");
    exe.setTarget(.{ .cpu_arch = std.Target.Cpu.Arch.aarch64, .os_tag = std.Target.Os.Tag.freestanding, .abi = std.Target.Abi.gnu });
    exe.setBuildMode(std.builtin.Mode.ReleaseSmall);

    exe.setLinkerScriptPath(std.build.FileSource{ .path = "src/linker.ld" });
    exe.addCSourceFile("src/boot.s", &.{});

    exe.install();

    const start_emulation_serial = b.addSystemCommand(&.{ "qemu-system-aarch64", "-machine", "virt", "-cpu", "cortex-a57", "-kernel", "zig-out/bin/kernel", "-nographic" });
    start_emulation_serial.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        start_emulation_serial.addArgs(args);
    }

    const start_emulation_ramfb = b.addSystemCommand(&.{ "qemu-system-aarch64", "-machine", "virt", "-cpu", "cortex-a57", "-kernel", "zig-out/bin/kernel", "-device", "cirrus-vga" });
    start_emulation_ramfb.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        start_emulation_ramfb.addArgs(args);
    }

    const run_step_ramfb = b.step("emulate-ramfb", "emulate the kernel with graphics and ramfb interface");
    run_step_ramfb.dependOn(&start_emulation_ramfb.step);

    const run_step_serial = b.step("emulate-serial", "emulate the kernel with no graphics and output uart to console");
    run_step_serial.dependOn(&start_emulation_serial.step);
}
