PROGRAM_SPACE equ 0x7e00 ; macro PROGRAM_SPACE to 0x7e00

section .data
    BOOT_DISK:
        db 0 ; boot disk zero aka first disk

    SectorsToRead:
        db 2 ; how many sectors to read

    DiskReadErrorString:
        db "Disk read failed :<", 0 ; what to say if it fails

section .text

    ReadDisk:
        mov ah, 0x02 ; BIOS func for reading disk 
        mov bx, PROGRAM_SPACE ; sets the stack into the program space / space it may use
        mov al, [SectorsToRead] ; selects how many sectors we want to read
        mov dl, [BOOT_DISK] ; sets what disk to read from
        mov ch, 0x00 ; sets ch/Hard drive cylinder to 0
        mov dh, 0x00 ; sets dh/Hard drive head to 0
        mov cl, 0x02 ; starts to read sector 2 / the first sector after the boot sector
        int 0x13 ; tries to read from CHS address 002 or cylinder 0 head 0 sector 2
        jc DiskReadFailed ; jump if condition is met ; if it fails for some reason, jump to DiskReadFailed
        ret

    DiskReadFailed:
        mov bx, DiskReadErrorString ; bx / what to print is set to the Error
        call PrintString ; calls PrintString with bx set to the error / what to print to the error
        ret

        jmp $
        