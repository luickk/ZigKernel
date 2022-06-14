const qemu_dma = @import("qemu_dma.zig");
const utils = @import("utils.zig");
const serial = @import("serial.zig");
const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;

const ramfb_cfg_dma_write_workaround = @cImport({
    @cInclude("qemu_dma_write_workaround.h");
});

const RamFbError = error{RamfbFileNotFound};

const fb_width: u32 = 1024;
const fb_height: u32 = 768;

const fb_bpp: u32 = 4;
const fb_stride: u32 = fb_bpp * fb_width;
const fb_size: u64 = fb_stride * fb_height;

fn fourcc_code(a: u32, b: u32, c: u32, d: u32) u32 {
    return (a | (b << 8) | (c << 16) | (d << 24));
}

// [15:0] R:G:B 5:6:5 little endian
const drm_format_rgb565: u32 = fourcc_code('R', 'G', '1', '6');
// [23:0] R:G:B little endian
const drm_format_rgbB888: u32 = fourcc_code('R', 'G', '2', '4');
// [31:0] x:R:G:B 8:8:8:8 little endian
const drm_format_xrgb8888: u32 = fourcc_code('X', 'R', '2', '4');

// var ramfb_cfg: qemu_dma.QemuRAMFBCfg = undefined;
var fb: *anyopaque = undefined;

pub fn ramfb_setup(allocator: *WaterMarkAllocator) !void {
    const select = qemu_dma.qemu_cfg_find_file() orelse return RamFbError.RamfbFileNotFound;
    serial.kprintf("before  malloc \n", .{}) catch unreachable;
    serial.kprintf("after init \n", .{}) catch unreachable;
    _ = allocator;

    ramfb_cfg_dma_write_workaround.ramfb_cfg_write_workaround(select);

    // fb = allocator.malloc(fb_size) catch unreachable;
    // var ramfb_cfg = qemu_dma.QemuRAMFBCfg{
    //     .addr = @byteSwap(u64, @ptrToInt(fb)),
    //     .fourcc = @byteSwap(u32, drm_format_xrgb8888),
    //     .flags = 0,
    //     .width = @byteSwap(u32, fb_width),
    //     .height = @byteSwap(u32, fb_height),
    //     .stride = @byteSwap(u32, fb_stride),
    // };

    // // -- cannot use existing functions(qemu_cfg_write_entry...) because of Zig Aarch64 issue described here https://github.com/ziglang/zig/issues/11859
    // var control: u32 = (select << 16) | @enumToInt(qemu_dma.QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select) | @enumToInt(qemu_dma.QemuCfgDmaControlBits.qemu_cfg_dma_ctl_write);

    // var dma_acc = .{ .control = @byteSwap(u32, control), .len = @byteSwap(u32, @sizeOf(qemu_dma.QemuRAMFBCfg)), .address = @byteSwap(u64, @ptrToInt(&ramfb_cfg)) };
    // // qemu_dma.barrier();
    // // writing to most significant with offset 0 since it's aarch*64*
    // const base_addr_upper = @intToPtr(*u64, 0x9020000 + 16);
    // base_addr_upper.* = @byteSwap(u64, @ptrToInt(&dma_acc));

    // // rather ugly cast to volatile with off alignment (because of packed struct) required
    // const dma_acc_ctrl_check = @ptrCast(*align(1) volatile u32, &dma_acc.control);
    // while ((@byteSwap(u32, dma_acc_ctrl_check.*) & ~@intCast(u8, 0x01)) != 0) {}

    serial.kprintf("done {u}\n", .{}) catch unreachable;

    // qemu_dma.qemu_cfg_write_entry(&ramfb_cfg, select, @sizeOf(qemu_dma.QemuRAMFBCfg));
    // serial.kprintf("after write \n", .{}) catch unreachable;
}
