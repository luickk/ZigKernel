const serial = @import("serial.zig");
const frame_buff_writer = @import("frameBuffer.zig").FbWriter;
const utils = @import("utils.zig");
const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;
const ramFb = @import("ramFb.zig");
const qemu_dma = @import("qemuDma.zig");

const intHandle = @import("zig-gicv2/src/intHandle.zig");
const gic = @import("zig-gicv2/src/gicv2.zig");
const irqUtils = @import("zig-gicv2/src/utils.zig");

comptime {
    @export(intHandle.common_trap_handler, .{ .name = "common_trap_handler", .linkage = .Strong });
}

export fn kernel_main() callconv(.Naked) noreturn {
    // get address of external linker script variable which marks stack-top and heap-start
    const heap_start: *anyopaque = @as(*anyopaque, @extern(?*u8, .{ .name = "_stack_top" }) orelse {
        serial.kprintf("error reading _stack_top label\n", .{}) catch unreachable;
        unreachable;
    });

    // GIC Init
    gic.gicv2Initialize();

    // irqUtils.exception_svc_test();

    var allocator = WaterMarkAllocator.init(heap_start, 5000000);

    ramFb.ramfbSetup(&allocator, heap_start) catch |err| {
        serial.kprintf("error while setting up ramfb: {u} \n", .{@errorToInt(err)}) catch unreachable;
    };

    while (true) {}
}

export fn el1_sp0_sync() void {}
export fn el1_sp0_irq() void {}
export fn el1_sp0_fiq() void {}
export fn el1_sp0_error() void {}
export fn el1_irw() void {}
export fn el1_sync() void {}
export fn el1_fiq() void {}
export fn el1_error() void {}
export fn el0_sync() void {}
export fn el0_irq() void {}
export fn el1_irq() void {}
export fn el0_fiq() void {}
export fn el0_error() void {}
export fn el0_32_sync() void {}
export fn el0_32_irq() void {}
export fn el0_32_fiq() void {}
export fn el0_32_error() void {}
