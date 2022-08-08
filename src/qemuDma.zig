const utils = @import("utils.zig");
const serial = @import("serial.zig");

const qemu_cfg_dma_base_dma_addr: u64 = 0x9020010;

const qemu_cfg_dma_ctl_error = 0x01;
const qemu_cfg_file_dir = 0x19;

pub const QemuCfgDmaAccess = packed struct {
    control: u32,
    len: u32,
    address: u64,
};

pub const QemuCfgDmaControlBits = enum(u8) {
    qemu_cfg_dma_ctl_error = 0x01,
    qemu_cfg_dma_ctl_read = 0x02,
    qemu_cfg_dma_ctl_skip = 0x04,
    qemu_cfg_dma_ctl_select = 0x08,
    qemu_cfg_dma_ctl_write = 0x10,
};

const QemuCfgFile = struct {
    size: u32, // file size
    select: u16, // write this to 0x510 to read it
    reserved: u16,
    name: [56]u8,
};

pub fn barrier() void {
    asm volatile ("ISB");
}

fn qemuCfgDmaTransfer(addr: u64, len: u32, control: u32) void {
    var dma_acc = .{ .control = @byteSwap(u32, control), .len = @byteSwap(u32, len), .address = @byteSwap(u64, addr) };

    barrier();

    // writing to most significant with offset 0 since it's aarch*64*
    const base_addr_upper = @intToPtr(*u64, qemu_cfg_dma_base_dma_addr);
    base_addr_upper.* = @byteSwap(u64, @ptrToInt(&dma_acc));

    // rather ugly cast to volatile with off alignment (because of packed struct) required
    const dma_acc_ctrl_check = @ptrCast(*align(1) volatile u32, &dma_acc.control);
    while ((@byteSwap(u32, dma_acc_ctrl_check.*) & ~@intCast(u8, qemu_cfg_dma_ctl_error)) != 0) {}
}

pub fn qemuCfgFindFile() ?u32 {
    var count: u32 = 0;
    var e: u32 = 0;
    var select: u16 = 0;
    qemuCfgReadEntry(&count, qemu_cfg_file_dir, @sizeOf(u32));
    count = @byteSwap(u32, count);

    while (e < count) : (e += 1) {
        var qfile: QemuCfgFile = undefined;
        qemuCfgRead(&qfile, @sizeOf(QemuCfgFile));
        if (utils.eql(u8, qfile.name[0..9], "etc/ramfb")) {
            select = @byteSwap(u16, qfile.select);
        }
    }
    if (select == 0)
        return null;
    return select;
}

fn qemuCfgRead(buff: *anyopaque, len: u32) void {
    qemuCfgDmaTransfer(@ptrToInt(buff), len, @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read));
}

fn qemuCfgReadEntry(buff: *anyopaque, e: u32, len: u32) void {
    var control: u32 = (e << 16) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read);
    qemuCfgDmaTransfer(@ptrToInt(buff), len, control);
}

pub fn qemuCfgWriteEntry(buff: *anyopaque, e: u32, len: u32) void {
    var control: u32 = (e << 16) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select) | @enumToInt(QemuCfgDmaControlBits.qemu_cfg_dma_ctl_write);
    qemuCfgDmaTransfer(@ptrToInt(buff), len, control);
}
