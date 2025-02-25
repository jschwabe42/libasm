; compile with nasm -f elf64 strlen.s -o strlen.o

section .text
global strlen  ; Export the strlen symbol

strlen:
	push    rbp         ; save old baseptr
	mov     rbp, rsp    ; baseptr setup with stackptr
	; rdi already holds the pointer to the string (first argument)
	mov     rcx, 0      ; init counter to 0
.loop:
	movzx   eax, byte [rdi + rcx] ; get address of character
	test    al, al      ; check current char for null terminator
	jz      .done       ; break on 0
	inc     rcx         ; increment
	jmp     .loop
.done:
	mov     rax, rcx    ; move counter into rax (return value)
	pop     rbp         ; restore baseptr to stackptr (caller)
	ret