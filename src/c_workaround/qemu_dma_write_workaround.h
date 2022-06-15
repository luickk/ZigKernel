#include  <stdint.h>

typedef uint8_t u8;
typedef int8_t s8;
typedef uint16_t u16;
typedef int16_t s16;
typedef uint32_t u32;
typedef int32_t s32;
typedef uint64_t u64;
typedef int64_t s64;
// typedef int64_t size_t;

#define FRAMEBUFFER_WIDTH      1024
#define FRAMEBUFFER_HEIGHT     768
#define FRAMEBUFFER_BPP        4
#define FRAMEBUFFER_STRIDE     (FRAMEBUFFER_BPP * FRAMEBUFFER_WIDTH)
#define FRAMEBUFFER_SIZE       (FRAMEBUFFER_STRIDE * FRAMEBUFFER_HEIGHT)

#define fourcc_code(a, b, c, d) ((u32)(a) | ((u32)(b) << 8) | \
                                 ((u32)(c) << 16) | ((u32)(d) << 24))

#define DRM_FORMAT_RGB565       fourcc_code('R', 'G', '1', '6') /* [15:0] R:G:B 5:6:5 little endian */
#define DRM_FORMAT_RGB888       fourcc_code('R', 'G', '2', '4') /* [23:0] R:G:B little endian */
#define DRM_FORMAT_XRGB8888     fourcc_code('X', 'R', '2', '4') /* [31:0] x:R:G:B 8:8:8:8 little endian */

// QEMU_CFG_DMA_CONTROL bits
#define QEMU_CFG_DMA_CTL_ERROR   0x01
#define QEMU_CFG_DMA_CTL_READ    0x02
#define QEMU_CFG_DMA_CTL_SKIP    0x04
#define QEMU_CFG_DMA_CTL_SELECT  0x08
#define QEMU_CFG_DMA_CTL_WRITE   0x10

#define BASE_ADDR 0x9020000 + 16

typedef struct {
    u32 control;
    u32 length;
    u64 address;
} __attribute__((__packed__)) QemuCfgDmaAccess;

struct QemuRAMFBCfg {
    u64 addr;
    u32 fourcc;
    u32 flags;
    u32 width;
    u32 height;
    u32 stride;
};

void ramfb_cfg_write_workaround(u32 select);