const mmio_uart = @intToPtr(*volatile u8, 0x09000000);

fn put_char(ch: u8) void {
    mmio_uart.* = ch;
}

fn kprint(print_string: []const u8) void {
    for (print_string) |ch| {
        if (ch == 0) {
            break;
        }
        put_char(ch);
    }
}

export fn kernel_main() void {
    kprint("hello world");
}
