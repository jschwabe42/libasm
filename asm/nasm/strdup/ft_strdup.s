extern _ft_strcpy
extern _ft_strlen
extern _malloc
extern ___error

section .text
global _ft_strdup

; input in rdi
_ft_strdup:
	; assuming non-null ptr to chars, get length in rax
	push rdi; save input ptr
	call _ft_strlen
	; rax contains length without terminator
	inc rax
	; call with rax value
	mov rdi, rax
	call _malloc
	test rax, rax
	jz .error_malloc
	mov rdi, rax ; provide dest: new allocation
	pop rsi ; pop input as second param
	call _ft_strcpy
	ret
.error_malloc:
	pop rdx ; pop input ptr to restore stack
	; handle null return from malloc (error)
	call ___error
	mov dword [rax], 12 ; ENOMEM
	; return null
	xor rax, rax
	ret
