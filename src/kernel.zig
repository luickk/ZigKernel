const vga_address = 0xB8000;
const buff_size = 2200;

var vga_buffer: *u16 = 0;

const vga_color = enum { black, blue, gree, cyan, red, magenta, brown, grey, dark_grey, bright_blue, bright_gree, bright_cyan, bright_red, bright_magenta, yellow, white };

fn vga_entry(ch: u8, fore_color: u8, back_color: u8) u16 {
    var ax: u16 = 0;
    var ah: u8 = 0;
    var al: u8 = 0;

    ah = back_color;
    ah <<= 4;
    ah |= fore_color;
    ax = ah;
    ax <<= 8;
    al = ch;
    ax |= al;

    return ax;
}

fn clear_vga_buffer(buffer: **u16, fore_color: u8, back_color: u8) void {
    for (buff_size) |i| {
        (*buffer)[i] = vga_entry(0, fore_color, back_color);
        // print("i: {} {} {} {}", .{ i, fore_color, back_color, buffer });
    }
}

fn init_vga(fore_color: u8, back_color: u8) void {
    vga_buffer = @as(*u16, vga_address);
    clear_vga_buffer(&vga_buffer, fore_color, back_color);
}

export fn kernel_entry() void {
    init_vga(white, black);

    vga_buffer[0] = vga_entry('H', white, black);
    vga_buffer[1] = vga_entry('e', white, black);
    vga_buffer[2] = vga_entry('l', white, black);
    vga_buffer[3] = vga_entry('l', white, black);
    vga_buffer[4] = vga_entry('o', white, black);
    vga_buffer[5] = vga_entry(' ', white, black);
    vga_buffer[6] = vga_entry('W', white, black);
    vga_buffer[7] = vga_entry('o', white, black);
    vga_buffer[8] = vga_entry('r', white, black);
    vga_buffer[9] = vga_entry('l', white, black);
    vga_buffer[10] = vga_entry('d', white, black);
}
