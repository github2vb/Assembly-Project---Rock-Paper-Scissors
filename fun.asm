IDEAL
MODEL small
STACK 100h
DATASEG
Score	db	0
winner db 0
PlayerChoice db 1b
ComputerChoice db 23 dup (?)
ComputerChoice2 db 23 dup (?)
PlayerChoice2 db 23 dup (?)
ComputerScore db (?)
PlayerScore db (?)	
msgYes db "You won!- $"
msgNo db "You lost- $"
win_melody dw 2711, 2415, 2031, 2711, 1612, 1,1, 1612, 1,1, 1809, 1,1,1,1, 2711, 2415, 2031, 2711, 1809, 1,1, 1809, 1,1, 2031, 1, 2152, 2415, 1,1, 2711, 2415, 2031, 2711, 2031, 1,1,1, 1809, 1, 2152, 1,1,1, 2711, 1,1, 2711, 1,1, 1809, 1,1, 2031, 0
lose_melody dw 9663, 9121, 8126, 1, 12175, 1, 10847, 1, 13666, 1, 14478, 0
win_screen_text db "You won!", 10,10, "You managed to win", 10,10,10, "- Press a key to exit -$"
lose_screen_text db " You lost! ", 10,10, "the computer won!", 10,10,10, "- Press a key to exit -$"
WhatToPlay2 db  "What would you like to play (rock, paper or scissors: (type r for rock, p for paper, and s for scissors) ",10, 10,10,"abc- $"
WantToPlay2 db  "Would you like to play rock paper scissors? (type y for yes, n for no)",10,10,10,"abc - $"
Welcome db "Welcome to rock paper scissors!",10, "$",10
rock3 db 23 dup (10, "rock",10,10, "$")
paper3 db 23 dup (10,"paper",10,10, "$")
shoot db 23 dup (10,"shoot!",10,10, "$")
scissors3 db 23 dup (10,"scissors",10,10, "$",10,10,10)
vs db "vs-$"
CODESEG
;next: 5
;exit: 3
;rock,paper, sciisors: 2
;left to do: hands in graphic mode, NewMainGame needs to clean graphics for last game
proc print
	mov ah, 09h
	mov dx, bx
	int 21h
	ret
endp
proc wait_tenth
    push ax
    push cx
    push dx
    
    mov ah, 86h
    mov cx, 0001h
    mov dx, 86A0h
    int 15h

    pop dx
    pop cx
    pop ax
    ret
endp
proc lose_screen
    
    mov ah, 09h
    mov dx, offset lose_screen_text
    int 21h

    mov ax, offset lose_melody
    call play_melody

    mov ah, 00h
    int 16h

    call wait_tenth

    ret
endp
proc play_beep ; divisor
    push bp
    mov bp, sp
    push ax

    in al, 61h ; Open speaker
    or al, 00000011b
    out 61h, al
    
    mov al, 0B6h ; Send control word to change frequency
    out 43h, al

    mov ax, [bp+4] ; Play divisor
    out 42h, al ; Sending lower byte
    mov al, ah
    out 42h, al ; Sending upper byte

    pop bp
    pop ax
    ret 2
endp
proc stop_beep
    push ax

    in al, 61h
    and al, 11111100b
    out 61h, al

    pop ax
    ret
endp
proc play_melody ; ax = notes array offset, divisor[2]
    push ax
    push si

    mov si, ax
    play_melody_loop:
        mov ax, [si]
        cmp ax, 0
        je play_melody_end

        cmp ax, 1
        je play_melody_continue

        push ax
        call play_beep


        play_melody_continue:
			call wait_tenth
			call stop_beep
			add si, 2
        jmp play_melody_loop
    
    play_melody_end:
    call stop_beep
    pop si
    pop ax
    ret
endp

proc win_screen

    mov ah, 09h
    mov dx, offset win_screen_text
    int 21h
    mov ax, offset win_melody
    call play_melody
    mov ah, 00h
    int 16h

    call wait_tenth

    ret
endp
proc starting_screen
	mov ah, 09h
	mov dx, bx
	int 21h
	mov ah, 00h 
	int 16h
	ret
endp
proc graphic_mode
    push ax

    mov ah, 00h
    mov al, 13h
    int 10h
    
    pop ax
    ret
endp

proc gameOn
	mov bx, offset rock3
	call starting_screen
	mov bx, offset paper3
	call starting_screen
	mov bx, offset scissors3
	call starting_screen
	mov bx, offset shoot
	call starting_screen
	ret
endp
proc WantToPlay 
	mov bx, offset WantToPlay2
	call starting_screen
	cmp al, 6Eh
	je exit2
	cmp al, 6Eh
	jne next4
	exit2:
		mov ax, 4c00h
		int 21h
	next4:
		ret
