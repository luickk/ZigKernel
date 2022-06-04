const allocator = @import("allocator.zig");
const qemu_dma = @import("qemu_dma.zig");

const fb_width = 1024;
const fb_height = 768
const fb_bpp = 4
const fb_stride = fb_bpp * fb_width;
const fb_size = fb_stride * fb_height;

fn fourcc_code(a: u32, b: u32, c: u32, d: u32) u64 {
	return (a | (b << 8) |  (c << 16) | (d << 24));
} 

// [15:0] R:G:B 5:6:5 little endian
const drm_format_rgb565 = fourcc_code('R', 'G', '1', '6');
// [23:0] R:G:B little endian
const drm_format_rgbB888 = fourcc_code('R', 'G', '2', '4');
// [31:0] x:R:G:B 8:8:8:8 little endian
const drm_format_xrgb8888 = fourcc_code('X', 'R', '2', '4');

pub fn ramfb_setup() !void {
	const alloc = allocator.init();
	try fb = alloc.malloc(fb_size);

	const cfg = qemu_dma.QemuRAMFBCfg {
		.addr = &fb,
		.fourcc = drm_format_xrgb8888,
	    .flags = 0,
	    .width = fb_width,
	    .height = fb_height,
	    .stride = fb_stride,
	};
	qemu_cfg_write_entry(&cfg, select, sizeof(cfg));
}