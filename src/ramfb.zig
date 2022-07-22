const qemu_dma = @import("qemuDma.zig");
const utils = @import("utils.zig");
const serial = @import("serial.zig");
const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;

const RamFbError = error{RamfbFileNotFound};

const fb_width: u32 = 1024;
const fb_height: u32 = 768;

const fb_bpp: u32 = 4;
const fb_stride: u32 = fb_bpp * fb_width;
const fb_size: u64 = fb_stride * fb_height;

fn fourccCode(a: u32, b: u32, c: u32, d: u32) u32 {
    return (a | (b << 8) | (c << 16) | (d << 24));
}

// [15:0] R:G:B 5:6:5 little endian
const drm_format_rgb565: u32 = fourccCode('R', 'G', '1', '6');
// [23:0] R:G:B little endian
const drm_format_rgbB888: u32 = fourccCode('R', 'G', '2', '4');
// [31:0] x:R:G:B 8:8:8:8 little endian
const drm_format_xrgb8888: u32 = fourccCode('X', 'R', '2', '4');

var fb: *anyopaque = undefined;
var ramfb_cfg: qemu_dma.QemuRAMFBCfg = undefined;

pub fn ramfbSetup(allocator: *WaterMarkAllocator, heap_start: *anyopaque) !void {
    _ = allocator;
    const select: u32 = qemu_dma.qemuCfgFindFile() orelse return RamFbError.RamfbFileNotFound;

    serial.kprintf("found ramfb_cfg \n", .{}) catch unreachable;

    // fb = allocator.malloc(fb_size) catch unreachable;
    ramfb_cfg = qemu_dma.QemuRAMFBCfg{
        .addr = @byteSwap(u64, @ptrToInt(heap_start)),
        .fourcc = @byteSwap(u32, drm_format_xrgb8888),
        .flags = 0,
        .width = @byteSwap(u32, fb_width),
        .height = @byteSwap(u32, fb_height),
        .stride = @byteSwap(u32, fb_stride),
    };
    serial.kprintf("inited struct cfg \n", .{}) catch unreachable;

    qemu_dma.qemuCfgWriteEntry(&ramfb_cfg, select, @sizeOf(qemu_dma.QemuRAMFBCfg));
    serial.kprintf("after write \n", .{}) catch unreachable;
}
