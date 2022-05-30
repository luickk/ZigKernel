zig build-obj -O ReleaseSmall -target aarch64-linux-gnu ../src/kernel.zig
as -target aarch64-linux-gnu ../src/boot.s
