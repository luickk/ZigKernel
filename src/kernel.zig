const vga_address = 0xB8000;
const buff_size: i64 = 2200;

const vga_color = enum(u8) { black, blue, gree, cyan, red, magenta, brown, grey, dark_grey, bright_blue, bright_gree, bright_cyan, bright_red, bright_magenta, yellow, white };

fn vga_entry(ch: u8, fore_color: vga_color, back_color: vga_color) u16 {
    var ax: u16 = 0;
    var ah: u8 = 0;
    var al: u8 = 0;

    ah = @enumToInt(back_color);
    ah <<= 4;
    ah |= @enumToInt(fore_color);
    ax = ah;
    ax <<= 8;
    al = ch;
    ax |= al;

    return ax;
}

fn clear_vga_buffer(buffer: *[]u16, fore_color: vga_color, back_color: vga_color) void {
    var i: usize = 0;
    while (i <= buff_size) : (i += 1) {
        buffer.*[i] = vga_entry(0, fore_color, back_color);
    }
}

fn init_vga(vga_buffer: *[]u16, fore_color: vga_color, back_color: vga_color) void {
    // vga_buffer.* = @as(*u16, vga_address);
    clear_vga_buffer(vga_buffer, fore_color, back_color);
}

export fn kernel_main() void {
    var vga_buffer: []u16 = undefined;
    vga_buffer.ptr = @intToPtr([*]u16, vga_address);
    init_vga(&vga_buffer, vga_color.white, vga_color.black);

    vga_buffer[0] = vga_entry('H', vga_color.white, vga_color.black);
    vga_buffer[1] = vga_entry('e', vga_color.white, vga_color.black);
    vga_buffer[2] = vga_entry('l', vga_color.white, vga_color.black);
    vga_buffer[3] = vga_entry('l', vga_color.white, vga_color.black);
    vga_buffer[4] = vga_entry('o', vga_color.white, vga_color.black);
    vga_buffer[5] = vga_entry(' ', vga_color.white, vga_color.black);
    vga_buffer[6] = vga_entry('W', vga_color.white, vga_color.black);
    vga_buffer[7] = vga_entry('o', vga_color.white, vga_color.black);
    vga_buffer[8] = vga_entry('r', vga_color.white, vga_color.black);
    vga_buffer[9] = vga_entry('l', vga_color.white, vga_color.black);
    vga_buffer[10] = vga_entry('d', vga_color.white, vga_color.black);
}
