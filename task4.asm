section .data
    IN_LEN equ 10

section .bss
    usr_input resb IN_LEN

global _start

section .text
_start:
    jmp read
    

read:
    mov eax, 3
    mov ebx, 0
    mov ecx, usr_input
    mov edx, IN_LEN
    int 0x80
    jmp write



write:
    mov eax, 4
    mov ebx, 1
    mov ecx, usr_input
    mov edx, IN_LEN
    int 0x80
    jmp exit

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80