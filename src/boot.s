; by https://github.com/swarren/rpi-3-aarch64-demo
.globl _start
_start:
    ldr x5, =0x00100000
    mov sp, x5
    bl main_kernel
hang:
    b hang