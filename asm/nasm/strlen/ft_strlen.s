section .text
global _ft_strlen

; input in rdi only
_ft_strlen:
	; set return value
	xor rax, rax
.loop:
	; move and then test
	mov cl, [rdi + rax]
	jmp .is_zero
.is_zero:
	test cl, cl
	; is zero (nul-terminator)
	jz .done
	inc rax
	jmp .loop
.done:
	; return value is already at rax
	ret
