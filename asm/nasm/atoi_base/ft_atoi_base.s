section .text
global _ft_atoi_base

; rdi: str, rsi: base
_ft_atoi_base:
	xor rax, rax
	; @todo implement checks: base
	; @todo implement checks: str
	; @follow-up return on error
	; @todo implement conversion
	ret