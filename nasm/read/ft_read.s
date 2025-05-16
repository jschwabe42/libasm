%ifidn __OUTPUT_FORMAT__, macho64
	%define GET_READ 0x2000003
	extern ___error
	%define GET_ERRNO ___error
	%define SYM(x) _ %+ x
%elifidn __OUTPUT_FORMAT__, elf64
	section .note.GNU-stack
	%define GET_READ 0
	extern __errno_location
	%define GET_ERRNO __errno_location wrt ..plt
	%define SYM(x) x
%else
	%error "Unsupported output format"
%endif

section .text
global SYM(ft_read)

; input: int fildes, const void *buf, size_t nbyte
; input in rdi, rsi, rdx
SYM(ft_read):
	mov rax, GET_READ ; MacOS 0x2000000 + 3, linux 0
	syscall
	cmp rax, 0
	jc .error_syscall
	ret
.error_syscall:
	; save syscall return value set global error variable
	mov rdx, rax
	call GET_ERRNO
	mov [rax], edx
	mov rax, -1
	ret
