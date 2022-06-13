const serial = @import("serial.zig");
const frame_buff_writer = @import("frame_buffer.zig").FbWriter;
const utils = @import("utils.zig");
const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;
const ramFb = @import("ramfb.zig");
const qemu_dma = @import("qemu_dma.zig");

export fn kernel_main() callconv(.Naked) noreturn {
    // get address of external linker script variable which marks stack-top and heap-start
    const heap_start: *anyopaque = @as(*anyopaque, @extern(?*u8, .{ .name = "_stack_top" }) orelse {
        serial.kprintf("error reading _stack_top label\n", .{}) catch unreachable;
        unreachable;
    });

    serial.kprintf("printf test int: {u} \n", .{100}) catch unreachable;
    serial.kprintf("printf test string: {s} \n", .{"testInsert"}) catch unreachable;
    serial.kprintf("{s}{s}", .{""}) catch |err| {
        if (err == serial.KprintfErr.NotEnoughArgs) {
            serial.kprintf("too few args\n", .{@errorToInt(err)}) catch unreachable;
        }
    };
    serial.kprintf("{s}", .{ "", "one too much" }) catch |err| {
        if (err == serial.KprintfErr.UnusedArgs) {
            serial.kprintf("unused args\n", .{@errorToInt(err)}) catch unreachable;
        }
    };

    var allocator = WaterMarkAllocator.init(heap_start, 5000000);

    ramFb.ramfb_setup(&allocator) catch |err| {
        serial.kprintf("error while setting up ramfb: {u} \n", .{@errorToInt(err)}) catch unreachable;
    };

    while (true) {}
}
