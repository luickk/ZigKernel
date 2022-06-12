ENTRY(_start)
SECTIONS {
    . = 0x40000000;
    .startup . : { start.o(.text) }
    .text : { *(.text) }
    .data : { *(.data) }
    .bss : { *(.bss COMMON) }
    . = ALIGN(8);
    . += 0x2000;
    _stack_top = .;
}