default rel

extern malloc
extern __errno_location

section .data
	ELEM_SIZE equ 16
	NEXT_OFFSET equ 8

section .text
global ft_create_elem
global ft_list_push_front
global ft_list_size

; input in rdi: data ptr
; return t_list *self
ft_create_elem:
	enter 0, 0
	push rdi
	mov rdi, ELEM_SIZE
	call malloc wrt ..plt
	test rax, rax
	jz .error_malloc
	; rax has 16 bytes
	pop qword [rax]; data ptr
	mov qword [rax + NEXT_OFFSET], 0; next ptr
	leave
	ret
.error_malloc:
	call __errno_location wrt ..plt
	mov qword [rax], 12 ; ENOMEM
	xor rax, rax
	leave
	ret

; rdi: **list
; rsi: *data
ft_list_push_front:
	enter 0, 0
	push qword rdi ; [rsp]
.elem_node:
	mov rdi, rsi
	call ft_create_elem ; *new
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
ft_list_size:
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