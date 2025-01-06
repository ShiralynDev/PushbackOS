[bits 16]
[org 0x7c00]

jmp start

TestingString: db "Test complete", 0
CurrentRow: db 0

%include "Functions.asm"
%include "DiskRead.asm"

mov [BOOT_DISK], dl

start:
    mov ah, 0x0e ; tele-type mode
    mov al, 'W' ; get ready to print W
    int 0x10 ; bios call

    mov bp, 0x7c00 ; selects what parts of the memory the program uses
    mov sp, bp ; Why we do this, idk

    call ClearScreen ; Calls ClearScreen from Functions
    call ReadDisk ; Calls ReadDisk function from the DiskRead.asm file

    mov bx, TestingString
    call PrintString

    mov dh, 00h
    call setLine

    loop:
        mov ah, 00h ; sets keyboard mode to get keystroke
        int 0x16 ; bios call to take input

        cmp al, 0x0D ; if al/input is 0D/enter
        je exit ; then jump to exit

        cmp al, 0x53
        je goDown
        cmp al, 0x73
        je goDown

        cmp al, 0x57
        je goUp
        cmp al, 0x77
        je goUp

    jmp loop

    goDown:
        mov dh, [CurrentRow]
        inc dh
        call setLine
        mov [CurrentRow], dh
    jmp loop

    goUp:
        mov dh, [CurrentRow]
        dec dh
        call setLine
        mov [CurrentRow], dh
    jmp loop

    exit:

    mov dh, [CurrentRow]
    call GetKeyboardInput
    mov dh, [CurrentRow]
    inc dh
    call setLine
    call PrintString

    ; jmp PROGRAM_SPACE ; jump to PROGRAM_SPACE = 0x7e00 -> ExtendedProgram

    jmp $

times 510-($-$$) db 0
dw 0xaa55 ; magic boot code