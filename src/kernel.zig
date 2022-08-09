const kprint = @import("serial.zig").kprint;
const frame_buff_writer = @import("frameBuffer.zig").FbWriter;
const utils = @import("utils.zig");
const ramFb = @import("ramFb.zig").ramFbDisplay;
const qemu_dma = @import("qemuDma.zig");
const test_img = @import("image_rgb_map.zig").testImg;

const intHandle = @import("zig-gicv2/src/intHandle.zig");
const gic = @import("zig-gicv2/src/gicv2.zig");
const irqUtils = @import("zig-gicv2/src/utils.zig");

export fn kernel_main() callconv(.Naked) noreturn {
    // get address of external linker script variable which marks stack-top and heap-start
    const heap_start: usize = @ptrToInt(@extern(?*u8, .{ .name = "_stack_top" }) orelse {
        kprint("error reading _stack_top label\n", .{});
        unreachable;
    });

    // GIC Init
    gic.gicv2Initialize();

    // irqUtils.exception_svc_test();

    var display = ramFb.init(heap_start, 500, 500, 4);

    display.ramfbSetup() catch |err| {
        kprint("error while setting up ramfb: {s} \n", .{@errorName(err)});
    };

    // display.drawAllWhite();
    display.drawRgb256Map(500, 500, &test_img);

    kprint("kernel boot complete \n", .{});
    while (true) {}
}

comptime {
    @export(intHandle.common_trap_handler, .{ .name = "common_trap_handler", .linkage = .Strong });
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
