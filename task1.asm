section .data
    STR_VAL db "this is the sample text",0x00
    STR_VAL_LEN equ 24
    INPUT_PROMPT db "String: "
    INPUT_PROMPT2 db 0xA,"Enter a character: "
    OUT_MSG db "input character is found "
    OUT_MSG2 db " time/s in the string",0xA
    char_count dd 0                 ;Define a memory location to store the character count (initially zero)

section .bss
    character resb 1

global _start

section .text

_start:
    jmp prompt

prompt:
    mov eax, 4
    mov edx, 8
    lea ecx, [INPUT_PROMPT]
    mov ebx, 1
    int 0x80
    mov eax, 4
    mov edx, STR_VAL_LEN
    lea ecx, [STR_VAL]
    mov ebx, 1
    int 0x80
    mov eax, 4
    mov edx, 20
    lea ecx, [INPUT_PROMPT2]
    mov ebx, 1
    int 0x80
    jmp read


read:                               ;Read a character input from the keyboard.
    mov eax, 3
    mov ebx, 0
    mov ecx, character
    mov edx, 1
    int 0x80
    jmp count

count:
    mov esi, STR_VAL
    mov eax, 0
    jmp count_chars

count_chars:
    xor edx, edx
    xor ecx, ecx
    mov dl, byte [esi]
    cmp dl, 0x00
    je update_char_count
    mov cl, [character]
    cmp dl, cl
    je count_chars2
    inc esi
    jmp count_chars

count_chars2:
    inc eax
    inc esi
    jmp count_chars
    
update_char_count:
    mov [char_count], eax           ; now eax has the maching character count
    jmp write

write:
    mov eax, 4
    mov edx, 25
    lea ecx, [OUT_MSG]
    mov ebx, 1
    int 0x80
    mov ebx, 1
    xor ecx, ecx
    mov eax, [char_count]
    add eax, 48
    mov [char_count],eax
    lea ecx, [char_count]
    mov edx, 1
    mov eax, 4
    int 0x80
    mov eax, 4
    mov edx, 22
    lea ecx, [OUT_MSG2]
    mov ebx, 1
    int 0x80
    jmp exit

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80