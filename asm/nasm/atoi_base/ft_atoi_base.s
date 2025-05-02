section .text

extern _ft_strlen
global _ft_atoi_base
global _my_isspace


; Whitespace characters in ASCII are:
; - Space (32: 0x20)
; - Tab (9: 0x09)
; - Line feed (10: 0x0A)
; - Vertical tab (11: 0x0B)
; - Form feed (12: 0x0C)
; - Carriage return (13: 0x0D)
; we can check other than space others by subtraction:
; c - 9 < 5 or c == 32
; rdi contains character byte (8-bit) - dil has lowest byte
_my_isspace:
	; check for space
	cmp dil, 0x20 ; 32 on ascii table
	je .is_space
	; check for other characters by subtraction
	sub dil, 0x09 ; subtract tab ascii value
	cmp dil, 5
	jb .is_space ; required: use `jb` for unsigned
	xor rax, rax
	ret
.is_space:
	mov rax, 1
	ret

; rdi: base, rsi: length 
check_base:
	; @todo implement checks: base
	; use r8, r9 for loop
	; keep track of character position using al, cl
	xor r8, r8
.loop_outer:
	cmp r8, rsi ; compare to length
	jge .return_ok
	; char c: outer character position
	mov al, [rdi + r8]
	cmp al, 0x2B ; '+'
	je .return_err
	cmp al, 0x2D ; '-'
	je .return_err
	push al
	; START: check isspace
	push rdi
	push rsi
	movzx dil, al
	call _my_isspace
	pop rsi
	pop rdi
	cmp rax, 1
	je .return_err
	pop al
	; END: check isspace
	; check c
	; nested loop
	mov r9, r8
	inc r9
	; r9 = r8 + 1
	jmp .loop_inner
.loop_inner:
	cmp r9, rsi
	; r9 >= rsi
	jge .next_outer
	mov cl, [rdi + r9]
	cmp cl, al
	je .return_err
	jmp .next_inner
.next_inner:
	inc r9
	jmp .loop_inner
.next_outer:
	inc r8
	jmp .loop_outer
.return_ok:
	xor rax, rax
	ret
.return_err:
	mov rax, 1
	ret

; rdi: str, rsi: base
_ft_atoi_base:
	push rdi
	mov rdi, rsi
	call _ft_strlen
	cmp rax, 2
	jl .ret_zero ; base is less than 2 characters
	mov rsi, rax
	; rdi: base, rsi: length 
	call check_base
	test rax, 0
	jne .ret_zero ; base checks failed
	; @todo implement checks: str
	; @follow-up return on error
	; @todo implement conversion

.ret_zero:
	xor rax, rax
	ret
