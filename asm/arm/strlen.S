.global _my_strlen

_my_strlen:
	sub     sp, sp, #32
	str     x0, [sp, 8] /* store pointer on stack */
	str     xzr, [sp, 24]
	b       1f
2:
	ldr     x0, [sp, 24] /* get counter from stack */
	add     x0, x0, 1
	str     x0, [sp, 24] /* put it back */
1:
	ldr     x1, [sp, 8]
	ldr     x0, [sp, 24]
	add     x0, x1, x0
	ldrb    w0, [x0]
	cmp     w0, 0
	bne     2b
	ldr     x0, [sp, 24]
	add     sp, sp, 32
	ret