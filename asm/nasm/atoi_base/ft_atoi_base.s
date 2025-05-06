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
; @todo use callee-saved registers for often-used data: rdi
convert:
	push rbx
	mov rbx, rdi
	xor r8, r8 ; initialize total (rax busy)
	jmp .loop_convert_cond
.inner_base_found:
	mov r9, r10 ; digit_value becomes i
.loop_sanity_check:
	cmp r9, -1 ; check digit_value has changed
	jne .loop_outer_next
	; imul r8d, ecx ; @audit same output if commented out will multiply rcx by r8 into rdx:rax - **overwrites** rdx (high 64 bits)
	pop rbx
	ret
.loop_outer_next:
	; mov rax, r8
	; imul rax, r12(rdx) ; prevent issues with rdx when using `mul` instead
	; add rax, r12(rdx) ; store at rdx:rax
	; mov r8, rax
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
; use rbx callee-save for str iteration
_ft_atoi_base:
	push rdi ; str tmp
	push rbx ; backup: callee-save rbx
	push rsi ; base tmp1
	; push r12 ; backup callee-save
	mov rbx, rdi ; str at rbx
.base_len:
	mov rdi, rsi
	call _ft_strlen
	cmp rax, 2
	jl .ret_zero ; base is less than 2 characters
	; mov r12, rax
.validate_base:
	; base at rdi, rsi
	; mov rsi, r12
	mov rsi, rax
	; rdi: base, rsi: length 
	call _check_base
	cmp rax, 0
	jne .ret_zero ; base checks failed
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
	mov rdx, rsi ; provide length
	pop rsi ; base tmp1
	pop rbx ; restore: callee-save rbx
	; pop r12
	; call with str, base, base_len, sign
	call convert
	pop rdi
	; pop rdi ; str tmp
	; restore: callee-saved (length, str)
	ret
.ret_zero:
	; restore: callee-saved (length, str)
	; option 1:
	; pop rsi ; base tmp1
	; pop rbx ; restore: callee-save rbx
	; option 2:
	; add rsp, 16
	; option 3:
	leave
	; pop r12
	; pop rdi ; str tmp
	xor rax, rax
	ret
