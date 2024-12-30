; arithmatic calculator

section .data
    NEW_LINE db 0xA
    INPUT_PROMPT_OP db "Enter the oporation(+,-,*): "
    INPUT_PROMPT1 db "Enter the number1: "
    INPUT_PROMPT2 db "Enter the number2: "
    OUT_MSG db "Answer: "
    char_count db 0
    reader_pointer db 0
    integer_result dd 0   


section .bss
    number1 resb 8
    number2 resb 8
    number resb 8
    oporation resb 1
    buffer resb 8   

    char_out resb 1
    temp resb 1  ; Temporary buffer to store one character at a time

global _start
global clear_input_buffer

section .text

_start:
    jmp prompt1

prompt1:
    mov eax, 4
    mov edx, 19
    lea ecx, [INPUT_PROMPT1]
    mov ebx, 1
    int 0x80
    jmp read1

read1:                               ;Read the number input from the keyboard. (reading only one digit number)
    mov byte [reader_pointer], 0
    mov dword [integer_result], 0
    call read_multiDigitNum
    mov eax, [integer_result]
    mov [number1],eax
    call clear_input_buffer
    jmp prompt2

prompt2:
    mov eax, 4
    mov edx, 19
    lea ecx, [INPUT_PROMPT2]
    mov ebx, 1
    int 0x80
    jmp read2

read2:                               ;Read the number input from the keyboard. (reading only one digit number)
    mov byte [reader_pointer], 0
    mov dword [integer_result], 0
    call read_multiDigitNum
    mov eax, [integer_result]
    mov [number2],eax
    call clear_input_buffer
    jmp prompt3


prompt3:
    mov eax, 4
    mov edx, 28
    lea ecx, [INPUT_PROMPT_OP]
    mov ebx, 1
    int 0x80
    jmp read3

read3:                               ;Read the number input from the keyboard. (reading only one digit number)
    mov eax, 3
    mov ebx, 0
    mov ecx, oporation
    mov edx, 1
    int 0x80
    call clear_input_buffer
    jmp calculate_option





clear_input_buffer:
    ; Continuously read until no more input (newline or EOF)
.loop:
    mov eax, 3         ; sys_read
    mov ebx, 0         ; File descriptor: stdin
    lea ecx, [temp]    ; Temporary buffer address
    mov edx, 1         ; Read one character
    int 0x80           ; System call

    cmp byte [temp], 0xA ; Check if the character is newline ('\n')
    je .done            ; Exit loop if newline is found

    test eax, eax       ; Check if EOF (read result is 0)
    jz .done

    jmp .loop           ; Keep clearing the buffer
.done:
    ret

calculate_option:
    mov eax, [oporation]
    cmp al, '+'
    je addition
    cmp al, '-'
    je subtraction
    cmp al, '*'
    je multiplication
    jmp exit

addition:
    mov eax, [number1]
    add eax, [number2]
    mov [number],eax
    jmp print_result

subtraction:
    mov eax, [number1]
    sub eax, [number2]
    mov [number],eax
    jmp print_result

multiplication:
    mov eax, [number1]
    mul word [number2]
    mov [number],eax
    jmp print_result

print_result:
    mov eax, 4
    mov ebx, 8
    lea ecx, [OUT_MSG] 
    mov edx, 1
    int 0x80
    jmp conv_num


; creating ascii numbers stack for given number
; Below code will print an int in number variable as a ascii number

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

exit:
    mov eax, 1
    mov ebx, 0
    int 0x80