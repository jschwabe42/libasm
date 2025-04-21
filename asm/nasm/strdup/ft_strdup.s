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
	; provide dest/allocation, input ptr to strcpy
	; @todo
	ret
.error_malloc:
	; handle null return from malloc (error)
	; @todo set error
	; return null
	xor rax, rax
	ret
