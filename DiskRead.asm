[bits 16]
[org 0x7c00]
PROGRAM_SPACE equ 0x7e00 ; macro PROGRAM_SPACE to 0x7e00


BOOT_DISK:
    db 0

SectorsToRead:
    db 3 ; how many sectors to read 1 = [512 bytes]

DiskReadErrorString:
    db "OS failed to load, go cry to your mama :<", 0 ; what to say if it fails

; -----------------------------------------------------------------------------------------

ReadDisk:
    mov ah, 02h ; BIOS func for reading disk 
    mov bx, PROGRAM_SPACE ; sets the stack into the program space / space it may use
    mov al, [SectorsToRead] ; selects how many sectors we want to read
    mov dl, [BOOT_DISK] ; sets what disk to read from
    mov ch, 0x00 ; Hard drive cylinder = 0
    mov dh, 0x00 ; Hard drive head = 0
    mov cl, 0x02 ; starts to read sector 2 / the first sector after the boot sector
    int 0x13 ; tries to read from CHS address 002 or cylinder 0 head 0 sector 2
    jc DiskReadFailed ; jump if condition flag is set ; if it fails for some reason, jump to DiskReadFailed
    ret

DiskReadFailed:
    mov al, ah
    call print_hex
    mov bx, DiskReadErrorString ; bx / what to print is set to the Error
    ;call PrintString ; calls PrintString with bx set to the error / what to print to the error
    jmp $

print_hex:
    push ax
    shr al, 4
    call print_hex_digit
    pop ax
    and al, 0x0F
    call print_hex_digit
    ret

print_hex_digit:
    cmp al, 9
    jle .digit
    add al, 7
.digit:
    add al, '0'
    mov ah, 0x0e
    int 0x10
    ret

    jmp $