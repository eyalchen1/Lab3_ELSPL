global main
extern system_call
extern strlen

main:
    push ebp
    mov ebp, esp

    mov eax, [ebp+8]       ; argc
    cmp eax, 2
    jl .done               ; if no argv[1], exit

    mov esi, [ebp+12]      ; argv pointer
    mov eax, [esi+4]       ; argv[1] pointer
    push eax
    call strlen
    add esp, 4             ; clean stack

    push eax               ; length
    push dword [esi+4]     ; buffer pointer (argv[1])
    push dword 1           ; stdout
    push dword 4           ; sys_write
    call system_call
    add esp, 16            ; clean stack

.done:
    mov eax, 0
    pop ebp
    ret