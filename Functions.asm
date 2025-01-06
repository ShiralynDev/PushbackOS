[bits 16]
[org 0x7c00]

section .data
    InputChar: times 50 db 0
    CurrentPosition: db 0

section .text

    PrintString:
        pusha ; puts stuff that we will use into the stack so we don't ruin our main file
        mov ah, 0x0e ; selects tele-type mode
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

    GetKeyboardInput:
        pusha
        mov bx, 0
        mov dx, 0
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
        dec bx
        dec dx
        mov [CurrentPosition], dx
        mov dword [InputChar + bx], ' '

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

    WriteToDisk:
        pusha
        mov ah, 03h
        ; AL = Amount of sectors to write to
        ; CH = cylinder to write
        ; CL = What sector to start at
        ; DH = head number
        ; DL = driver number
        ; ES = what to write
        int 13
    ret

    GetSystemClock:
        mov ah, 02h ; read RTC (real time clock)
        int 1ah     ; bios call
        mov al, cl
        mov ah, 0x0e
        int 0x10
    ret

;CompareInput:
;ret