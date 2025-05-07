%macro PRINT 1
	push rax
	push rdi
	push rsi
	push rdx
	jmp %%after_data
%%str_data: ; (local to the macro invocation, %% to prevent duplicate definition)
	db %1, 0
	%%str_len equ $ - %%str_data
%%after_data:
	; macOS syscall - write(fd, buffer, size)
	mov rax, 0x2000004    ; macOS syscall number for write
	mov rdi, 1            ; file descriptor 1 is stdout
	lea rsi, [rel %%str_data] ; pointer to string (with default rel)
	mov rdx, %%str_len     ; length of string
	syscall
	
	; Restore registers
	pop rdx
	pop rsi
	pop rdi
	pop rax
%endmacro

; Print macro for a string pointer in RDI
; does not preserve flags register
%macro PRINT_PTR 0
	; Save all registers we'll use
	push rcx
	push rdx
	push rsi
	push rdi    ; Original string pointer

	call _ft_strlen
	; Set up and execute syscall
	mov rdx, rax
	mov rsi, [rsp] ; provide rdi input ptr
	mov rdi, 1 ; stdout file descriptor
	mov rax, 0x2000004
	syscall
	; 1: stack for newline
	; push 0xa
	; mov rax, 0x2000004    ; macOS syscall number for write
	; mov rdi, 1            ; file descriptor 1 is stdout
	; mov rsi, rsp ; pointer to newline character
	; mov rdx, 1            ; length of string (just 1 byte)
	; syscall
	; pop rax
	; 2: be lazy and call ; PRINT 0xa
	; 3: use local data label
	jmp %%print_newline
%%data:
	db 0xa
%%print_newline:
	mov rdx, 1
	lea rsi, [rel %%data] ; provide rdi input ptr
	mov rdi, 1 ; stdout file descriptor
	mov rax, 0x2000004
	syscall

	; Restore all registers in reverse order
	pop rdi
	pop rsi
	pop rdx
	pop rcx
%endmacro