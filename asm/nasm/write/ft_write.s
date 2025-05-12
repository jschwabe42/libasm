extern __errno_location

section .text
global ft_write

; input: int fildes, const void *buf, size_t nbyte
; input in rdi, rsi, rdx
ft_write:
	mov rax, 1 ; MacOS 0x2000000 + 4, linux 1
	syscall
	cmp rax, 0
	jl .error_syscall
	ret
.error_syscall:
	; save syscall return valueö set global error variable
	mov rdx, rax
	call __errno_location wrt ..plt
	mov [rax], edx
	mov rax, -1
	ret