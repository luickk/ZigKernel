const utils = @import("utils.zig");

// probably high not low
const port_qemu_cfg_dma_addr_low = 0x09020000;

const qemu_cfg_file_dir = 0x19;

const QemuCfgDmaAccess = packed struct {
    control: u32,
    length: u32,
    address: u64,
};

const QemuCfgDmaControlBits = enum(u8) {
    qemu_cfg_dma_ctl_error = 0x01,
    qemu_cfg_dma_ctl_read = 0x02,
    qemu_cfg_dma_ctl_skip = 0x04,
    qemu_cfg_dma_ctl_select = 0x08,
    qemu_cfg_dma_ctl_write = 0x10,
};

pub const QemuRAMFBCfg = struct {
    addr: u64,
    fourcc: u32,
    flags: u32,
    width: u32,
    height: u32,
    stride: u32,
};

const QemuCfgFile = struct {
    size: u32, // file size
    select: u16, // write this to 0x510 to read it
    reserved: u16,
    name: [56]u8,
};

fn barrier() usize {
    return asm volatile ("ISB");
}

fn qemu_cfg_dma_transfer(addr: *anyopaque, length: u32, control: u32) void {
    const dma_acc: QemuCfgDmaAccess = .{ .address = @ptrToInt(addr), .length = length, .control = control };
    _ = barrier();
    var raw_ptr: *anyopaque = @intToPtr(*anyopaque, port_qemu_cfg_dma_addr_low);
    raw_ptr.* = &dma_acc;

    while (dma_acc.control) {}
}

pub fn qemu_cfg_find_file() ?u32 {
    var count: u32 = undefined;
    var e: u32 = 0;

    qemu_cfg_read_entry(&count, qemu_cfg_file_dir, @sizeOf(@TypeOf(count)));

    while (e < count) : (e += 1) {
        var qfile: QemuCfgFile = undefined;
        qemu_cfg_read(&qfile, @sizeOf(@TypeOf(qfile)));

        if (utils.str_cmp(&qfile.name, "etc/ramfb", 9, 9)) {
            return qfile.select;
        }
    }
    return null;
}

fn qemu_cfg_read(buff: *anyopaque, len: u32) void {
    qemu_cfg_dma_transfer(buff, len, @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read));
}

fn qemu_cfg_read_entry(buff: *anyopaque, e: u32, len: usize) void {
    var control: u32 = (e << 16) | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read;
    qemu_cfg_dma_transfer(buff, len, control);
}

pub fn qemu_cfg_write_entry(buff: *anyopaque, e: u32, len: usize) void {
    var control: u32 = (e << 16) | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_write;
    qemu_cfg_dma_transfer(buff, len, control);
}
