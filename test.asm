; basic level assembly code, exit with exit code 0

global _start
section .text

_start
    mov eax, 1
    mov ebx, 0
    int 0x80