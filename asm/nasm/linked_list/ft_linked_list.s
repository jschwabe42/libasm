default rel

extern _malloc
extern ___error

section .data
	ELEM_SIZE equ 16
	NEXT_OFFSET equ 8

section .text
; extern _print_dbg_list
global _ft_create_elem
global _ft_list_push_front
global _ft_list_remove_if
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
	mov qword [rax], 12; ENOMEM
	xor rax, rax
	leave
	ret

; rdi: **list
; rsi: *data
_ft_list_push_front:
	enter 0, 0
	push qword rdi; [rsp]
.elem_node:
	mov rdi, rsi
	call _ft_create_elem; *new
	test rax, rax
	; rax contains ptr to new
	; [rax] data
	; [rax + 8] next ptr
	jz .return
.update_ptrs:
	mov rcx, qword [rsp]; store **list at rcx
	push qword [rcx]; push *list == cur (save head)
	mov [rcx], rax; *list = new (discard [rcx])
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
.do_swap_inline:
	mov rdi, [r12]
	mov rsi, [r13]
	call [rsp + 8]
	cmp al, 1
	jl .inner_loop_advance; no swap
	xor r14b, r14b; not sorted
	mov r8, qword [r12]; cur->data == tmp
	mov r9, qword [r13]; next->data
	mov [r12], r9; cur->data = next->data
	mov [r13], r8; next->data = tmp
.inner_loop_advance:
	mov r9, r13; tmp1 next
	mov r12, r9; *cur = tmp1 (next)
	mov r13, [r9 + NEXT_OFFSET]; next = tmp1->next
	jmp .inner_loop_cond
.outer_loop_iter:
	mov rdi, [rsp]; **list
	mov r12, [rdi]; cur = *list
	mov r13, [r12 + NEXT_OFFSET]; next = cur/(*list)->next
	jmp .outer_loop_cond

; ft_list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(void *, void *), void (*free_fct)(void *));
; rdi: list **
; rsi: data_ref *
; rdx: cmp
; rcx: free (cur->data)
_ft_list_remove_if:
	enter 0, 0
	leave
	ret