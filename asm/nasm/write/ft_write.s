extern ___error

section .data
	int_max dq 0x7FFFFFFFFFFFFFFF

section .text
global _ft_write

; input: int fildes, const void *buf, size_t nbyte
; input in rdi, rsi, rdx
_ft_write:
	cmp rdx, [rel int_max]
	jg .error_einval
	mov rax, 0x2000004 ; MacOS 0x2000000 + 4
	syscall
	jc .error_syscall
	ret
.error_einval:
	; somehow set error and then return appropriate code
	; preserve base pointer, set new base pointer, call ___error
	call ___error
	; we now have rax as location for setting EINVAL
	mov dword [rax], 22; @follow-up dword?
	jmp .error_ret
.error_syscall:
	neg rax; negate for (CF) errored
	mov rdx, rax
	call ___error
	mov [rax], edx; @follow-up dword?, edx is 32-bit part of rdx
	jmp .error_ret
.error_ret:
	mov rax, -1
	ret