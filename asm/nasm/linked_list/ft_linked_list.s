default rel

extern _malloc
extern ___error

section .data
	ELEM_SIZE equ 16
	NEXT_OFFSET equ 8

section .text
extern _swap
extern _debug_outer_iter
extern _debug_outer_iter_done
extern _reset_to_head
extern _advance
extern _cmp_bubble
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

; rdi **list
; rsi (*cmp)
_ft_list_sort:
	enter 0, 0
	; preserve registers: callee-save
	push  r12; [rsp + 24]
	mov r12, qword [rdi]; cur = *list
	push  r13; [rsp + 16]
	mov r13, qword [r12 + NEXT_OFFSET]; (*list)->next
	mov r9, 0; bool: sorted?
	push  rsi; [rsp + 8] cmp
	push  rdi; [rsp] **list
.outer_loop_cond:
	call _debug_outer_cond
	cmp r9, 0
	je .var_init
	leave
	ret
.var_init:
	call _debug_outer_cond_complete
	mov r9, 1
.inner_loop_cond:
	test r12, r12; cur
	jz .outer_loop_iter
	test r13, r13; next
	jz .outer_loop_iter
	; neither is null!
	mov rdx, [rsp + 8]
	push  r12
	push  r13
	; rdi: cur->data
	mov rdi,  [rsp + 8]; @audit
	; rsi: next->data
	mov rsi,  [rsp]; @audit
	call _swap; this asserts rdx > 0 @audit violated
	cmp rax, r9
	je .inner_loop_advance
	mov r9, 0
.inner_loop_advance:
	; cur = *list
	; next = (*list)->next
	lea rsi, [rsp + 8]
	lea rdx, [rsp]
	call _advance
	pop  r13
	pop  r12
	jmp .inner_loop_cond
.outer_loop_iter: ; @audit-ok
	call _debug_outer_iter
	; deref rdi at [rsp]
	mov rdi, [rsp + 24]; **list @audit-ok
	; push  r12
	; push  r13
	; cur = *list
	; next = (*list)->next
	lea rsi, [rsp + 8]
	lea rdx, [rsp]
	call _reset_to_head
	; Load the possibly modified values back into registers
	; call _debug_outer_iter_done
	jmp .outer_loop_cond
