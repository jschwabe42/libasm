%ifidn __OUTPUT_FORMAT__, macho64
	extern ___error
	%define GET_ERRNO ___error
	%define SYM(x) _ %+ x
	%define SYM_SYSCALL(x) _ %+ x
%elifidn __OUTPUT_FORMAT__, elf64
	section .note.GNU-stack
	extern __errno_location
	%define GET_ERRNO __errno_location wrt ..plt
	%define SYM(x) x
	%define SYM_SYSCALL(x) x wrt ..plt
%else
	%error "Unsupported output format"
%endif

extern SYM(malloc)
extern SYM(ft_strcpy)
extern SYM(ft_strlen)

section .text
global SYM(ft_strdup)

; input in rdi
SYM(ft_strdup):
	enter 0, 0
	; assuming non-null ptr to chars, get length in rax
	push rdi; save input ptr
	call SYM(ft_strlen)
	; rax contains length without terminator
	inc rax
	; call with rax value
	mov rdi, rax
	sub rsp, 8
	call SYM_SYSCALL(malloc)
	add rsp, 8
	test rax, rax
	jz .error_malloc
	mov rdi, rax ; provide dest: new allocation
	pop rsi ; pop input as second param
	call SYM(ft_strcpy)
	leave
	ret
.error_malloc:
	leave
	; handle null return from malloc (error)
	call GET_ERRNO
	mov qword [rax], 12 ; ENOMEM
	; return null
	xor rax, rax
	ret
