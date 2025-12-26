AdventureLine1: db "You wake up, you look at the clock it shows 10:00. [leave bed, sleep]"

Adventure:
    call ClearScreen
    mov dh, 00h
    mov dl, 00h
    call setLine

    mov bx, AdventureLine1
    call PrintString

    call GetKeyboardInput

    ret