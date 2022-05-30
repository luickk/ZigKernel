zig build-obj -femit-bin=build/kernel.o -O ReleaseSmall ../src/kernel.zig 
as ../src/boot.s -o build/boot.o
ld -T ../src/linker.ld build/boot.o build/kernel.o -o os.bin