const serial = @import("serial.zig");

pub const PrintStyle = enum(u8) {
    string = 10,
    hex = 16,
    binary = 2,
};

pub fn str_cmp(str1: [*]const u8, str2: [*]const u8, str1_len: usize, str2_len: usize) bool {
    var i_cmp: usize = 0;
    if (str1_len != str2_len) {
        return false;
    }
    while (i_cmp < str1_len) : (i_cmp += 1) {
        if (str1[i_cmp] != str2[i_cmp]) {
            return false;
        }
    }
    return true;
}

pub fn memcmp_str(s1: [*]const u8, s2: [*]const u8, n: usize) bool {
    var n_i = n;
    while (n_i > 0) : (n_i -= 1) {
        if (s1[n] - s2[n] > 0) {
            return false;
        }
    }
    return true;
}

pub fn assert(ok: bool) void {
    if (!ok) unreachable; // assertion failure
}

pub fn reverse_string(str: [*]u8, len: usize) void {
    var start: usize = 0;
    var end: usize = len - 1;
    var temp: u8 = 0;

    while (end > start) {
        temp = str[start];
        str[start] = str[end];
        str[end] = temp;

        start += 1;
        end -= 1;
    }
}

// 20 is u64 max len in u8
pub fn uitoa(num: u64, print_style: PrintStyle) struct { arr: [20]u8, len: u8 } {
    var str = [_]u8{0} ** 20;

    if (num == 0) {
        str[0] = 0;
        return .{ .arr = str, .len = 0 };
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
    reverse_string(&str, i);
    return .{ .arr = str, .len = i };
}

test "itoa test" {
    const res = uitoa(32, PrintStyle.string).arr;
    assert(res[0] == '3');
    assert(res[1] == '2');

    const res2 = uitoa(89367549, PrintStyle.string).arr;
    assert(res2[0] == '8');
    assert(res2[1] == '9');
    assert(res2[2] == '3');
    assert(res2[3] == '6');
    assert(res2[4] == '7');
    assert(res2[5] == '5');
    assert(res2[6] == '4');
    assert(res2[7] == '9');
}

test "reverse_string test" {
    var res = "abvc".*;
    reverse_string(@as([*]u8, &res), 4);
    assert(res[0] == 'c');
    assert(res[1] == 'v');
    assert(res[2] == 'b');
    assert(res[3] == 'a');
}

test "str_cmp test" {
    var l = "dd";
    var p = "dd";
    if (!str_cmp(l, p, l.len, p.len)) {
        assert(false);
    }
}

test "str memcmp test" {
    var l = "dd";
    var p = "dd";
    if (!memcmp_str(l, p, l.len)) {
        assert(false);
    }
}
