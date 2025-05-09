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
	push qword rbx
	push qword rsi ; [rsp + 8]
	push qword rdi ; [rsp]

	mov rcx, [rsp]
	mov rdx, [rcx]
	mov rbx, rdx; at this point is created
	mov rdi, [rdx]; created - data
	; call _puts
	mov rcx, [rsp]
	mov rdi, [rsp + 8]
	call _ft_create_elem ; *new
	test rax, rax
	jz .return
	; rax ptr
	; [rax] data
	; [rax + 8] next ptr
	; mov qword [rbx + 8], qword rax; FUCK This sets current->next = new
	mov [rax + 8], rbx ; new->next = cur
	mov rcx, [rsp] ; **list
	mov [rcx], rax ; *list = new
.return:
	leave
	ret