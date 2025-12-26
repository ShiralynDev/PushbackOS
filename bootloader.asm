[bits 16]
[org 0x7c00]
PROGRAM_SPACE equ 0x7e00

jmp start

%include "DiskRead.asm"

start:

    mov [BOOT_DISK], dl

    cli
    push cs
    pop ds
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti

    call ReadDisk

    jmp PROGRAM_SPACE ; jump to PROGRAM_SPACE = 0x7e00 -> ExtendedProgram

    times 510-($-$$) db 0
    dw 0xaa55 ; magic boot code