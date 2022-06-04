const serial = @import("serial.zig");
const frame_buff_writer = @import("frame_buffer.zig").FbWriter;
const utils = @import("utils.zig");
const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;
const ramFb = @import("ramfb.zig");

export fn kernel_main() callconv(.Naked) noreturn {
    serial.kprint("start \n");
    // get address of external linker script variable which marks stack-top and heap-start
    const heap_start: *anyopaque = @as(*anyopaque, @extern(?*u8, .{ .name = "_stack_top" }) orelse unreachable);

    // var fb = FbWriter.init();
    // // fb.fb_buffer.ptr = @intToPtr([*]u16, 0x09020000);
    // fb.fb_clear();
    // fb.fb_write('H', 0);
    // fb.fb_write('E', 1);
    // fb.fb_write('L', 2);
    // fb.fb_write('L', 3);
    // fb.fb_write('O', 4);

    // var l = "dd";
    // var p = "dd";
    // if (utils.str_cmp(l, p, l.len, p.len)) {
    //     serial.kprint("same \n");
    // }

    var allocator = WaterMarkAllocator.init(heap_start, 4000);

    _ = allocator.malloc(100) catch unreachable;

    ramFb.ramfb_setup(&allocator) catch unreachable;

    serial.kprint("end \n");
    while (true) {}
}
