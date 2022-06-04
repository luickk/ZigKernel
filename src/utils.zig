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
