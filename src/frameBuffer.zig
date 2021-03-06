pub const FbWriter = struct {
    pub const VgaColor = enum(u8) { black, blue, gree, cyan, red, magenta, brown, grey, dark_grey, bright_blue, bright_gree, bright_cyan, bright_red, bright_magenta, yellow, white };
    const x86_vga_address = 0xB8000;
    const x86_vga_buf_size = 2200;

    // default is x86 addresses and size
    buff_address: u64,
    buff_size: i64,
    fb_buffer: []u16,

    fore_color: u8,
    back_color: u8,

    pub fn fbWrite(self: FbWriter, ch: u8, fb_buff_index: u64) void {
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

    pub fn fbClear(self: FbWriter) void {
        var i: u64 = 0;
        while (i <= self.buff_size) : (i += 1) {
            self.fb_write(self.back_color, i);
        }
    }

    pub fn init() FbWriter {
        var fb = FbWriter{
            .buff_address = x86_vga_address,
            .buff_size = x86_vga_buf_size,
            .fb_buffer = undefined,
            .fore_color = @enumToInt(VgaColor.black),
            .back_color = @enumToInt(VgaColor.white),
        };

        fb.fb_buffer.ptr = @intToPtr([*]u16, fb.buff_address);
        return fb;
    }
};
