%ifidn __OUTPUT_FORMAT__, macho64
	%define GET_WRITE 0x2000004
	extern ___error
	%define GET_ERRNO ___error
	%define SYM(x) _ %+ x
%elifidn __OUTPUT_FORMAT__, elf64
	section .note.GNU-stack
	%define GET_WRITE 1
	extern __errno_location
	%define GET_ERRNO __errno_location wrt ..plt
	%define SYM(x) x
%else
	%error "Unsupported output format"
%endif

section .text
global SYM(ft_write)

; input: int fildes, const void *buf, size_t nbyte
; input in rdi, rsi, rdx
SYM(ft_write):
	mov rax, GET_WRITE ; MacOS 0x2000000 + 4, linux 1
	syscall
	cmp rax, 0
	jl .error_syscall
	ret
.error_syscall:
	; save syscall return valueö set global error variable
	mov rdx, rax
	call GET_ERRNO
	mov [rax], edx
	mov rax, -1
	ret