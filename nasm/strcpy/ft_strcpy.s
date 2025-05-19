%ifidn __OUTPUT_FORMAT__, macho64
	%define SYM(x) _ %+ x
%elifidn __OUTPUT_FORMAT__, elf64
	section .note.GNU-stack
	%define SYM(x) x
%else
	%error "Unsupported output format"
%endif

section .text
global SYM(ft_strcpy)

; input in rdi, rsi
SYM(ft_strcpy):
	; save dest (rdi) on stack
	push rdi
.loop:
	mov al, [rsi]
	mov [rdi], al
	; test rdi for nul terminator (after assignment/termination)
	cmp al, 0
	je .done
	inc rsi
	inc rdi
	; otherwise next iteration
	jmp .loop
.done:
	; return ptr to rdi using rax (restore rdi from stack)
	pop rax
	ret
