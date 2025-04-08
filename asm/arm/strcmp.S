.global _my_strcmp
.align 2

// x0 - first string pointer (equivalent to rdi)
// x1 - second string pointer (equivalent to rsi)
// w2 - byte from first string
// w3 - byte from second string
// x4 - index counter (equivalent to rax)

// f: the next occurrence of label forward from here
// b: the previous occurrence of label backward from here

_my_strcmp:
	mov x4, #0               // Initialize counter to 0
1:
	ldrb w2, [x0, x4]
	ldrb w3, [x1, x4]
	cmp w2, w3
	// check if different
	bne 2f
	// compare to zero
	cbz w2, 3f
	// addition has 3 operands
	add x4, x4, #1
	b 1b
2:
	sub w0, w2, w3
	ret
3:
	// fine in this case (we are done using x0 and can write w0 (32 bit of x0))
	mov w0, #0
	ret
