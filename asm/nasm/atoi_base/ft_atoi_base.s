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
	; check for other characters by subtraction
	sub dil, 0x09 ; subtract tab ascii value
	cmp dil, 5
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
	je .yes
	xor rax, rax
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
.loop_outer:
	cmp r8, rsi ; compare to length
	jge .return_ok
	; char c: outer character position
	movzx rdi, byte [rdx + r8]
	call check_non_pfx ; check c
	cmp rax, 1
	je .return_err
	; nested loop
	mov r9, r8 ; r9 = r8 + 1
	inc r9
	jmp .loop_inner
.loop_inner:
	cmp r9, rsi
	jge .next_outer ; r9 >= rsi
	movzx rcx, byte [rdx + r9]
	cmp cl, dil
	je .return_err
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

; rdi, rsi, rdx call with str, base, base_len
convert:
	mov rcx, rdi ; save rdi (str)
	xor rax, rax ; initialize total (rax busy)
.loop_convert_outer:
	movzx rdi, byte [rcx]
	test rdi, rdi
	jz .do_return ; end of str!
	push rax
	call _my_isspace
	cmp rax, 1
	je .ret_zero
	pop rax
	mov r9, -1 ; digit_value
	xor r10, r10 ; inner loop counter
.loop_inner:
	cmp r10, rdx
	jge .loop_sanity_check
	; run loop with comparison, assignment
	movzx rdi, byte [rcx]
	movzx r11, byte [rsi + r10]
	cmp dil, r11b
	je .inner_base_found
	inc r10
	jmp .loop_inner
.inner_base_found:
	mov r9, r10 ; digit_value becomes i
.loop_sanity_check:
	cmp r9, -1 ; check digit_value has changed
	je .do_return
.loop_outer_next:
	imul rax, rdx ; prevent issues with rdx when using `mul` instead
	add rax, r9
	inc rcx
	jmp .loop_convert_outer
.ret_zero:
	xor rax, rax
	ret
.do_return:
	ret

; rdi: str, rsi: base
; @audit leave causing stack corruption
_ft_atoi_base:
	push rdi
	mov rdi, rsi
	call _ft_strlen
	cmp rax, 2
	jl .ret_zero ; base is less than 2 characters
	push rsi ; base
	push rax ; length
	mov rsi, rax
	; rdi: base, rsi: length 
	call _check_base
	test rax, rax
	jnz .ret_zero ; base checks failed
	mov r8, [rsp + 16] ; access input (str)
.skip_ws:
	movzx rdi, byte [r8] ; byte at current address index
	call _my_isspace
	test rax, rax
	jz .check_prefix ; zero: no more prefix
	inc r8
	jmp .skip_ws
.check_prefix:
	xor rcx, rcx
	movzx rdi, byte [r8]
	cmp dil, 0x2D ; '-'
	jne .check_plus
	;path A: sure to be negative at this point
	mov cl, 1 ; sign flag
	inc r8
.check_plus:
	;path B: positive or no prefix
	cmp dil, 0x2B ; '+'
	jne .start_conversion
	inc r8
	jmp .start_conversion
.start_conversion:
	mov rdi, r8 ; &str[..]
	pop rdx ; base_length
	pop rsi ; base
	pop rax ; dump str from stack
	push rcx ; sign
	; call with str, base, base_len
	call convert
	; apply sign
	pop rcx
	cmp rcx, 1
	je .ret_sign
	; mov rax, 1
	; leave
	ret
.ret_sign:
	; called if sign is 1 (cl)
	; mov rax, 1
	neg rax
	; leave
	ret
.ret_zero:
	xor rax, rax
	; mov rax, 1
	ret
