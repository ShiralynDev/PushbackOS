[bits 16]
[org 0x7c00]

jmp start

TestingString: db "Test complete", 0
CurrentRow: db 0

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

    mov [BOOT_DISK], dl

    mov ah, 0x0e ; tele-type mode
    mov al, 'W' ; get ready to print W
    int 0x10 ; bios call

    call ClearScreen ; Calls ClearScreen from Functions
    mov dh, 00h
    mov dl, 00h ; all the way to the left
    call setLine

    call ReadDisk ; Calls ReadDisk function from the DiskRead.asm file

    mov bx, TestingString
    call PrintString

    mov dh, 01h
    mov dl, 00h ; all the way to the left
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
        cmp dh, 25
        je loop
        inc dh
        call setLine
        mov [CurrentRow], dh
    jmp loop

    goUp:
        mov dh, [CurrentRow]
        cmp dh, 1
        je loop
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