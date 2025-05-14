default rel

section .data
	NEXT_OFFSET equ 8

section .text
global _ft_list_sort_fn_calls

; *cur, *next, cmp
lswap:
	enter 0, 0
	push rdi; cur
	push rsi; next

	mov rdi, [rdi]; cur->data
	mov rsi, [rsi]; next->data

	call rdx; cmp
	test al, al
	jg .swap_data; > 0
	mov rax, 1
	jmp .return
.swap_data:
	pop rsi; cur
	pop rdi; next
	xor rax, rax

	mov r8, qword [rdi]; cur->data == tmp
	mov r9, qword [rsi]; next->data
	mov [rdi], r9; cur->data = next->data
	mov [rsi], r8; next->data = tmp
.return:
	leave
	ret

; **cur, **next
advance:
	; effectively `mov [rdi], [rsi]`
	mov r9, [rsi]; *next
	mov [rdi], r9; *cur = *next
	; effectively `mov [rsi], [[rsi] + NEXT_OFFSET]`
	mov r10, [r9 + NEXT_OFFSET]; (*next)->next
	; mov [r9], r10; wrong: (*next) = (*next)->next
	mov [rsi], r10; *next = (*next)->next
	ret

; **list, **cur, **next
reset_to_head:
	; setup cur = *list
	mov r9, [rdi]
	mov [rsi], r9
	; setup next to (*list)->next
	mov r10, [r9 + NEXT_OFFSET]
	mov [rdx], r10
	ret

; rdi **list
; rsi (*cmp)
_ft_list_sort_fn_calls:
	enter 0, 0
	; preserve registers: callee-save
	push qword r14
	push qword r12; [rsp + 24]
	mov r12, qword [rdi]; cur = *list
	push qword r13; [rsp + 16]
	mov r13, qword [r12 + NEXT_OFFSET]; (*list)->next
	mov r14b, 0; bool: sorted?
	; preserve input
	push  rsi; [rsp + 8] cmp
	push  rdi; [rsp] **list
.outer_loop_cond:
	cmp r14b, 0
	je .set_sorted
	leave
	ret
.set_sorted:
	mov r14b, 1
.inner_loop_cond:
	test r12, r12; cur
	jz .outer_loop_iter
	test r13, r13; next
	jz .outer_loop_iter
	; neither is null!
.do_swap:
	mov rdx, [rsp + 8]; cmp
	mov rdi, r12; rdi: cur
	mov rsi, r13; rsi: next
	call lswap; cur, next, cmp
	cmp al, r14b
	jne .not_sorted
	jmp .inner_loop_advance
.not_sorted: ; swap data
	mov r14b, 0
; .inner_loop_advance:
; 	mov r9, r13; tmp1 next
; 	mov r12, r9; *cur = tmp1 (next)
; 	mov r13, [r9 + NEXT_OFFSET]; next = tmp1->next
; 	jmp .inner_loop_cond
.inner_loop_advance:
	push r12
	push r13
	lea rdi, [rsp + 8]; &cur
	lea rsi, [rsp]; &next
	call advance
	pop r13
	pop r12
	jmp .inner_loop_cond
; .outer_loop_iter:
; 	mov rdi, [rsp]; **list
; 	mov r12, [rdi]; cur = *list
; 	mov r13, [r12 + NEXT_OFFSET]; next = cur/(*list)->next
; 	jmp .outer_loop_cond
.outer_loop_iter:
	mov rdi, [rsp]; **list
	push r12
	push r13
	; load adresses
	lea rsi, [rsp + 8]
	lea rdx, [rsp]
	call reset_to_head; lst, &cur, &next
	pop r13
	pop r12
	jmp .outer_loop_cond
