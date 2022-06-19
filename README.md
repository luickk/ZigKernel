# ZigKernel for aarch64
Very basic aarch64 kernel written in Zig.

Currently based on https://wiki.osdev.org/QEMU_AArch64_Virt_Bare_Bones

# Status

As stated by Zig, it is by far not done and although the language itself is declared as stable, a kernel is an edge case which is apperantly not completely bug free (yet).

I started this project with the goal of writing a small kernel (with userspace) in zig. I then had the idea to first implement a driver for the qemu ramfb interface in zig for this kernel.
Whilst doing this I discovered numerous (or few very elementary) flaws in Zig, which do not let me continue this project. 
I instead implemented the driver in C: https://github.com/luickk/qemu-ramfb-aarch64-driver \n and also filed an issue with a complete description of the observed behaviour and hypothesis: https://github.com/ziglang/zig/issues/11859 .

As up to now, depending on the build mode (more on that in the gh issue), the kernel ether runs but doesn't properly write to mmio or it hangs (jumps to an interrupt handler) but writes to mmio berforehand. The actual behaviour is way more complex and weird and can be read in the filed gh issue. 

## Setup

### Dependencies

- qemu-system-aarch64
- zig

To build the kernel just run </br>
`zig build` and to emulate it,</br>
`zig build emulate-serial`

## Ramfb (simple virtual display)

The driver can be found [here](https://github.com/luickk/qemu-ramfb-aarch64-driver) (C implementation)

## Manual Build Scripts (deprecated)

### Dependencies
- aarch64-linux-gnu-gcc
- aarch64-linux-gnu-ld
- qemu-system-aarch64
- zig

The manual build can be found in `build_scripts/` and consists of the necessary build scripts for a standarad aarch64 virtual machine. Just run `build_toolchain.sh` as well as `run_qemu.sh` to test the kernel.

A full implementation using the zig builder is in process.