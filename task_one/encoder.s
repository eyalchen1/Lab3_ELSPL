section .bss
buffer: resb 1       ; 1 byte buffer

section .text
global main
extern system_call

main:
    push ebp
    mov ebp, esp

.read_loop:
    ; read 1 byte from stdin (fd=0)
    push 1          ; length
    push buffer     ; buffer pointer
    push 0          ; fd = stdin
    push 3          ; sys_read
    call system_call
    add esp, 16
        cmp eax, 0      ; eax = number of bytes read
    je .done        ; EOF, exit

    ; eax contains number of bytes read (1)
    ; get the byte from buffer into eax
    mov al, [buffer]
    movzx eax, al       ; zero-extend to 32-bit
    call encode         ; eax = encoded char

    ; write the encoded char
    mov [buffer], al
    push 1
    push buffer
    push 1
    push 4              ; sys_write
    call system_call
    add esp, 16
    jmp .read_loop      ; repeat

.done:
    mov eax, 1          ; sys_exit
    xor ebx, ebx
    int 0x80


encode:
    push ebp
    mov ebp, esp

    ; eax contains the character
    mov al, al       ; ensure we're working with the lower byte (optional)

    cmp al, 'A'
    jb .not_letter      ; below 'A'
    cmp al, 'Z'
    jle .letter         ; uppercase letter

    cmp al, 'a'
    jb .not_letter      ; below 'a'
    cmp al, 'z'
    jle .letter         ; lowercase letter
.not_letter:
    ; do nothing
    jmp .done

.letter:
    add al, 3           ; encode the letter

.done:
    pop ebp
    ret


