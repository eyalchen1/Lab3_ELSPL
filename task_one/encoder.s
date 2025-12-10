section .bss
buffer: resb 1       ; 1 byte buffer

section .data
newline: db 10       ; newline character

section .text
global main
extern strlen
extern system_call
main:
    push ebp
    mov ebp, esp

    ; --- get argc / argv ---
    mov eax, [ebp+8]       ; argc
    mov ecx, eax           ; counter = argc
    cmp ecx, 1
    jle .skip_args         ; if argc <= 1, skip argument printing

    mov esi, [ebp+12]      ; argv pointer
    add esi, 4             ; skip argv[0]
.argloop:
    mov eax, [esi]         ; pointer to current argv[i]
    push eax
    call strlen
    add esp, 4             ; clean stack

    push eax               ; length
    push dword [esi]       ; string pointer
    push dword 1           ; fd = stdout
    push dword 4           ; sys_write
    call system_call
    add esp, 16
    ; write newline
    push 1
    push newline
    push 1
    push 4
    call system_call
    add esp, 16

    add esi, 4
    dec ecx
    cmp ecx, 1
    jg .argloop
.skip_args:

.read_loop:
    ; read 1 byte from stdin (fd = 0)
    push 1
    push buffer
    push 0
    push 3          ; sys_read
    call system_call
    add esp, 16

    cmp eax, 0
    je .exit_main   ; EOF
    mov al, [buffer]
    movzx eax, al
    call encode
    mov [buffer], al

    ; write encoded byte
    push 1
    push buffer
    push 1
    push 4          ; sys_write
    call system_call
    add esp, 16

    jmp .read_loop

.exit_main:
    mov eax, 1      ; sys_exit
    xor ebx, ebx
    int 0x80


; --- encode function ---
encode:
    push ebp
    mov ebp, esp

    mov al, al       ; optional

    cmp al, 'A'
    jb .not_letter_enc
    cmp al, 'Z'
    jle .upper_enc

    cmp al, 'a'
    jb .not_letter_enc
    cmp al, 'z'
    jle .lower_enc

.not_letter_enc:
    jmp .done_enc

.upper_enc:
    add al, 3
    jmp .done_enc

.lower_enc:
    add al, 3

.done_enc:
    pop ebp
    ret