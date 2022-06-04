// probably high not low
const port_qemu_cfg_dma_addr_low = 0x09020000;

const qemu_cfg_file_dir = 0x19
const QemuCfgDmaAccess = packed struct {
	control: u32,
	length: u32,
	address: u64.
};

const QemuCfgDmaControlBits = enum {
	qemu_cfg_dma_ctl_error = 0x01,
	qemu_cfg_dma_ctl_read = 0x02,
	qemu_cfg_dma_ctl_skip = 0x04,
	qemu_cfg_dma_ctl_select = 0x08,
	qemu_cfg_dma_ctl_write = 0x10
}


const QemuRAMFBCfg = struct {
    addr: u64,
    fourcc: u32,
    flags: u32,
    width: u32,
    height: u32,
    stride: u32,
};

const QemuCfgFile = struct {
    size: u32, // file size
    select: u16, // write this to 0x510 to read it
    reserved: u16,
    name: u8[56],
};

fn barrier() usize {
    return asm volatile ("ISB");
}

fn qemu_cfg_dma_transfer(addr: u64, length: u32, control: u32) void {
	const dma_acc: QemuCfgDmaAccess = .{.address=@as(u32, addr), .length=length, control=control};
	_ = barrier();
	const reg_acc: Register.init(port_qemu_cfg_dma_addr_low);
	raw_ptr: *u32 = @intToPtr(*u32, address);
	raw_ptr.* = &dma_acc;

	while(dma_acc.control) {};
}

fn qemu_cfg_find_file(filename: []u8){
    var count: u32 = undefined; 
    var e: u32 = 0;
    var select: u32 = undefined;

    var i_cmp: usize = 0;

    qemu_cfg_read_entry(&count, QEMU_CFG_FILE_DIR, sizeof(count));

    while (e < count) : (e += 1) {
        const  qfile: QemuCfgFile = undefined;
        qemu_cfg_read(&qfile, @sizeof(qfile));
        while (i_cmp < 9) : (i_cmp += 1) {
        	if (qfile.name[i_cmp] != filename[i_cmp]) {
        		select = 
        	}
        }
        select = qfile.select;
    }
    return select;
}

fn qemu_cfg_read(buff :*u64, len: usize) void {
    qemu_cfg_dma_transfer(buff, @as(u32, len), @enumToInt(u32, QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read));
}

fn qemu_cfg_read_entry(buff :*u64, e: i32, len: usize) {
    var control: u32 = (e << 16) | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_read;
    qemu_cfg_dma_transfer(buff, len, control);
}

fn qemu_cfg_write_entry(buff :*u64, int e, int len) {
    var control: u32 = (e << 16) | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_select | QemuCfgDmaControlBits.qemu_cfg_dma_ctl_write;
    qemu_cfg_dma_transfer(buff, len, control);
}
