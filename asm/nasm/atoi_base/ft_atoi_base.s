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
	movzx rax, byte [rdi + r8]
	cmp al, 0x2B ; '+'
	je .return_err
	cmp al, 0x2D ; '-'
	je .return_err
	push rax
	; START: check isspace
	push rdi
	push rsi
	mov rdi, rax
	call _my_isspace
	pop rsi
	pop rdi
	cmp rax, 1
	je .return_err
	pop rax
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
	mov rcx, [rdi + r9]
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
	; if space found (1) -> return 0
	cmp rax, 1
	je .ret_zero
	pop rax
	mov r9, -1 ; digit_value
	xor r10, r10 ; inner loop counter
	jmp .loop_inner
.loop_inner:
	cmp r10, rdx
	jge .loop_sanity_check
	; run loop with comparison, assignment
	movzx rdi, byte [rcx]
	movzx r11, byte [rsi + r10]
	cmp dil, r11b
	je .inner_base_found
.inner_base_found:
	mov r9, r10
	jmp .loop_sanity_check
.loop_sanity_check:
	cmp r9, -1
	; mov rax, r8
	jne .loop_outer_next
	ret
.loop_outer_next:
	; mov rax, r8
	mul rdx
	add rax, r9
	; mov r8, rax
	; calculate result, put back into r8
	inc rcx
	jmp .loop_convert_outer
.ret_zero:
	xor rax, rax
	ret
.do_return:
	; put total into rax
	; mov rax, r8
	ret


; rdi: str, rsi: base
_ft_atoi_base:
	push rbx
	push rdi
	mov rdi, rsi
	call _ft_strlen
	cmp rax, 2
	jl .ret_zero ; base is less than 2 characters
	push rsi ; base
	push rax ; length
	mov rsi, rax
	; rdi: base, rsi: length 
	call check_base
	test rax, rax
	jnz .ret_zero ; base checks failed
	; @todo implement checks: str
	; skip whitespace prefixes
	mov rbx, [rsp + 16] ; access input (str)
.skip_ws:
	movzx rdi, byte [rbx] ; byte at current address index
	call _my_isspace
	test rax, rax
	jz .check_prefix ; zero: no more prefix
	inc rbx
	jmp .skip_ws
.check_prefix:
	; @follow-up return on error
	; @todo implement conversion
	xor rcx, rcx
	movzx rdi, byte [rbx]
	cmp dil, 0x2D ; '-'
	jne .check_plus
	;path A: sure to be negative at this point
	mov cl, 1 ; sign flag
	inc rbx
.check_plus:
	;path B: positive or no prefix
	cmp dil, 0x2B ; '+'
	jne .start_conversion
	inc rbx
	jmp .start_conversion
.start_conversion:
	mov rdi, rbx ; &str[..]
	pop rdx ; base_length
	pop rsi ; base
	pop rax ; dump str from stack
	push rcx ; sign
	; call with str, base, base_len
	call convert
	; apply sign
	pop rcx
	cmp cl, 1
	je .ret_sign
	leave
	ret
.ret_sign:
	; called if sign is 1 (cl)
	neg rax
	leave
	ret
.ret_zero:
	xor rax, rax
	ret
