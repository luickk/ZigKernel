const qemu_dma = @import("qemuDma.zig");
const utils = @import("utils.zig");
const kprint = @import("serial.zig").kprint;

const RamFbError = error{RamfbFileNotFound};

const QemuRAMFBCfg = packed struct {
    addr: u64,
    fourcc: u32,
    flags: u32,
    width: u32,
    height: u32,
    stride: u32,
};

fn fourccCode(a: u32, b: u32, c: u32, d: u32) u32 {
    return (a | (b << 8) | (c << 16) | (d << 24));
}

// [15:0] R:G:B 5:6:5 little endian
const drm_format_rgb565: u32 = fourccCode('R', 'G', '1', '6');
// [23:0] R:G:B little endian
const drm_format_rgbB888: u32 = fourccCode('R', 'G', '2', '4');
// [31:0] x:R:G:B 8:8:8:8 little endian
const drm_format_xrgb8888: u32 = fourccCode('X', 'R', '2', '4');

pub const ramFbDisplay = struct {
    fb_addr: usize,
    fb_size: u32,

    display_width: u32,
    display_height: u32,
    display_stride: u32,
    display_bpp: u32,

    pub fn init(fb_addr: usize, disp_width: u32, disp_height: u32, disp_bpp: u32) ramFbDisplay {
        var disp_stride = disp_bpp * disp_width;
        return ramFbDisplay{
            .fb_addr = fb_addr,
            .fb_size = disp_stride * disp_height,
            .display_width = disp_width,
            .display_height = disp_height,
            .display_bpp = disp_bpp,
            .display_stride = disp_stride,
        };
    }

    pub fn ramfbSetup(cfg: *ramFbDisplay) !void {
        const select: u32 = qemu_dma.qemuCfgFindFile() orelse return RamFbError.RamfbFileNotFound;

        kprint("found ramfb_cfg \n", .{});

        var ramfb_cfg = QemuRAMFBCfg{
            .addr = @byteSwap(u64, cfg.fb_addr),
            .fourcc = @byteSwap(u32, drm_format_xrgb8888),
            .flags = 0,
            .width = @byteSwap(u32, cfg.display_width),
            .height = @byteSwap(u32, cfg.display_height),
            .stride = @byteSwap(u32, cfg.display_stride),
        };

        qemu_dma.qemuCfgWriteEntry(&ramfb_cfg, select, @sizeOf(QemuRAMFBCfg));
    }

    // setting all pixels(including padding) to white
    pub fn drawAllWhite(cfg: *ramFbDisplay) void {
        var i: u32 = 0;
        while (i < cfg.fb_size) : (i += 1) {
            @intToPtr(*u8, cfg.fb_addr + i).* = 255;
        }
    }

    pub fn drawRgb256Map(cfg: *ramFbDisplay, x_res: u32, y_res: u32, rgb_map: []const u32) void {
        var rgb_map_bytes = @bitCast([]const u8, rgb_map);
        var map_stride: u32 = x_res * cfg.display_bpp;
        var map_size: u32 = map_stride * y_res;

        var i: u32 = 0;
        var map_i: u32 = 0;
        // var fb_arr = @intToPtr([*]u8, cfg.fb_addr);
        while (map_i < map_size) : (map_i += 4) {
            if (map_i % map_stride == 0 and map_i != 0) {
                i += cfg.display_stride - map_stride;
            }
            // 1 compensates for alignement (xRGB)
            @memcpy(@intToPtr([*]u8, cfg.fb_addr + i), @ptrCast([*]const u8, &rgb_map_bytes[map_i]), 4);
            i += 4;
        }
        kprint("size: {u} \n", .{map_size});
    }
};
