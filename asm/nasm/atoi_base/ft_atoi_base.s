section .text

extern _ft_strlen
global _ft_atoi_base
global _my_isspace
global _check_base


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
.other_whitespace:
	; check for other characters by subtraction
	movzx rax, dil
	sub al, 0x09 ; subtract tab ascii value
	cmp al, 5
	jb .is_space ; required: use `jb` for unsigned
	xor rax, rax
	ret
.is_space:
	mov rax, 1
	ret

; rdi: char byte - 1 on found
check_plus_minus:
	cmp dil, 0x2B ; '+'
	je .yes
	cmp dil, 0x2D ; '-'
	sete al
	ret
.yes:
	mov rax, 1
	ret

; rdi: char byte
check_non_pfx:
	call check_plus_minus
	test rax, rax
	jnz .return ; rax != 0
	call _my_isspace
	ret
.return:
	ret

; rdi: base, rsi: length 
_check_base:
	xor r8, r8
	mov rdx, rdi ; rdx: base
.loop_outer_precond:
	cmp r8, rsi ; compare to length
	jnge .loop_outer
	xor rax, rax
	ret
.loop_outer:
	; char c: outer character position
	movzx rdi, byte [rdx + r8] ; precondition: char c at rdi given
	call check_non_pfx ; check c
	cmp rax, 1 ; return if hit
	jne .loop_init_inner
	ret
.loop_init_inner:
	mov r9, r8 ; r9 = r8 + 1
	inc r9
	; nested loop
.loop_inner_precond:
	cmp r9, rsi
	je .next_outer ; r9 >= rsi
.loop_inner:
	movzx rcx, byte [rdx + r9] ; precondition: char c at rdi
	cmp cl, dil
	jne .next_inner
	mov rax, 1
	ret
.next_inner:
	inc r9
	jmp .loop_inner_precond
.next_outer:
	inc r8
	jmp .loop_outer_precond

; rdi, rsi, rdx, rcx: call with str, base, base_len, sign
; @todo use callee-saved registers for often-used data: rdi
convert:
	push rbx
	mov rbx, rdi
	xor r8, r8 ; initialize total (rax busy)
	jmp .loop_convert_cond
.inner_base_found:
	mov r9, r10 ; digit_value becomes i @follow-up cmov
.loop_sanity_check:
	; pcond1: rax == 0
	cmp r9, -1 ; check digit_value has changed
	jne .loop_outer_next
	pop rbx
	ret
.loop_outer_next:
	imul r8d, edx
	add r8d, r9d ; add digit value to result
	inc rbx
.loop_convert_cond:
	movzx rdi, byte [rbx]
	test dil, dil
	jz .do_return ; end of str!
.loop_convert_outer:
	call _my_isspace ; rdi is preserved !
	test rax, rax
	; pcond1: @audit-info precondition to sanity_check: rax == 0
	jz .loop_inner_init
	xor rax, rax
	pop rbx
	ret
.loop_inner_init:
	mov r9, -1 ; digit_value
	xor r10, r10 ; inner loop counter
.loop_inner:
	cmp r10, rdx
	jge .loop_sanity_check
	; run loop with comparison, assignment
	movzx r11, byte [rsi + r10]
	cmp dil, r11b
	je .inner_base_found
	inc r10
	jmp .loop_inner
.do_return:
	mov rax, r8
	neg rax
	test ecx, ecx
	cmovz rax, r8 ; sign zero, restore positive
	pop rbx
	ret

; rdi: str, rsi: base
; @audit use rbx callee-save for str iteration, stack vars?
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
	mov rdx, rsi ; provide length
	mov rsi, [rsp]
	; call with str, base, base_len, sign
	call convert
	leave ; epilogue: pops rsi, rbx
	ret
.ret_zero:
	; option 1:
	leave ; epilogue: pops rsi, rbx
	; option 2:
	; mov rsp, rbp ; restore stack ptr
	; pop rbp ; restore base ptr
	xor rax, rax
	ret
