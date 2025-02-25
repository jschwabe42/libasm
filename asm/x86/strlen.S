strlen:
	push    rbp  /* save baseptr */
	mov     rbp, rsp  /* set baseptr to current stack ptr */
	mov     qword ptr [rbp-24], rdi
	mov     qword ptr [rbp-8], 0 /* init counter var */
	jmp     .L2
.L3:
	add     qword ptr [rbp-8], 1 /* increment counter */
.L2:
	mov     rdx, qword ptr [rbp-24] /* load input into rdx */
	mov     rax, qword ptr [rbp-8] /* load counter into rax */
	add     rax, rdx /* add counter to input (offset) */
	movzx   eax, byte ptr [rax] /* current char: move with zero extend (prefix) single byte at rax into eax (32bit) */
	test    al, al /* is the current character a null byte? */
	jne     .L3
	mov     rax, qword ptr [rbp-8] /* load counter into rax */
	pop     rbp /* restore baseptr (to caller) */
	ret