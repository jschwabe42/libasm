default rel

extern _malloc
extern ___error

section .data
	ELEM_SIZE equ 16
	NEXT_OFFSET equ 8

section .text
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
	push qword rbx; [rsp + 32]
	mov rbx, rsi; put cmp fnptr in callee-save rbx
	push qword r12; [rsp + 24]
	mov r12, qword [rdi]; cur = *list
	push qword r13; [rsp + 16]
	mov r13, qword [r12 + NEXT_OFFSET]; (*list)->next
	push qword r14; [rsp + 8]
	mov r14, 0; bool: sorted?
	; preserve **list
	push qword rdi; [rsp]
.outer_loop_cond:
	test r14b, r14b
	jnz .return
	mov r14b, 1; sorted = true
.inner_loop_cond:
	test r12, r12; cur
	jz .outer_loop_iter
	test r13, r13; next
	jz .outer_loop_iter
	; neither is null!
.run_cmp:
	; rdi: cur->data
	mov rdi, qword [r12]; @audit
	push rdi
	call _puts
	pop rdi
	; rsi: next->data
	mov rsi, qword [r13]; @audit
	call rbx; (*cmp)
	cmp rax, 0
	jle .inner_loop_advance
.swap:
	; rax > 0 @audit ptrs!
	mov r14b, 0; sorted = false
	mov rdi, qword [r12]; tmp = cur->data
	mov rsi, qword [r13]; next->data
	mov rdi, rsi; cur->data = next->data;
	mov rsi, rdi; next->data = tmp
.inner_loop_advance:
	mov r12, r13; cur = next
	mov rdi, [r13 + NEXT_OFFSET]
	mov r13, rdi; next = next->next
	jmp .inner_loop_cond
.outer_loop_iter:
	; deref rdi at [rsp]
	mov rdi, [rsp]; **list @audit
	; cur = *list
	mov r12, [rdi]; @follow-up is the value correct?
	; next = (*list)->next
	mov r13, qword [r12 + 8]
	jmp .outer_loop_cond
.return:
	leave
	ret