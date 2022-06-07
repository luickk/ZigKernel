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

// pub fn kprint_ui(num: u64) void {
//     var ret = utils.uitoa(num);

//     var j: usize = 0;
//     while (j < ret.len) : (j += 1) {
//         put_char(ret.arr[j]);
//     }
// }

// // todo => use utils.uitoa -- cant yet bc zig struct return borken
pub fn kprint_ui(num: u64) void {
    var str = [_]u8{0} ** 20;

    if (num == 0) {
        str[0] = 0;
        return;
    }

    var rem: u64 = 0;
    var i: u8 = 0;
    var num_i = num;
    while (num_i != 0) {
        rem = @mod(num_i, 2);
        if (rem > 9) {
            str[i] = @truncate(u8, (rem - 10) + 'a');
        } else {
            str[i] = @truncate(u8, rem + '0');
        }
        i += 1;

        num_i = num_i / 2;
    }
    utils.reverse_string(&str, i);

    var j: usize = 0;
    while (j < i) : (j += 1) {
        put_char(str[j]);
    }
}
