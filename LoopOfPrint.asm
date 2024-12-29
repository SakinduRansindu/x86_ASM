
section .data
    MSG db "Hello_World", 0xA
    MSG_LEN equ 12

global _start
section .text

_start:
    mov eax, 0
    push eax
    jmp loop_a 

loop_a:
    pop eax     ;restore preserved eax value
    add eax, 1
    cmp eax, 100
    push eax    ;preserve the eax befor systemcall
    jle write
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