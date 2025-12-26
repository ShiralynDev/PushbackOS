[bits 16]

    InputChar: times 50 db 0
    CurrentPosition: db 0
    mem_buf times 6 db 0
    CurrentRow: db 1

    NoSuchDriveString: db "No such drive", 0
    HardDiskString: db "Hard disk", 0
    FloppyChangeString: db "Floppy disk type 1", 0
    FloppyNoChangeString: db "Floppy disk type 2", 0
    UnknownDiskString: db "Unknown disk type", 0


    PrintString: ; dx = maxLineSize
        pusha ; puts stuff that we will use into the stack so we don't ruin our main file
        mov ah, 0Eh ; selects tele-type mode
    Loop: 
        cmp [bx], byte 0 ;  checks if bx aka the string is at EOS / ions  zero
        je Exit
        mov al, [bx] ; moves current char of bx / the string to al / char to type
        int 0x10 ; bios call to print
        inc bx ; goes to next char in string 
        jmp Loop ; jumps back to check if the next char is a EOS
    Exit:
        popa
        ret

    ClearScreen:
        pusha
        mov ah, 07h    ; set mode 
        mov bh, 0x07   ;00010111b ;0x07   ; set mode: white on black
        mov al, 00h
        mov cx, 0x000  ; row 0, column 0
        mov dx, 0x184f ; row 24 (0x18), col 79 (0x4f)
        int 0x10       ; call BIOS video interupt
        popa
    ret

    setLine: ; set dh to 00h for first line, ect...
        pusha
        mov ah, 02h
        mov bh, 0x0
        int 0x10
        popa
    ret

    GetKeyboardInput: ; keyboard input gets stored in bx
        pusha
        mov bx, 0
        mov [CurrentPosition], dx
    Loop1:
        cmp bx, 49
        je Exit1

        mov ah, 00h ; sets keyboard mode to get keystroke
        int 0x16 ; bios call to take input

        cmp al, 0x0D ; if al/input is 0D/enter
        je Exit1 ; then jump to exit
        cmp al, 0x08 ; if al/input is 1C/backspace
        je Exit2 ; then jump to exit
        mov [InputChar + bx], al ; moves the inputed char to InputChar
        inc bx ; increses bx / goes to the next char in the string
        inc dx
        mov [CurrentPosition], dx
        mov ah, 0x0e ; selects tele-type mode
        int 0x10 ; does the interupt and prints the input
        jmp Loop1 ; loops
    Exit2:
        cmp bx, 0
        je Loop1
        dec bx
        dec dx
        mov [CurrentPosition], dx
        mov byte [InputChar + bx], ' '

        mov dh, [CurrentRow]
        mov dl, [CurrentPosition]
        call setLine

        mov al, ' '
        mov ah, 0x0e
        int 0x10

        mov dh, [CurrentRow]
        mov dl, [CurrentPosition]
        call setLine

        jmp Loop1
    Exit1:
        mov al, 0 ; moves zero into al for next line
        mov [InputChar + bx], al ; makes the last char of the string 0 to show that it's the end of the string

        popa
        mov bx, InputChar ; moves the complete string back into bx for the other code to use
        ret

    CompareStrings: ; si = string 1, di = string 2, dx = result
        push ax
        push si
        push di

        CompareStringLoop:
            mov al, [si]
            mov ah, [di]
            cmp al, ah
            jne CompareStringExitNotEqual

            test al, al
            jz CompareStringExitEqual

            inc si
            inc di
            jmp CompareStringLoop

        CompareStringExitNotEqual:
            mov dx, 0
            jmp CompareStringDone

        CompareStringExitEqual:
            mov dx, 1

        CompareStringDone:

        pop si
        pop di
        pop ax
        ret

    ax_to_string:
        pusha

        mov bx, ax
        lea si, [mem_buf+5]
        mov cx, 0

    convert_loop:
        xor dx, dx
        mov ax, bx
        mov bx, 10
        div bx
        add dl, '0'
        dec si
        mov [si], dl
        mov bx, ax
        inc cx
        cmp ax, 0
        jne convert_loop
        lea di, [mem_buf]
    shift_loop:
        lodsb
        stosb
        loop shift_loop
        mov byte [di], 0
        popa
        ret

    GetDiskInfo: ; dl = disk number, returns: bx = disk type
        mov ah, 15h
        int 0x13

        cmp ah, 0x00
        je NoSuchDrive
        cmp ah, 0x03
        je HardDisk
        cmp ah, 0x02
        je FloppyWithChange
        cmp ah, 0x01
        je FloppyNoChange

    HardDisk:
        mov bx, HardDiskString
        jmp DiskInfoDone

    FloppyWithChange:
        mov bx, FloppyChangeString
        jmp DiskInfoDone

    FloppyNoChange:
        mov bx, FloppyNoChangeString
        jmp DiskInfoDone

    NoSuchDrive:
        mov bx, NoSuchDriveString

    DiskInfoDone:
        ret

;CompareInput:
;ret