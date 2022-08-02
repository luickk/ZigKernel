.global _start
_start:
    // setting up int. excp. vec. table
    ldr x0, = exception_vector_table
    msr vbar_el1, x0
    
    mov x0, #3 << 20
    msr cpacr_el1, x0
        
    ldr x30, = _stack_top
    mov sp, x30
    bl kernel_main
    b .
