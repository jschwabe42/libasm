%ifidn __OUTPUT_FORMAT__, macho64
	%define SYM(x) _ %+ x
%elifidn __OUTPUT_FORMAT__, elf64
	section .note.GNU-stack
	%define SYM(x) x
%else
	%error "Unsupported output format"
%endif

section .text
global SYM(ft_strcmp)

; input in rdi, rsi
SYM(ft_strcmp):
	xor rax, rax
.loop:
	; move and then test: store to allow for cmp
	movzx rcx, byte [rdi + rax]
	movzx rdx, byte [rsi + rax]
	cmp rcx, rdx
	jne .diff
	test rcx, rcx
	; rcx is terminator
	jz .equal
	inc rax
	jmp .loop
.diff:
	; rcx and rdx have different byte value (ASCII)
	sub rcx, rdx
	mov rax, rcx
	ret
.equal:
	xor rax, rax
	ret
