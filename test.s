.globl test_arm

test_arm:
    udf #0x10    /* trap, use p $pc=$pc+4 in gdb to step out */
    mov r0, #0   /* blabla */
    bx lr        /* blabla */
