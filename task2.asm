section .data
    MULTIPLIER equ 2
    NEW_LINE db 0xA
    INPUT_PROMPT db "Enter a number: "
    OUT_MSG db "Multiplied Number: "
    char_count db 0
    reader_pointer db 0
    integer_result dd 0               ; To store the converted integer

section .bss
    number resb 8
    char_out resb 1
    buffer resb 8                    ; Allocate space for the input


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

read:                               ;Read the number input from the keyboard. (reading only one digit number)
    call read_multiDigitNum
    mov eax, [integer_result]
    mov [number],eax
    jmp multiply_init

multiply_init:                  ; make the initial values for counters
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

; creating ascii numbers stack for given number

conv_num:
    mov eax, [number]           ; restore answer system_write use eax to store number of bytes writen
    xor edx, edx                ; Clear EDX, it will hold the remainder (digit)

    cmp eax, 9                  ; Check if EAX is one digit
    jle handle_one_digit 

convert_loop:
    cmp eax, 9                  ; Check if number is now less than 10 (one digit)
    jle handle_one_digit
    mov ebx, 10                 ; Set divisor to 10
    div ebx                     ; Divide EAX by EBX, result in EAX, remainder in EDX
    add dl, '0'                 ; Convert the remainder to ascii the dl is the last part of the edx lenght in 1 byte
    push dx                     ; Push the ascii num to stack

    mov ecx, [char_count]       ; load the stack counter, increment and save it
    inc ecx
    mov [char_count], cl

    jmp convert_loop            ; making while true loop

handle_one_digit:
    add al, '0'
    push ax
    mov ecx, [char_count]      
    inc ecx                     ; Increment the stack counter
    mov [char_count], cl        ; Store the updated counter
    jmp finish_conversion


finish_conversion:
    jmp pop_and_print           ; print the collected values in stack

; Below code will print the stack values in one line

pop_and_print:
    mov ecx, [char_count]
    cmp cl, 0
    je print_newline        ; exiting the while true loop if stack is empty

    pop dx
    mov [char_out], dl     

    mov eax, 4             ; write the number as charachter
    mov ebx, 1
    lea ecx, [char_out]
    mov edx, 1
    int 0x80

    mov ecx, [char_count]
    dec cl                 ; Decrement the stack counter
    mov [char_count], cl   ; preserve the count

    jmp pop_and_print      ; making while true loop

print_newline:          ; go to next line
    mov eax, 4
    mov ebx, 1 
    lea ecx, [NEW_LINE] 
    mov edx, 1
    int 0x80           
    jmp exit

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80


; Below code will read multi digit number from stdin (upto 10 digits)
; store the number in integer_result variable
; buffer variable and reader_pointer should be created

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