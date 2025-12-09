global main
extern system_call
extern strlen
newline: db 10       ; newline character
section .text
main:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]       ; argc
    mov ecx, eax           ; counter = argc
    cmp ecx, 1
    jle .done              ; if argc <= 1, exit (no argv[1..])

    mov esi, [ebp+12]      ; argv pointer
    add esi, 4             ; skip argv[0], start with argv[1]

.loop:
    mov eax, [esi]         ; pointer to current argv[i]
    push eax
    call strlen
    add esp, 4

    push eax               ; length
    push dword [esi]       ; buffer pointer
    push dword 1           ; stdout
    push dword 4           ; sys_write
    call system_call
    add esp, 16

; write newline
    push 1                 ; length = 1 byte
    push newline           ; buffer pointer
    push dword 1           ; stdout
    push dword 4           ; sys_write
    call system_call
    add esp, 16

    add esi, 4             ; move to next argv[i]
    sub ecx, 1
    cmp ecx, 1             ; have we printed all arguments?
    jg .loop               ; if more, loop

.done:
    mov eax, 0
    pop ebp
    ret