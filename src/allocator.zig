const AllocationError = error{
    MaxMem,
    MaxFree,
};

// todo => aliginment
// todo => paging
pub const WaterMarkAllocator = struct {
    const max_frees = 100;
    alloc_base: [*]u8,

    alloc_bottom: usize,
    alloc_top: usize,

    currently_free: usize,
    // todo => dynamic
    freed_zones: [max_frees]struct { freed_base: *anyopaque, freed_size: usize },

    pub fn malloc(self: *WaterMarkAllocator, size: usize) !*anyopaque {
        if (self.alloc_bottom + size > self.alloc_top) {
            return AllocationError.MaxMem;
        }
        self.alloc_bottom += size;
        return @ptrCast(*anyopaque, self.alloc_base + self.alloc_bottom);
    }

    // todo test
    pub fn free(self: *WaterMarkAllocator, addr: *usize, size: u32) AllocationError {
        self.freed_zones[self.currently_free] = .{ addr, size };
        if (self.currently_free >= self.max_frees) {
            return AllocationError.MaxFree;
        }
        self.currently_free += 1;
    }
    pub fn init(base: *anyopaque, alloc_size: usize) WaterMarkAllocator {
        return .{ .alloc_base = @ptrCast([*]u8, base), .alloc_bottom = 0, .alloc_top = alloc_size, .currently_free = 0, .freed_zones = undefined };
    }
};