endp
proc WhatToPlay
	mov bx, offset WhatToPlay2
	call starting_screen
	cmp al, 72h
	je rock2
	cmp al, 73h
	je scissors2
	cmp al, 70h
	je paper2
	rock2:
		mov [PlayerChoice], 00000000b
		mov bl, [rock3]
		mov [PlayerChoice2], bl
		jmp next3
	paper2:
		mov [PlayerChoice], 00000001b
		mov bl,[paper3]
		mov [PlayerChoice2], bl
		jmp next3
	scissors2:
		mov [PlayerChoice], 00000010b
		mov bl, [scissors3]
		mov [PlayerChoice2], bl
		jmp next3
	next3:	
		ret
endp
proc PlayerInput
mov dx, offset PlayerChoice
	mov bx, dx
	mov [byte ptr bx], 21
	mov ah, 0Ah
	int 21h
	ret
endp
proc NewGameMini
	mov al, [PlayerChoice]
	mov ah, [ComputerChoice]
	mov bl, [score]
	xor al,al
	xor ah, ah
	xor bl, bl
	ret
endp
proc NewMainGame
	mov bx, offset Welcome
	call starting_screen
	xor cl, cl
	xor ch, ch
	xor al, al
	mov ah, [winner] 
	xor ah, ah
	call NewGameMini
	ret
endp
proc printNo
	mov bx, offset msgYes
	call starting_screen
	ret
endp
proc printYes
	mov bx, offset msgYes
	call starting_screen
	ret
endp
proc UpdateScore
	mov al, [winner]
	cmp al, 0b
	je next
	inc ch
	cmp cl, 00000011b
	je GameDoneComputerWon
	cmp ch, 00000011b
	je GameDonePlayerWon
	next:
		inc cl
		ret
	GameDoneComputerWon:
		call lose_screen
		jmp Game
	GameDonePlayerWon:
		call win_screen
		jmp Game
	ret
endp
proc NewMiniGame
	inc bl
	
	ret
endp
proc RandomPlay
	mov ah, 2Ch
	int 21h
	mov al, dl
	cmp al, 00010000b
	jg bigger
	mov al, dl
	cmp al, 00010000b
	jl 	 smaller
	jmp the_same
	bigger:
		mov al, 'p'
		mov [ComputerChoice], 00000001b
		mov bl, [paper3]
		mov [ComputerChoice2], bl
		jmp next2
	smaller:
		mov al,'r'
		mov [ComputerChoice], 00000000b
		mov bl, [rock3]
		mov [ComputerChoice2], bl
		jmp next2
	the_same:
		mov al, 's'
		mov [ComputerChoice], 00000010b
		mov bl, [scissors3]
		mov [ComputerChoice2], bl
		jmp next2
	next2:
		ret
endp
proc PlayerWin
	mov al, [PlayerChoice]
	mov ah, [ComputerChoice]
	mov bl, al
	mov bh, ah
	cmp bl, bh
	je anotherOne
	cmp al, ah
	jg Big
	jmp smal
	Big:
		sub al, ah
		cmp al ,00000001b
		je yes
		cmp al, 00000010b
		je no
	yes:
		mov [Winner],1
		call UpdateScore
		call printYes
		jmp anotherOne

	no:
		mov al, 0
		call UpdateScore
		call printNo
		jmp anotherOne
	smal:
		sub al, ah
		cmp al ,00000001b
		je yes
		cmp al, 00000010b
		je no
	yes2:
		mov [Winner] ,1 
		call UpdateScore
		mov bx, offset msgYes
		call starting_screen
		jmp anotherOne
		
	no2:
		mov al, 0
		call UpdateScore
		mov bx, offset msgNo
		call starting_screen
		jmp anotherOne
		
	anotherOne:
		call NewMiniGame
	ret
endp
proc paint_pixel ; x, y, color
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov ah, 0Ch
    mov bh, 0
    mov cx, [bp+4]
    mov dx, [bp+6]
    mov al, [bp+8]
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 6
endp

proc draw_rect ; x, y, width, height, color
    push bp
    mov bp, sp
    push ax
    push bx
    push cx
    push dx

    mov ax, [bp+4] ;x
    mov bx, [bp+6] ;y
    mov dl, [bp+8] ;width
    mov dh, [bp+10] ;height
    
    xor cx, cx
    rect_row:
        mov ax, [bp+4]
        mov cl, 0
        rect_pixel:
            push [bp+12]
            push bx
            push ax
            call paint_pixel
            inc ax
            inc cl
            cmp cl, dl
            jle rect_pixel
        inc bx
        inc ch
        cmp ch, dh
        jle rect_row

    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 10
endp
proc vs2 
	xor bx, bx
	mov bx, offset ComputerChoice2
	call starting_screen
	mov bx, offset vs
	call starting_screen
	mov bx, offset PlayerChoice2
	call starting_screen
	ret
endp
proc mini_game
	call NewGameMini
	call WhatToPlay
	call gameOn
	call RandomPlay
	call PlayerWin
	ret
endp

CODESEG
start:
	mov ax, @data
	mov ds, ax
mov cl, [ComputerScore]
mov ch, [PlayerScore]
call graphic_mode
call NewMainGame
Game:
	call WantToPlay
	MiniGame:
	call mini_game
		call vs2
		call UpdateScore
		loop MiniGame
	loop Game
exit:
	mov ax, 4c00h
	int 21h
END start