%ifidn __OUTPUT_FORMAT__, macho64
	%define SYM(x) _ %+ x
%elifidn __OUTPUT_FORMAT__, elf64
	section .note.GNU-stack
	%define SYM(x) x
%else
	%error "Unsupported output format"
%endif

section .text
global SYM(ft_strlen)

; input in rdi only
SYM(ft_strlen):
	; set return value
	xor rax, rax
.loop:
	; move and then test
	mov cl, byte [rdi + rax]
	cmp cl, 0
	; is zero (nul-terminator)
	je .done
	inc rax
	jmp .loop
.done:
	; return value is already at rax
	ret