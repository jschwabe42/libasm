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
.loop_inner:
	cmp r9, rsi
	je .next_outer ; r9 >= rsi
	movzx rcx, byte [rdx + r9]
	movzx rdi, byte [rdx + r8]
	cmp rcx, rdi
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

; rdi, rsi, rdx, rcx: call with str, base, base_len, sign
; @todo use callee-saved registers for often-used data (r8, rdx)
convert:
	mov r8, rcx
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
	je .loop_sanity_check
	; run loop with comparison, assignment
	movzx rdi, byte [rcx]
	movzx r11, byte [rsi + r10]
	cmp dil, r11b
	je .inner_base_found
	inc r10
	jmp .loop_inner
.inner_base_found:
	mov r9, r10 ; digit_value becomes i
	jmp .loop_sanity_check
.insanity:
	imul rax, r8
	ret
.loop_sanity_check:
	cmp r9, -1 ; check digit_value has changed
	je .insanity
.loop_outer_next:
	imul rax, rdx ; prevent issues with rdx when using `mul` instead
	add rax, r9
	inc rcx
	jmp .loop_convert_outer
.ret_zero:
	pop rax
	xor rax, rax
	ret
.do_return:
	cmp r8, 1
	je .sign
	ret
.sign:
	neg rax
	ret

; rdi: str, rsi: base
_ft_atoi_base:
	push rbx ; backup callee-save
	push r12 ; backup callee-save
	push rdi
	mov rbx, rdi ; str at rbx
.base_len:
	mov rdi, rsi
	call _ft_strlen
	cmp rax, 2
	jl .ret_zero_one ; base is less than 2 characters
	mov r12, rax
.validate_base:
	; base at rdi, rsi
	push rdi ; base
	mov rsi, r12
	; rdi: base, rsi: length 
	call _check_base
	cmp rax, 0
	jne .ret_zero_two ; base checks failed
	; mov r8, [rsp + 8] ; access input (str)
.skip_ws:
	movzx rdi, byte [rbx] ; byte at current address index
	call _my_isspace
	cmp rax, 1
	jne .check_prefix ; zero: no more prefix
	inc rbx
	jmp .skip_ws
.check_prefix:
	xor rcx, rcx
	movzx rdi, byte [rbx]
	cmp rdi, 0x2D ; '-'
	jne .check_plus
	;path A: sure to be negative at this point
	mov rcx, 1 ; sign flag
	inc rbx
	jmp .start_conversion
.check_plus:
	;path B: positive or no prefix
	cmp rdi, 0x2B ; '+'
	jne .start_conversion
	inc rbx
.start_conversion:
	mov rdi, rbx ; &str[..]
	mov rdx, r12 ; provide length
	pop rsi ; base
	; call with str, base, base_len, sign
	call convert
	pop rdi ; dump str from stack
	; restore: callee-saved (length, str)
	pop r12
	pop rbx
	ret
.ret_zero_one:
	pop rdi
	xor rax, rax
	; restore: callee-saved (length, str)
	pop r12
	pop rbx
	ret
.ret_zero_two:
	pop rsi   ; Pop the base
	pop rdi   ; Pop str
	xor rax, rax
	; restore: callee-saved (length, str)
	pop r12
	pop rbx
	ret
