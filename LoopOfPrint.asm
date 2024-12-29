
section .data
    MSG db "Hello_World", 0xA
    MSG_LEN equ 12

global _start
section .text

_start:
    mov eax, 0
    jmp loop_a

loop_a:
    add eax, 1
    cmp eax, 5
    jl write
    jmp exit



write:
    mov eax, 4
    mov ebx, 1
    mov ecx, MSG
    mov edx, MSG_LEN
    int 0x80
    jmp loop_a

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80