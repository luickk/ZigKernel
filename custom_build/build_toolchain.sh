rm -r build
mkdir build
cd build
zig build-obj -femit-bin=kernel.o -O ReleaseSmall -target aarch64-linux-gnu ../../src/aarch64_serial_print.zig
aarch64-linux-gnu-gcc -c -o start.o ../../src/boot.s
aarch64-linux-gnu-ld -nostdlib -o kernel.elf -T ../../src/linker.ld kernel.o