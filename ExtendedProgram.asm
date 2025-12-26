[bits 16]
[org 0x7e00]

jmp ExtendedStart

%include "Functions.asm"
%include "plong.asm"
%include "adventure.asm"

StartupString: db "Type help for commands", 0
CommandEnterString: db "$ ", 0
InputCommand: db 16, "", 0

MemoryText db " kb", 0
EnterDiskText db "Please enter disk number: ", 0
WriteDiskText db "Please enter what you want to save to disk:", 0

CommandsListString db "help, clear, ram, disk, plong, adventure, writedisk, readdisk", 0

HelpCommand: db "help", 0
ClearCommand: db "clear", 0
MemoryCommand: db "ram", 0
DiskCommand: db "disk", 0
PlongCommand: db "plong", 0
AdventureCommand: db "adventure", 0
WriteDiskCommand: db "writedisk", 0
ReadDiskCommand: db "readdisk", 0

tempString:
    db "Yo yo from extended program loaded in to memory", 0

BOOT_DISK: db 0

; -----------------------------------------------------------------------------------------

ExtendedStart:
    mov [BOOT_DISK], dl

    mov bx, tempString
    call PrintString

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

    diskCommandExe:
        mov bx, EnterDiskText
        mov dx, 0x1a ; 26 in decimal
        call PrintString
        call GetKeyboardInput
        mov dl, [bx]
        sub dl, '0'
        call GetDiskInfo
        push bx

        mov dh, [CurrentRow]
        inc dh
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine 

        pop bx
        call PrintString

        mov dh, [CurrentRow]
        inc dh
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine 
        jmp AfterCommandDef

    plongCommandExe:
        call Plong
        jmp AfterCommandDef

    adventureCommandExe:
        call Adventure
        jmp AfterCommandDef

    WriteDiskCommandExe:
        mov bx, WriteDiskText
        call PrintString

        mov dh, [CurrentRow]
        inc dh
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine 

        call GetKeyboardInput

        mov ah, 03h
        mov al, 1
        mov ch, 0
        mov cl, 10
        mov dh, 0
        mov dl, 0
        int 0x13

        mov dh, [CurrentRow]
        inc dh
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine 

        jmp AfterCommandDef

    ReadDiskCommandExe:
        mov ah, 02h
        mov al, 1
        mov ch, 0
        mov cl, 10
        mov dh, 0
        mov dl, 0
        int 0x13

        mov dh, [CurrentRow]
        inc dh
        mov [CurrentRow], dh
        mov dl, 00h
        call setLine 

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
    mov dx, 02h
    call GetKeyboardInput
    mov dx, 00h
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

    mov si, bx
    mov di, DiskCommand
    call CompareStrings
    cmp dx, 1
    je diskCommandExe

    mov si, bx
    mov di, PlongCommand
    call CompareStrings
    cmp dx, 1
    je plongCommandExe

    mov si, bx
    mov di, AdventureCommand
    call CompareStrings
    cmp dx, 1
    je adventureCommandExe

    mov si, bx
    mov di, WriteDiskCommand
    call CompareStrings
    cmp dx, 1
    je WriteDiskCommandExe

    mov si, bx
    mov di, ReadDiskCommand
    call CompareStrings
    cmp dx, 1
    je ReadDiskCommandExe

    jmp CommandLoop

    exit69:

    jmp $

    times 1536-($-$$) db 0 