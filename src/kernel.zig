const serial = @import("serial.zig");
const frame_buff_writer = @import("frame_buffer.zig").FbWriter;
const utils = @import("utils.zig");
const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;

export fn kernel_main() callconv(.Naked) noreturn {
    serial.kprint("start");
    // get address of external linker script variable which marks stack-top and heap-start
    const heap_start: *u8 = @extern(?*u8, .{ .name = "_stack_top" }) orelse unreachable;

    // var fb = FbWriter.init();
    // // fb.fb_buffer.ptr = @intToPtr([*]u16, 0x09020000);
    // fb.fb_clear();
    // fb.fb_write('H', 0);
    // fb.fb_write('E', 1);
    // fb.fb_write('L', 2);
    // fb.fb_write('L', 3);
    // fb.fb_write('O', 4);

    // var l = "dd";
    // var p = "cc";
    // _ = utils.str_cmp(l, p, l.len, p.len);

    // var allocator = WaterMarkAllocator.init(@ptrToInt(heap_start));

    // _ = allocator.malloc(100) catch unreachable;

    serial.kprint("end");
    while (true) {}
}
