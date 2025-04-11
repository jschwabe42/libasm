section .text
global _ft_strcpy

; input in rdi, rsi
_ft_strcpy:
	xor rax, rax
.loop:
	; test rsi for nul terminator
	; otherwise dst[x] = src[x]
	; movzx [rdi + rax], [rsi + rax]
	jmp .loop
.terminate:
	; dst[x] = 0 if src[x] == 0
.done:
	; return ptr to rdi
	ret
