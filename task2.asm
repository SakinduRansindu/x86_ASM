section .data
    MULTIPLIER equ 2
    NEW_LINE db 0xA
    INPUT_PROMPT db "Enter a number: "
    OUT_MSG db "Multiplied Number: "

section .bss
    number resb 8
    char_out resb 1

global _start

section .text

_start:
    jmp prompt

prompt:
    mov eax, 4
    mov edx, 16
    lea ecx, [INPUT_PROMPT]
    mov ebx, 1
    int 0x80
    jmp read

read:                               ;Read the number input from the keyboard.
    mov eax, 3
    mov ebx, 0
    mov ecx, number
    mov edx, 1
    int 0x80
    mov eax, [number]
    sub eax, 48
    mov [number],eax
    jmp multiply_init

multiply_init:
    mov eax, 0
    mov ecx, 0
    mov edx, [number]
    cmp edx, 0
    je update_final_value
    jmp multiply

multiply:
    add eax, [number]
    inc ecx
    cmp ecx, MULTIPLIER
    je update_final_value
    jmp multiply

update_final_value:
    mov [number],eax
    jmp write


write:
    mov eax, 4
    mov edx, 19
    lea ecx, [OUT_MSG]
    mov ebx, 1
    int 0x80
    jmp conv_num

conv_num:
    ;convert to ascii

write_nl:
    mov eax, 4
    mov edx, 1
    lea ecx, [NEW_LINE]
    mov ebx, 1
    int 0x80
    jmp exit

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80