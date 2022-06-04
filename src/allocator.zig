const AllocationError = error{
    MaxMem,
    MaxFree,
};

pub const WaterMarkAllocator = struct {
    const max_frees = 100;
    alloc_base: u64,
    alloc_top: u64,

    currently_free: u32,
    max_mem: u32,
    // todo => dynamic
    freed_zones: [max_frees]struct { freed_base: *u64, freed_size: usize },

    pub fn malloc(self: *WaterMarkAllocator, size: usize) !*u64 {
        var addr = self.alloc_top;
        if (self.alloc_top + size > self.max_mem) {
            return AllocationError.MaxMem;
        }
        self.alloc_top += size;
        return @intToPtr(*u64, addr);
    }
    pub fn free(self: *WaterMarkAllocator, addr: *u32, size: usize) AllocationError {
        self.freed_zones[self.currently_free] = .{ addr, size };
        if (self.currently_free >= self.max_frees) {
            return AllocationError.MaxFree;
        }
        self.currently_free += 1;
    }
    pub fn init(base: u64) WaterMarkAllocator {
        return .{ .alloc_base = base, .alloc_top = base, .currently_free = 0, .max_mem = 5000, .freed_zones = undefined };
    }
};
