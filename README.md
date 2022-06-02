# ZigKernel for aarch64
Very basic aarch64 kernel written in Zig.

Currently based on https://wiki.osdev.org/QEMU_AArch64_Virt_Bare_Bones

## Setup

### Dependencies

- qemu-system-aarch64
- zig

To build the kernel just run </br>
`zig build` and to emulate it,</br>
`zig build run`

## Manual Build Scripts (deprecated)

### Dependencies
- aarch64-linux-gnu-gcc
- aarch64-linux-gnu-ld
- qemu-system-aarch64
- zig

The manual build can be found in `build_scripts/` and consists of the necessary build scripts for a standarad aarch64 virtual machine. Just run `build_toolchain.sh` as well as `run_qemu.sh` to test the kernel.

A full implementation using the zig builder is in process.