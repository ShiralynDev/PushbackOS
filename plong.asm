; pong but better

TopRow: db 0
BottomRow: db 25
PlayerOneX: db 0
PlayerTwoX: db 0
Paddle: db "xxxxx", 0
ballX: db 0
ballY: db 0

Plong:
    PlongLoop:

    mov al, 00h
    mov ah, 01h
    int 0x16
    jz afterInput

    mov ah, 00h
    int 0x16 
    cmp al, 'a'
    je movPlayerOneLeft
    cmp al, 'd'
    je movPlayerOneRight

    cmp al, 'j'
    je movPlayerTwoLeft
    cmp al, 'l'
    je movPlayerTwoRight

    afterInput:

    call ClearScreen

    mov dx, [PlayerOneX]
    mov dh, [TopRow]
    call setLine
    mov bx, Paddle
    call PrintString

    mov dx, [PlayerTwoX]
    mov dh, [BottomRow]
    call setLine
    mov bx, Paddle
    call PrintString

    jmp PlongLoop
    
    movPlayerOneLeft:
    mov bx, [PlayerOneX]
    cmp bx, 00h
    je afterInput
    dec bx
    mov [PlayerOneX], bx
    jmp afterInput

    movPlayerOneRight:
    mov bx, [PlayerOneX]
    inc bx
    mov [PlayerOneX], bx
    jmp afterInput

    movPlayerTwoLeft:
    mov bx, [PlayerTwoX]
    cmp bx, 00h
    dec bx
    mov [PlayerTwoX], bx
    jmp afterInput

    movPlayerTwoRight:
    mov bx, [PlayerTwoX]
    inc bx
    mov [PlayerTwoX], bx
    jmp afterInput

    ret