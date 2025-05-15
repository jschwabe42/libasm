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


extern SYM(ft_strcpy)
extern SYM(ft_strlen)
extern SYM(malloc)

section .text
global SYM(ft_strdup)

; input in rdi
SYM(ft_strdup):
	; assuming non-null ptr to chars, get length in rax
	push rdi; save input ptr
	call SYM(ft_strlen)
	; rax contains length without terminator
	inc rax
	; call with rax value
	mov rdi, rax
	call SYM_SYSCALL(malloc)
	test rax, rax
	jz .error_malloc
	mov rdi, rax ; provide dest: new allocation
	pop rsi ; pop input as second param
	call SYM(ft_strcpy)
	ret
.error_malloc:
	pop rdx ; pop input ptr to restore stack
	; handle null return from malloc (error)
	call GET_ERRNO
	mov dword [rax], 12 ; ENOMEM
	; return null
	xor rax, rax
	ret
