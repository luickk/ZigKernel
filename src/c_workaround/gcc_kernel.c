#include "qemu_dma_write_workaround.h"

#define serial_mmio 0x09000000

void put_char(u8 ch) {
    *((u64*)serial_mmio) = ch;
}

void kprint(u8 *print_string, u8 len) {
    for (u8 i = 0; i < len; i++)
     {
        put_char(print_string[i]);
    }
}


void kernel_main(void) {
  kprint("test\n", 5);
  
  ramfb_cfg_write_workaround(2097152);
  
  kprint("done\n", 5);

  while (1);
}