default rel

extern _malloc
extern ___error

section .data
	ELEM_SIZE equ 16
	NEXT_OFFSET equ 8

section .text
global _ft_create_elem
global _ft_list_push_front
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