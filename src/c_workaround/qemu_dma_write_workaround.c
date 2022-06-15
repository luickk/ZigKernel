#include "qemu_dma_write_workaround.h"

void qemu_cfg_dma_transfer(void *address, u32 length, u32 control) {
    QemuCfgDmaAccess access = { .address = __builtin_bswap64((u64)address), .length = __builtin_bswap32(length), .control = __builtin_bswap32(control) };

    if (length == 0) {
        return;
    }

    // __asm__("ISB");

	// *((u64*)BASE_ADDR) = __builtin_bswap64((u64)&access);
    uint64_t *mmio_w = (uint64_t*)BASE_ADDR;
    // u64 addr_in_mmio = *mmio_w; 
    *mmio_w = 500;

    while(__builtin_bswap32(access.control) & ~QEMU_CFG_DMA_CTL_ERROR) {}
}

static void qemu_cfg_write_entry(void *buf, u32 e, u32 len) {
    u32 control = (e << 16) | QEMU_CFG_DMA_CTL_SELECT | QEMU_CFG_DMA_CTL_WRITE;
    qemu_cfg_dma_transfer(buf, len, control);
}


void ramfb_cfg_write_workaround(u32 select) {
	struct QemuRAMFBCfg cfg = {
		.addr   = __builtin_bswap64(0x4000),
		.fourcc = __builtin_bswap32(DRM_FORMAT_XRGB8888),
		.flags  = __builtin_bswap32(0),
		.width  = __builtin_bswap32(FRAMEBUFFER_WIDTH),
		.height = __builtin_bswap32(FRAMEBUFFER_HEIGHT),
		.stride = __builtin_bswap32(FRAMEBUFFER_STRIDE),
	};
    qemu_cfg_write_entry(&cfg, select, sizeof(cfg));
}