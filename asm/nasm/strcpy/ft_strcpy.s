section .text
global _ft_strcpy

; input in rdi, rsi
_ft_strcpy:
	; save dest (rdi) on stack
	push rdi
.loop:
	mov al, [rsi]
	mov [rdi], al
	; test rdi for nul terminator (after assignment/termination)
	test al, al
	je .done
	inc rsi
	inc rdi
	; otherwise next iteration
	jmp .loop
.done:
	; return ptr to rdi using rax (restore rdi from stack)
	pop rax
	ret
