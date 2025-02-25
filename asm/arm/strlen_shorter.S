strlen:
    sub     sp, sp, #16       /* allocate stack space */
    str     x0, [sp, 8]       /* store ptr on stack */
    mov     x1, 0             /* init counter to 0 */
.loop:
    ldr     x0, [sp, 8]       /* load input ptr */
    add     x2, x0, x1        /* get offset for current char */
    ldrb    w3, [x2]          /* load current character */
    cmp     w3, 0             /* check for null terminator */
    beq     .done             /* on terminator, jump to done */
    add     x1, x1, 1         /* increment counter */
    b       .loop             /* loop again */
.done:
    mov     x0, x1            /* move counter to x0 (return value) */
    add     sp, sp, #16       /* deallocate stack space */
    ret