const utils = @import("utils.zig");

const mmio_uart = @intToPtr(*volatile u8, 0x09000000);

const KprintfParsingState = enum { filling_val, printing_ch };

const KprintfErr = error{
    TypeNotFound,
    TypeMissMatch,
};

fn put_char(ch: u8) void {
    mmio_uart.* = ch;
}

pub fn kprint(print_string: []const u8) void {
    for (print_string) |ch| {
        if (ch == 0) {}
        put_char(ch);
    }
}

pub fn kprintf(comptime print_string: []const u8, args: anytype) !void {
    comptime var print_state = KprintfParsingState.printing_ch;
    comptime var i_args_parsed: u8 = 0;
    // inline required bc not rolled out loop wouldn't mut printing_ch
    inline for (print_string) |ch, i| {
        switch (ch) {
            else => {
                if (print_state == KprintfParsingState.printing_ch) {
                    put_char(ch);
                }
            },
            '{' => {
                print_state = KprintfParsingState.filling_val;
                switch (print_string[i + 1]) {
                    'u' => {
                        if (print_string[i + 2] != '}') {
                            return KprintfErr.TypeNotFound;
                        }

                        // if (@typeInfo(@TypeOf(args[i_args_parsed])) != .Int) {
                        //     return KprintfErr.TypeMissMatch;
                        // }
                        kprint_ui(args[i_args_parsed], utils.PrintStyle.string);
                        i_args_parsed += 1;
                    },
                    else => {
                        return KprintfErr.TypeNotFound;
                    },
                }
            },
            '}' => {
                print_state = KprintfParsingState.printing_ch;
            },
            0 => break,
        }
    }
}

// pub fn kprint_ui(num: u64, print_style: utils.PrintStyle) void {
//     var ret = utils.uitoa(num, print_style);

//     var j: usize = 0;
//     while (j < ret.len) : (j += 1) {
//         put_char(ret.arr[j]);
//     }
// }

pub fn kprint_ui(num: u64, print_style: utils.PrintStyle) void {
    var str = [_]u8{0} ** 20;

    if (num == 0) {
        str[0] = 0;
        return;
    }

    var rem: u64 = 0;
    var i: u8 = 0;
    var num_i = num;
    while (num_i != 0) {
        rem = @mod(num_i, @enumToInt(print_style));
        if (rem > 9) {
            str[i] = @truncate(u8, (rem - 10) + 'a');
        } else {
            str[i] = @truncate(u8, rem + '0');
        }
        i += 1;

        num_i = num_i / @enumToInt(print_style);
    }
    utils.reverse_string(&str, i);

    var j: usize = 0;
    while (j < i) : (j += 1) {
        put_char(str[j]);
    }
}
