ENTRY(_start)
SECTIONS {
    . = 0x40000000;
    .text : { *(.text) }
    . = ALIGN(0x800);
    .text.exceptions : { *(.text.exceptions) }
    .data : { *(.data) }
    .bss : { *(.bss COMMON) }
    . = ALIGN(8);
    . += 0x1000;
    _stack_top = .;
}