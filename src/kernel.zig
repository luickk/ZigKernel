const serial = @import("serial.zig");
const frame_buff_writer = @import("frame_buffer.zig").fb_writer;

export fn kernel_main() callconv(.Naked) noreturn {
    // serial.kprint("hello world");

    var fb = frame_buff_writer.init();
    fb.fb_clear();
    fb.fb_write('H', 0);
    fb.fb_write('E', 1);
    fb.fb_write('L', 2);
    fb.fb_write('L', 3);
    fb.fb_write('O', 4);

    while (true) {}
}
