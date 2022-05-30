mkdir build
cd build
zig build-obj -femit-bin=kernel.o -O ReleaseSmall -target aarch64-linux-gnu ../../src/kernel.zig
aarch64-linux-gnu-gcc -c -o start.o ../../src/boot.s
aarch64-linux-gnu-ld -Bstatic --gc-sections -nostartfiles -nostdlib -o app.elf -Ttext 0x8000 -T ../../src/linker.ld kernel.o
