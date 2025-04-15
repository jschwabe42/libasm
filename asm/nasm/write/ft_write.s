extern ___error

section .text
global _ft_write

; input: int fildes, const void *buf, size_t nbyte
; input in rdi, rsi, rdx
_ft_write:
	mov rax, 0x2000004 ; MacOS 0x2000000 + 4
	syscall
	jc .error_syscall
	ret
.error_syscall:
	; save syscall return valueö set global error variable
	mov rdx, rax
	call ___error
	mov [rax], edx
	mov rax, -1
	ret