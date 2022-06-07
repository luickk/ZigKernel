const utils = @import("utils.zig");
const serial = @import("serial.zig");

// probably high not low
const qemu_cfg_dma_base_addr = 0x09020000;

const qemu_cfg_dma_base_dma_addr = 0x10;

const qemu_cfg_dma_ctl_error = 0x01;

const qemu_cfg_file_dir = 0x19;

const QemuCfgDmaAccess = packed struct {
    control: u32,
    len: u32,
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

fn barrier() void {
    asm volatile ("ISB");
}

fn qemu_cfg_dma_transfer(addr: u64, len: u32, control: u32) void {
    serial.kprint("control field:");
    serial.kprint_ui(@byteSwap(u32, control));
    var dma_acc: QemuCfgDmaAccess = .{ .control = @byteSwap(u32, control), .len = @byteSwap(u32, len), .address = @byteSwap(u64, addr) };
    barrier();
    // writing to most significant with offset 0 since it's aarch*64*
    const base_addr_upper = @intToPtr(*u64, qemu_cfg_dma_base_dma_addr);
    base_addr_upper.* = @byteSwap(u64, @ptrToInt(&dma_acc));

    // rather ugly cast to volatile with off alignment (because of packed struct) required
    const dma_acc_ctrl_check = @ptrCast(*align(1) volatile u32, &dma_acc.control);
    while ((@byteSwap(u32, dma_acc_ctrl_check.*) & ~@intCast(u8, qemu_cfg_dma_ctl_error)) != 0) {
        // serial.kprint("control field:");
        // serial.kprint_ui(@byteSwap(u32, dma_acc_ctrl_check.*));
        // serial.kprint("\n");
    }
}

pub fn qemu_cfg_find_file() ?u16 {
    var count: u32 = 0;

    serial.kprint("looking entry up \n");
    qemu_cfg_read_entry(&count, qemu_cfg_file_dir, @sizeOf(u32));
    serial.kprint("conv\n");
    count = @byteSwap(u32, count);

    serial.kprint("done waiting \n");
    serial.kprint("test: \n");
    serial.kprint_ui(count);
    serial.kprint(" \n");

    var e: u16 = 0;
    while (e < count) : (e += 1) {
        var qfile: QemuCfgFile = undefined;
        qemu_cfg_read(&qfile, @sizeOf(QemuCfgFile));
        if (utils.str_cmp(&qfile.name, "etc/ramfb", 10, 10)) {
            return @byteSwap(u16, qfile.select);
        }
    }
    return null;
}

fn qemu_cfg_read(buff: *anyopaque, len: u32) void {
    qemu_cfg_dma_transfer(@ptrToInt(buff), len, @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read));
}

fn qemu_cfg_read_entry(buff: *anyopaque, e: u32, len: u32) void {
    var control: u32 = (e << 16) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read);
    qemu_cfg_dma_transfer(@ptrToInt(buff), len, control);
}

pub fn qemu_cfg_write_entry(buff: *anyopaque, e: u32, len: u32) void {
    var control: u32 = (e << 16) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_write);
    qemu_cfg_dma_transfer(@ptrToInt(buff), len, control);
}
