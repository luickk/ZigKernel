const serial = @import("serial.zig");
const frame_buff_writer = @import("frame_buffer.zig").FbWriter;
const utils = @import("utils.zig");
const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;
const ramFb = @import("ramfb.zig");
const qemu_dma = @import("qemu_dma.zig");

export fn kernel_main() callconv(.Naked) noreturn {
    // get address of external linker script variable which marks stack-top and heap-start
    const heap_start: *anyopaque = @as(*anyopaque, @extern(?*u8, .{ .name = "_stack_top" }) orelse {
        serial.kprint("error reading _stack_top label\n");
        unreachable;
    });

    var allocator = WaterMarkAllocator.init(heap_start, 5000000);

    // _ = allocator.malloc(100) catch unreachable;

    ramFb.ramfb_setup(&allocator) catch |err| {
        serial.kprint("err while ramfb setup, code: ");
        serial.kprint_ui(@errorToInt(err), utils.PrintStyle.string);
        serial.kprint("\n");
    };

    while (true) {}
}
