[bits 16]
[org 0x7c00]

jmp start

StartupString: db "Type help for commands", 0
CommandEnterString: db "$ ", 0
CurrentRow: db 1
InputCommand: db 16, "", 0

mem_buf times 6 db 0

MemoryText db " kb", 0

CommandsListString db "help, clear, ram", 0

HelpCommand: db "help", 0
ClearCommand: db "clear", 0
MemoryCommand: db "ram", 0

%include "Functions.asm"
%include "DiskRead.asm"

start:

    cli
    push cs
    pop ds
    xor ax, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7B00
    sti

    call ClearScreen ; Calls ClearScreen from Functions
    mov dh, 00h
    mov dl, 00h ; all the way to the left
    call setLine

    mov bx, StartupString
    call PrintString

    mov dh, 01h
    mov dl, 00h ; all the way to the left
    call setLine

    jmp CommandLoop

    clearCommandExe:
        call ClearScreen
        mov dh, 0
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine  
        jmp AfterCommandDef

    memoryCommandExe:
        int 0x12
        call ax_to_string
        mov bx, mem_buf
        call PrintString
        mov bx, MemoryText
        call PrintString

        mov dh, [CurrentRow]
        inc dh
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine  
        jmp AfterCommandDef

    helpCommandExe:
        mov bx, CommandsListString
        call PrintString
        mov dh, [CurrentRow]
        inc dh
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine 
        jmp AfterCommandDef

    AfterCommandDef:

    CommandLoop:
    mov bx, CommandEnterString
    call PrintString
    call GetKeyboardInput
    mov [InputCommand], bx
    mov dh, [CurrentRow]
    inc dh
    mov [CurrentRow], dh
    call setLine

    mov si, bx 
    mov di, ClearCommand
    call CompareStrings
    cmp dx, 1
    je clearCommandExe

    mov si, bx 
    mov di, MemoryCommand
    call CompareStrings
    cmp dx, 1
    je memoryCommandExe

    mov si, bx
    mov di, HelpCommand
    call CompareStrings
    cmp dx, 1
    je helpCommandExe

    jmp CommandLoop

    exit69:

    ; jmp PROGRAM_SPACE ; jump to PROGRAM_SPACE = 0x7e00 -> ExtendedProgram

    jmp $

times 510-($-$$) db 0
dw 0xaa55 ; magic boot code