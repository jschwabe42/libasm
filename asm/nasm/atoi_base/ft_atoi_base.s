section .text

extern _ft_strlen
global _ft_atoi_base
global _my_isspace
global _check_base
global _check_plus_minus

; %include "macros.s"

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
	jne .other_whitespace
	mov rax, 1
	ret
.other_whitespace:
	; check for other characters by subtraction
	movzx rax, dil
	sub al, 0x09 ; subtract tab ascii value
	cmp al, 5
	setb al
	ret

; rdi: char byte - 1 on found
_check_plus_minus:
	mov rax, 1
	cmp dil, 0x2B ; '+'
	je .return
	cmp dil, 0x2D ; '-'
.return:
	sete al
	ret

; rdi: char byte
check_non_pfx:
	call _check_plus_minus
	test rax, rax
	jnz .return ; rax != 0
	call _my_isspace
.return:
	ret

; rdi: base, rsi: length 
_check_base:
	xor r8, r8
	mov rdx, rdi ; rdx: base
.loop_outer_precond:
	cmp r8, rsi ; compare to length
	jne .loop_outer
	ret
.loop_outer:
	; char c: outer character position
	movzx rdi, byte [rdx + r8] ; precondition: char c at rdi given
	call check_non_pfx ; check c
	cmp al, 1 ; return if hit
	jne .loop_init_inner
	ret
.loop_init_inner: ; r9 = r8 + 1
	lea r9, [r8 + 1]; same as `mov r9, r8`, `inc r9`
.loop_inner_precond:
	cmp r9, rsi
	je .next_outer
.loop_inner: ; r9 < rsi
	movzx rcx, byte [rdx + r9] ; precondition: char c at rdi
	cmp cl, dil
	sete al ; in this case equal to `mov al, 1`
	jne .next_inner
	ret
.next_inner:
	inc r9
	jmp .loop_inner_precond
.next_outer:
	inc r8
	jmp .loop_outer_precond

; rdi, rsi, rdx, rcx: call with str, base, base_len, sign
convert:
	enter 8, 1
	mov [rbp - 8], qword rdi ; opt1: `push rbx`, `mov rbx, rdi` (callee-save)
	xor r8, r8 ; initialize total (rax busy)
	jmp .loop_convert_cond
.loop_sanity_check: ; pcond: rax == 0
	cmp r9, -1 ; check digit_value has changed
	je .epilogue
.loop_outer_next:
	imul r8d, edx
	add r8d, r9d ; add digit value to result
	inc qword [rbp - 8]; opt1: `inc rbx`
.loop_convert_cond:
	mov rdi, qword [rbp - 8]
	movzx rdi, byte [rdi] ; opt1: `movzx rdi, byte [rbx]`
	test dil, dil
	jz .do_return ; end of str!
.loop_convert_outer:
	call _my_isspace ; rdi is preserved !
	test rax, rax
	jz .loop_inner_init; pcond: rax == 0
	setz al
	jmp .epilogue
.loop_inner_init:
	mov r9, -1 ; digit_value
	xor r10, r10 ; inner loop counter
.loop_inner:
	cmp r10, rdx
	jge .loop_sanity_check
	; run loop with comparison, assignment
	movzx r11, byte [rsi + r10]
	cmp dil, r11b
	cmove r9, r10 ; modify digit_value
	je .loop_sanity_check
	inc r10
	jmp .loop_inner
.do_return:
	mov rax, r8
	neg rax
	test ecx, ecx
	cmovz rax, r8 ; sign zero, restore positive
.epilogue:
	leave
	ret

; rdi: str, rsi: base
_ft_atoi_base:
	enter 0, 0 ; prologue
	push rbx ; backup: callee-save rbx
	push rsi ; base tmp1
	mov rbx, rdi ; str at rbx
.base_len:
	mov rdi, rsi
	call _ft_strlen
	cmp rax, 2
	jl .ret_zero ; base is less than 2 characters
.validate_base:
	mov rsi, rax
	; rdi: base, rsi: length 
	call _check_base
	test rax, rax
	jnz .ret_zero ; base checks failed
.skip_ws:
	movzx rdi, byte [rbx] ; byte at current address index
	call _my_isspace
	test rax, rax
	jz .check_prefix ; zero: no more prefix
	inc rbx
	jmp .skip_ws
.check_prefix:
	xor rcx, rcx
	movzx rdi, byte [rbx]
	cmp rdi, 0x2D ; '-'
	je .set_minus
.check_plus:
	;path B: positive or no prefix
	cmp rdi, 0x2B ; '+'
	jne .start_conversion
	inc rbx
	jmp .start_conversion
.set_minus:
	;path A: sure to be negative at this point
	mov rcx, 1 ; sign flag
	inc rbx
.start_conversion:
	mov rdi, rbx ; &str[..]
	; PRINT_PTR ; print rdi
	mov rdx, rsi ; provide length
	mov rsi, [rsp]
	; call with str, base, base_len, sign
	call convert
	leave ; option1 epilogue: pops rsi, rbx
	ret
.ret_zero:
	; option 2: epilogue - pops rsi, rbx
	mov rsp, rbp ; restore stack ptr
	pop rbp ; restore base ptr
	xor rax, rax
	ret
