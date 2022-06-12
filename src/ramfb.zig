const allocator = @import("allocator.zig");
const qemu_dma = @import("qemu_dma.zig");
const utils = @import("utils.zig");
const serial = @import("serial.zig");

const WaterMarkAllocator = @import("allocator.zig").WaterMarkAllocator;

const fb_width: u32 = 1024;
const fb_height: u32 = 768;

const fb_bpp: u32 = 4;
const fb_stride: u32 = fb_bpp * fb_width;
const fb_size: u64 = fb_stride * fb_height;

const RamFbError = error{RamfbFileNotFound};

var ramfb_cfg: qemu_dma.QemuRAMFBCfg = undefined;
var fb: *anyopaque = undefined;
var f: u32 = undefined;

fn fourcc_code(a: u32, b: u32, c: u32, d: u32) u64 {
    return (a | (b << 8) | (c << 16) | (d << 24));
}

// [15:0] R:G:B 5:6:5 little endian
const drm_format_rgb565 = fourcc_code('R', 'G', '1', '6');
// [23:0] R:G:B little endian
const drm_format_rgbB888 = fourcc_code('R', 'G', '2', '4');
// [31:0] x:R:G:B 8:8:8:8 little endian
const drm_format_xrgb8888 = fourcc_code('X', 'R', '2', '4');

pub fn ramfb_setup(alloc: *WaterMarkAllocator) !void {
    const select = qemu_dma.qemu_cfg_find_file() orelse return RamFbError.RamfbFileNotFound;
    serial.kprint("before  malloc \n");
    fb = try alloc.malloc(fb_size);
    ramfb_cfg = .{
        .addr = @byteSwap(u64, @ptrToInt(fb)),
        .fourcc = @byteSwap(u32, drm_format_xrgb8888),
        .flags = 0,
        .width = @byteSwap(u32, fb_width),
        .height = @byteSwap(u32, fb_height),
        .stride = @byteSwap(u32, fb_stride),
    };
    qemu_dma.qemu_cfg_write_entry(&ramfb_cfg, select, @sizeOf(qemu_dma.QemuRAMFBCfg));
    serial.kprint("after write \n");
}
