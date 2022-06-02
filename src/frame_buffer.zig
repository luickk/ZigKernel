pub const fb_writer = struct {
    pub const vga_color = enum(u8) { black, blue, gree, cyan, red, magenta, brown, grey, dark_grey, bright_blue, bright_gree, bright_cyan, bright_red, bright_magenta, yellow, white };
    const x86_vga_address = 0xB8000;
    const x86_vga_buf_size = 2200;

    // default is x86 addresses and size
    buff_address: usize,
    buff_size: i64,
    fb_buffer: []u16,

    fore_color: u8,
    back_color: u8,

    pub fn fb_write(self: fb_writer, ch: u8, fb_buff_index: u64) void {
        var ax: u16 = 0;
        var ah: u8 = 0;
        var al: u8 = 0;

        ah = self.back_color;
        ah <<= 4;
        ah |= self.fore_color;
        ax = ah;
        ax <<= 8;
        al = ch;
        ax |= al;

        self.fb_buffer[@as(usize, fb_buff_index)] = ax;
    }

    pub fn fb_clear(self: fb_writer) void {
        var i: u64 = 0;
        while (i <= self.buff_size) : (i += 1) {
            self.fb_write(self.back_color, i);
        }
    }

    pub fn init() fb_writer {
        var fb = fb_writer{
            .buff_address = x86_vga_address,
            .buff_size = x86_vga_buf_size,
            .fb_buffer = undefined,
            .fore_color = @enumToInt(vga_color.black),
            .back_color = @enumToInt(vga_color.white),
        };

        fb.fb_buffer.ptr = @intToPtr([*]u16, fb.buff_address);
        fb.fb_clear();
        return fb;
    }
};
