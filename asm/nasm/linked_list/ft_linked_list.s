default rel

extern _malloc
extern ___error

section .data
	ELEM_SIZE equ 16
	NEXT_OFFSET equ 8

section .text
extern _print_dbg_list
extern _debug_outer_iter
extern _debug_outer_iter_done
extern _debug_inner_cmp
extern _debug_inner_cond
extern _debug_outer_cond
extern _debug_outer_cond_complete
global _ft_create_elem
global _ft_list_push_front
global _ft_list_size
global _ft_list_sort
extern _puts

; input in rdi: data ptr
; return t_list *self
_ft_create_elem:
	enter 0, 0
	push rdi
	mov rdi, ELEM_SIZE
	call _malloc
	test rax, rax
	jz .error_malloc
	; rax has 16 bytes
	pop qword [rax]; data ptr
	mov qword [rax + NEXT_OFFSET], 0; next ptr
	leave
	ret
.error_malloc:
	call ___error
	mov qword [rax], 12 ; ENOMEM
	xor rax, rax
	leave
	ret

; rdi: **list
; rsi: *data
_ft_list_push_front:
	enter 0, 0
	push qword rdi ; [rsp]
.elem_node:
	mov rdi, rsi
	call _ft_create_elem ; *new
	test rax, rax
	; rax contains ptr to new
	; [rax] data
	; [rax + 8] next ptr
	jz .return
.update_ptrs:
	mov rcx, qword [rsp]; store **list at rcx
	push qword [rcx]; push *list == cur (save head)
	mov [rcx], rax ; *list = new (discard [rcx])
	pop qword [rax + NEXT_OFFSET]; new->next = cur
.return:
	leave
	ret

; rdi *list
_ft_list_size:
	mov r8, rdi; cur
	mov rax, 0
.loop_cond:
	test r8, r8
	jz .return_len
	inc rax
.loop_body:
	mov r9, [r8 + NEXT_OFFSET]; next
	test r9, r9
	mov r8, r9
	jnz .loop_cond
.return_len:
	ret

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

	mov r8, qword [rdi]  ; cur->data == tmp
	mov r9, qword [rsi]  ; next->data
	mov [rdi], r9  ; cur->data = next->data
	mov [rsi], r8  ; next->data = tmp
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
_ft_list_sort:
	enter 0, 0
	; preserve registers: callee-save
	push r14
	push  r12; [rsp + 24]
	mov r12, qword [rdi]; cur = *list
	push  r13; [rsp + 16]
	mov r13, qword [r12 + NEXT_OFFSET]; (*list)->next
	mov r14, 0; bool: sorted?
	; preserve input
	push  rsi; [rsp + 8] cmp
	push  rdi; [rsp] **list
	; print unsorted list
	mov rdi, [rdi]
	call _print_dbg_list
.outer_loop_cond:
	cmp r14, 0
	je .set_sorted
	leave
	ret
.set_sorted:
	mov r14, 1
.inner_loop_cond:
	test r12, r12; cur
	jz .outer_loop_iter
	test r13, r13; next
	jz .outer_loop_iter
	; neither is null!
	mov rdx, [rsp + 8]; cmp
	mov rdi,  r12; rdi: cur
	mov rsi,  r13; rsi: next
	call lswap; cur, next, cmp
	cmp rax, r14
	jne .not_sorted
	jmp .inner_loop_advance
.not_sorted:
	mov r14, 0
.inner_loop_advance:
	push  r12
	push  r13
	lea rdi, [rsp + 8]; &cur
	lea rsi, [rsp]; &next
	call advance
	pop  r13
	pop  r12
	jmp .inner_loop_cond
.outer_loop_iter: ; @audit-ok
	mov rdi, [rsp]; **list @audit-ok
	push  r12
	push  r13
	; load adresses
	lea rsi, [rsp + 8]
	lea rdx, [rsp]
	call reset_to_head; lst, &cur, &next
	pop r13
	pop r12
	jmp .outer_loop_cond
