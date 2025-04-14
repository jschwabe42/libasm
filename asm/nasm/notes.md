# x86_64 intel syntax assembly
## example function

```asm
foo:
    pushq %rbx # Save registers, if needed
    pushq %r12
    pushq %r13
    subq $0x18, %rsp # Allocate stack space
    # Function body
    addq $0x18, %rsp # Deallocate stack space
    popq %r13 # Restore registers
    popq %r12
    popq %rbx ret # Pop return address and return control to caller
```
[source](https://cs.brown.edu/courses/cs033/docs/guides/x64_cheatsheet.pdf)
## function arg registers
RDI, RSI, RDX, RCX, R8, R9
## registers
- rax stores return value (up to 64 bits)
- %rax, %rcx, %rdx, %rdi, %rsi, %rsp, and %r8-r11 are considered caller-save registers (not necessarily saved across calls)
- Registers %rbx, %rbp, and %r12-r15 are callee-save registers (saved across function calls):
    1. the current value of each should be pushed onto the stack to be restored at the end. For example: 
        ```asm
        Pushq %rbx
        pushq %r12
        pushq %r13
        ```
    2. when function is finished and the return value (if any) is placed in
%rax, return control to the caller, putting the stack back in the state it was called with. 
        
        2.1. First, the callee frees the stack space it allocated by adding the same amount
        to the stack pointer:
        ```asm
        addq $0x18, %rsp # Give back 24 bytes of stack space
        ```
        2.2. Then, it pops off the registers it saved earlier
        ```asm
        popq %r13 # Remember that the stack is FILO!
        popq %r12
        popq %rbx
        ```
    3. Finally, the program should return to the call site:
`ret`
- rsp stack pointer
## initialize variables
- initialize `mov rax, 0` (gets optimized into) `xor rax, rax` for performance
- `test al, al` is often preferred over `cmp al, 0`
- `inc rsi` shorter than `add rsi, 1`
```asm
# copy index from rsi into rdi: 
mov al, [rsi]
mov [rdi], al
```
## local variables & stack
While it is possible to
make space on the stack as needed in a function body, it is generally more efficient to allocate
this space all at once at the beginning of the function.

This can be accomplished using the call
subq $N, %rsp where N is the size of the callee’s stack frame.
### function prologue
```asm
subq $0x18, %rsp # Allocate 24 bytes of space on the stack
```

### Using the Stack Frame
Once you have set up the stack frame, you can use it to store and access local variables:
- Arguments which cannot fit in registers (e.g. structs) will be pushed onto the stack before
the call instruction, and can be accessed relative to `%rsp`. **Keep in mind that you will
need to take the size of the stack frame into account when referencing arguments in this
manner.**
- If the function has more than [six integer or pointer arguments](#function-arg-registers), these will be pushed onto
the stack as well.
- For any stack arguments, the lower-numbered arguments will be closer to the stack
pointer. That is, arguments are pushed on in right-to-left order when applicable.
- Local variables will be stored in the space allocated in the function prologue, when some
amount is subtracted from %rsp. The organization of these is up to the programmer.