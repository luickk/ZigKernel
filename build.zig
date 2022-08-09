const std = @import("std");
const warn = @import("std").debug.warn;
const os = @import("std").os;

pub fn build(b: *std.build.Builder) void {

    // zig build solution (not working)
    const exe = b.addExecutable("kernel", null);
    exe.setTarget(.{ .cpu_arch = std.Target.Cpu.Arch.aarch64, .os_tag = std.Target.Os.Tag.freestanding });
    exe.setBuildMode(std.builtin.Mode.ReleaseFast);

    exe.setLinkerScriptPath(std.build.FileSource{ .path = "src/linker.ld" });
    exe.addObjectFile("src/kernel.zig");
    exe.addCSourceFile("src/boot.S", &.{});
    exe.addCSourceFile("src/zig-gicv2/src/exception_vec.S", &.{});

    exe.install();

    const start_emulation_serial = b.addSystemCommand(&.{ "qemu-system-aarch64", "-machine", "virt", "-cpu", "cortex-a57", "-kernel", "zig-out/bin/kernel", "-nographic" });
    start_emulation_serial.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        start_emulation_serial.addArgs(args);
    }

    const start_emulation_ramfb = b.addSystemCommand(&.{ "qemu-system-aarch64", "-machine", "virt", "-cpu", "cortex-a57", "-kernel", "zig-out/bin/kernel", "-device", "ramfb", "-serial", "stdio" });
    start_emulation_ramfb.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        start_emulation_ramfb.addArgs(args);
    }

    const start_emulation_ramfb_gdb = b.addSystemCommand(&.{ "qemu-system-aarch64", "-s", "-S", "-machine", "virt", "-cpu", "cortex-a57", "-kernel", "zig-out/bin/kernel", "-device", "ramfb", "-serial", "stdio" });
    start_emulation_ramfb_gdb.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        start_emulation_ramfb_gdb.addArgs(args);
    }

    const run_step_ramfb = b.step("emulate-ramfb", "emulate the kernel with graphics and ramfb interface");
    run_step_ramfb.dependOn(&start_emulation_ramfb.step);

    const run_step_ramfb_gdb = b.step("emulate-ramfb-gdb", "emulate the kernel with graphics and ramfb interface and a gdb server");
    run_step_ramfb_gdb.dependOn(&start_emulation_ramfb_gdb.step);

    const run_step_serial = b.step("emulate-serial", "emulate the kernel with no graphics and output uart to console");
    run_step_serial.dependOn(&start_emulation_serial.step);

    const test_obj_step = b.addTest("src/utils.zig");
    const test_step = b.step("test", "Run tests for testable kernel parts");
    test_step.dependOn(&test_obj_step.step);
}
