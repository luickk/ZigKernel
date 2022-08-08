# Minimal Bare Metal Zig Kernel for aarch64
Very basic aarch64 kernel written in Zig.

Currently based on https://wiki.osdev.org/QEMU_AArch64_Virt_Bare_Bones

# Status

I started this project with the goal of writing a simple kernel with a few drivers (in zig). Since Zig is not completely stable (yet; on aarch64), I found a few issues and quirks one of which is a compiler bug.
The compiler bug is an issue with struct returns, that is not resolved yet, it's not a dealbreaker though, since one can maneuver around that.
I posted that issue on Zigs git with a complete description of the observed behaviour and hypothesis: https://github.com/ziglang/zig/issues/11859.
For debugging purposes I implemented the ramfb driver in C as well(which helped me to resolve the issue): https://github.com/luickk/qemu-ramfb-aarch64-driver and the arm a53 interrupt controller gicv2: https://github.com/luickk/zig-gicv2.

As up to now, depending on the build mode (more on that in the gh issue), the kernel either runs fine & the ramfb driver works or it doesn't even start up.

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