# ZigKernel for aarch64
Very basic aarch64 kernel written in Zig.

Currently based on https://wiki.osdev.org/QEMU_AArch64_Virt_Bare_Bones

## Setup

### Dependencies

- qemu-system-aarch64
- zig

To build the kernel just run </br>
`zig build` and to emulate it,</br>
`zig build emulate-serial`


## Implementing the Cirrus CLGD 54xx VGA driver bare metal (for qemu) // in proccess

The driver code can be found [here](https://github.com/torvalds/linux/blob/master/drivers/video/fbdev/cirrusfb.c) and is based on the old deprecated(less complex) linux kernel fbdev frame buffer driver.

## Ramfb

I fully implemented a friend buffer but there is no documentation or any information about the ramfb base address or mmio. In 'build_scripts/dtb.text' is the binary tree which is usually send to the bootloader(and is kept somewhere in dram) but there isn't any information about the ramfb addresses either.

## Manual Build Scripts (deprecated)

### Dependencies
- aarch64-linux-gnu-gcc
- aarch64-linux-gnu-ld
- qemu-system-aarch64
- zig

The manual build can be found in `build_scripts/` and consists of the necessary build scripts for a standarad aarch64 virtual machine. Just run `build_toolchain.sh` as well as `run_qemu.sh` to test the kernel.

A full implementation using the zig builder is in process.