const utils = @import("utils.zig");

const mmio_uart = @intToPtr(*volatile u8, 0x09000000);

fn put_char(ch: u8) void {
    mmio_uart.* = ch;
}

pub fn kprint(print_string: []const u8) void {
    for (print_string) |ch| {
        if (ch == 0) {
            break;
        }
        put_char(ch);
    }
}

pub fn kprint_err(e: anyerror) void {
    for (@bitCast([2]u8, @errorToInt(e))) |ch| {
        put_char(ch);
    }
}
