section .data
    input_buffer db 8                ; Buffer for input (size 10 bytes)
    integer_result dd 0               ; To store the converted integer
    new_line db 0xA                   ; Newline character
    reader_pointer db 0

section .bss
    buffer resb 8                    ; Allocate space for the input

section .text
    global _start

_start:
    ; Prompt for input
    mov eax, 4
    mov ebx, 1
    lea ecx, [input_buffer]
    mov edx, 14
    int 0x80
    call read_multiDigitNum
    jmp exit

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

read_multiDigitNum:
    mov eax, 3
    mov ebx, 0
    lea ecx, [buffer]
    mov edx, 10                       ; Read up to 10 characters
    int 0x80
    jmp convertToInt_init

convertToInt_init:
    ; Convert input to integer
    xor eax, eax                      ; Clear result
    xor ebx, ebx                      ; Index for processing input
    mov ecx, [buffer]
    jmp convertToInt_loop

convertToInt_loop:
    sub cl, '0' 

    cmp cl, 0                        ; Check if character is less than '0'
    jl done_conversion
    cmp cl, 9                        ; Check if character is greater than '9'
    jg done_conversion


    xor eax, eax
    mov al , byte [integer_result]         ; Load current integer result
    mov bl , 10
    mul bl
    add al, cl                      ; Add new digit value
    mov [integer_result], al         ; Store updated result

    xor eax, eax
    mov al, byte [reader_pointer]
    inc al
    mov [reader_pointer], al
    mov ecx, [buffer+eax]

    jmp convertToInt_loop


done_conversion:
    ret
