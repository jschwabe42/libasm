extern ___error

section .text
global _ft_read

; input: int fildes, const void *buf, size_t nbyte
; input in rdi, rsi, rdx
_ft_read:
	mov rax, 0x2000003 ; MacOS 0x2000000 + 3
	syscall
	jc .error_syscall
	ret
.error_syscall:
	; save syscall return value set global error variable
	mov rdx, rax
	call ___error
	mov [rax], edx
	mov rax, -1
	ret