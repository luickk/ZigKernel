const qemu_dma = @import("qemuDma.zig");
const utils = @import("utils.zig");
const serial = @import("serial.zig");

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

        serial.kprintf("found ramfb_cfg \n", .{});

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
    pub fn drawAllWhite(cfg: *ramFbDisplay) void {
        // setting all pixels to white
        var pixel = [3]u8{ 255, 255, 255 };
        var i: u32 = 0;
        var j: u32 = 0;
        while (i < cfg.display_width) : (i += 1) {
            while (j < cfg.display_height) : (j += 1) {
                @memcpy(@intToPtr([*]u8, cfg.fb_addr + ((j * cfg.display_stride) + (i * cfg.display_bpp))), @ptrCast([*]const u8, &pixel), 4);
            }
        }
    }
    pub fn drawRgb256Map(cfg: *ramFbDisplay, x_res: u32, y_res: u32, rgb_map: []const u32) void {
        var rgb_map_bytes = @bitCast([]const u8, rgb_map);
        var map_stride: u32 = x_res * cfg.display_bpp;
        var map_size: u32 = map_stride * y_res;

        var i: u32 = 0;
        var map_i: u32 = 0;
        while (map_i < map_size) : (map_i += 4) {
            if (map_i % map_stride == 0 and map_i != 0) {
                i += cfg.display_stride - map_stride;
            }
            // 1 compensates for alignement (xRGB)
            @memcpy(@intToPtr([*]u8, cfg.fb_addr + i), @ptrCast([*]const u8, &rgb_map_bytes[map_i]), 4);

            serial.kprintf("{u}, {u} \n", .{ i, map_i });
            i += 4;
        }
    }
};
