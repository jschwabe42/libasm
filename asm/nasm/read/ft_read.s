extern __errno_location

section .text
global ft_read

; input: int fildes, const void *buf, size_t nbyte
; input in rdi, rsi, rdx
ft_read:
	mov rax, 0 ; MacOS 0x2000000 + 3, linux 0
	syscall
	cmp rax, 0
	jc .error_syscall
	ret
.error_syscall:
	; save syscall return value set global error variable
	mov rdx, rax
	call __errno_location wrt ..plt
	mov [rax], edx
	mov rax, -1
	ret