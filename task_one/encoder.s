section .bss
buffer: resb 1       ; 1 byte buffer

section .rodata
    ; constants used for open flags/modes
    O_RDONLY    dd 0
    O_WRONLY    dd 1
    O_CREAT     dd 64

section .data
newline:     db 10       ; newline character
outputfile:  dd 1        ; default stdout fd
inputfile:   dd 0        ; default stdin fd

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
    jle .skip_args_print   ; if argc <= 1, skip argument printing
    ; --- parse args for -i and -o ---
    ; use local i at [ebp-4]
    sub esp, 4
    mov dword [ebp-4], 1   ; i = 1

.parse_loop:
    mov ebx, [ebp+12]      ; ebx = argv (pointer to argv[0])
    mov edx, [ebp-4]       ; edx = i
    shl edx, 2             ; edx = 4*i
    add ebx, edx           ; ebx = &argv[i]
    mov esi, [ebx]         ; esi = argv[i] (pointer to string)

    ; call strlen( argv[i] )
    push esi
    call strlen
    add esp, 4
    mov edi, eax           ; edi = strlen(argv[i])

    cmp edi, 2
    jl .skip_parse_check   ; length < 2 -> can't be -x

    ; check first char is '-'
    mov al, [esi]
    cmp al, '-'
    jne .skip_parse_check

    ; check second char
    mov al, [esi+1]
    cmp al, 'i'
    jne .check_o
    ; it's -i -> open file argv[i]+2 for reading
    lea edx, [esi+2]       ; edx = filename pointer
    push dword 0           ; mode (ignored for readonly)
    push dword [O_RDONLY]  ; flags = O_RDONLY (=0)
    push dword edx         ; filename
    push dword 5           ; sys_open
    call system_call
    add esp, 16
    mov [inputfile], eax   ; save returned fd (or negative on error)
    jmp .after_parse_check

.check_o:
    cmp al, 'o'
    jne .skip_parse_check
    ; it's -o -> open file argv[i]+2 for writing (create if needed)
    lea edx, [esi+2]       ; edx = filename pointer
    push dword 511         ; mode = 0777 octal = 511 decimal
    mov eax, [O_CREAT]
    mov ebx, [O_WRONLY]
    add eax, ebx           ; flags = O_CREAT | O_WRONLY
    push dword eax
    push dword edx
    push dword 5           ; sys_open
    call system_call
    add esp, 16
    mov [outputfile], eax  ; save returned fd
    jmp .after_parse_check

.skip_parse_check:
    ; nothing to do for this arg
.after_parse_check:
    inc dword [ebp-4]      ; i++
    mov edx, [ebp+8]       ; argc
    cmp edx, [ebp-4]
    jg .parse_loop

    add esp, 4             ; pop local i

    ; --- print all command-line arguments (debug printout) ---
    mov esi, [ebp+12]      ; argv pointer
    add esi, 4             ; skip argv[0]
.argloop:
    mov eax, [esi]         ; pointer to current argv[i]
    push eax
    call strlen
    add esp, 4             ; clean stack

    push eax               ; length
    push dword [esi]       ; string pointer
    push dword [outputfile] ; fd = outputfile instead of hardcoded 1
    push dword 4           ; sys_write
    call system_call
    add esp, 16
    ; write newline
    push 1
    push newline
    push dword [outputfile] ; fd = outputfile
    push 4
    call system_call
    add esp, 16

    add esi, 4
    dec ecx
    cmp ecx, 1
    jg .argloop

.skip_args_print:

    ; --- main read/encode/write loop ---
.read_loop:
    ; read 1 byte from inputfile
    push 1
    push buffer
    mov eax, [inputfile]
    push eax
    push 3          ; sys_read
    call system_call
    add esp, 16

    cmp eax, 0
    je .exit_main   ; EOF
    mov al, [buffer]
    movzx eax, al
    call encode
    mov [buffer], al

    ; write encoded byte to outputfile
    push 1
    push buffer
    mov eax, [outputfile]
    push eax
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

    ; input in al, output in al
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