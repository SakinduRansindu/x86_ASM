section .data
    IN_LEN equ 10
    MSG db "you entered: "
    PROMT db "Enter something: "

section .bss
    usr_input resb IN_LEN

global _start

section .text
_start:
    jmp prompt_user
    

read:                              ; read is a symbolic lable and can be used to jump to a instruction address
    mov eax, 3
    mov ebx, 0
    mov ecx, usr_input
    mov edx, IN_LEN
    int 0x80
    jmp write

prompt_user:
    mov eax, 4
    mov ebx, 1
    mov ecx, PROMT                  ; symbolic lable used here for the string message
    mov edx, 17
    int 0x80
    jmp read


write:
    mov eax, 4
    mov ebx, 1
    mov ecx, MSG
    mov edx, 13
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, usr_input
    mov edx, IN_LEN                 ; symbolic lable used here to const lenght
    int 0x80
    jmp exit

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80