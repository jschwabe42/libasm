strlen:
	push    rbp  /* save baseptr */
	mov     rbp, rsp  /* set baseptr to current stack ptr */
	mov     rcx, 0 /* initialize counter */
.loop:
	movzx   eax, byte ptr [rdi + rcx] /* current char: move with zero extend (prefix) */
	test    al, al /* is the current character a null byte? */
	jz      .done /* jump if zero */
	inc     rcx /* increment */
	jmp     .loop
.done:
	mov     rax, rcx /* load counter for return */
	pop     rbp /* restore baseptr (to caller) */
	ret