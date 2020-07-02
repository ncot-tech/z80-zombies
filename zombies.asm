    OUTPUT zombies.z80
    ORG $8000

main:
    ;init
    ld a,0
    ld (gameOver),a
    ld (playerCollidedS),a
    ld (playerCollidedZ),a
    ld (playerCollidedQ),a
    ld a,4
    ld (zombieCount),a

    ; Clear and set up screen
    call cls
    call showTitles ; show titles
    call cls
; Draw game screen
    call drawscreen
; Generate 4 zombies
    call genzombs
    call printzombs
; Generate 8 quicksand
    call genqs
    call printqs
; Generate player start pos
    call genplayer
    call printplayer
    
loop:
    call getjoystick
    ;call delay

    call swampCheck
    call playertouchzombie

    call playertouchqs
    
    call printplayer
    call movezombies

    call printzombs
    ;call debugprint

    ; update player pos
    ld hl,(playerNew)
    ld (playerCur),hl

    ; is game over?
    ld a,(gameOver)
    cp 1
    jp nz,loop
gameLost:
    call tidyup
; wait until the user lets go of the stick/buttons
wait_stickup_over:
    in a,($1)
    cp 0
    jp nz, wait_stickup_over
wait_input_over:
    in a,($1)
    and $10           ; should have 16 in a
    cp $10            ; do we have 16 in a?
    jp nz,wait_input_over
    jp main

; ###############################################################

; ###############################################################
; Draw the game screen
drawscreen:
    module drawscreen
    ld de,screentop
    call print

    ld b, 17                
loop:
    push af
    push bc
    ld de,screenmid
    call print
    pop bc
    pop af
    ;;
    djnz loop

    ld de,screentop
    call print
    ret
    endmodule



; ###############################################################
; Generate and draw initial quicksand positions
; hl,b and a will be modified
genqs:
    module genqs
    ld b, 16
    ld hl, quicksand
loop:   
    call random
    and %00001111
    add 3
    
    ld (hl), a  ; pos now in array
    inc hl
    ;;
    djnz loop
    ret
    endmodule

; ###############################################################
; Print Quicksand positions
printqs:
    module printqs
    ld b, 8
    ld hl, quicksand
loop:   
    
    push bc
    ; print quicksand on screen
    ; de - address of text to print
    ; bc - x,y position
    
    ld bc,(hl)
    inc hl
    inc hl
    ld de,quicksandChar
    call printat
    
    ;;
    pop bc
    djnz loop
    ret
    endmodule

; ###############################################################
; Generate player positions
genplayer:
    module genplayer

    ;ld a,r  ; get a "random" number 0-127 for x/y pos
    call random
    and %00001111
    add 3
    
    ld hl, (playerCur)
    ld h, a  ; x pos

    call random
    and %00001111
    add 3

    ld l, a  ; y pos
    ld (playerCur), hl
    ld (playerNew),hl

    ret
    endmodule

; ###############################################################
; Print player character
printplayer:
    module printplayer
 
    ld bc, (playerCur)              ; address of co-ords
    call clearchar

    ld bc, (playerNew)              ; address of co-ords
    ld de,playerChar
    call printat

    ret
    endmodule

; ###############################################################
; Get joystick input, blocks until stick is pressed and released
; Takes 'playerCur', modifies based on input, returns 'playerNew'
getjoystick:
    module getjoystick:

invalid:
    in a,($1)
    cp 0
    jp nz,valid  ; if pressed, go to valid
    ld a,0
    ld (stickPressed),a ; else reset stickPressed (they let go)
    jp invalid          ; loop

valid:
    ld b,a      ; store it
    ld a,(stickPressed)
    cp 0
    jp nz,invalid           ; if stick down, go back to read it again
    ld a,1
    ld (stickPressed),a     ; else set flag and continue

    ld hl,(playerCur)   ; L = Y position, H = X Position
                        ; Stored LH in RAM though
up:
    ld a,b           ; restore a
    and $1           ; should have 1 in a
    cp $1            ; do we have 1 in a?
    jp nz,down       ; no, go to next one
    ld a,l
    sub 1
    ld l,a
down:
    ld a,b           ; restore a
    and $2           ; should have 2 in a
    cp $2            ; do we have 2 in a?
    jp nz,left       ; no, go to next one
    ld a,l
    inc a
    ld l,a
left:
    ld a,b           ; restore a
    and $4           ; should have 4 in a
    cp $4            ; do we have 4 in a?
    jp nz,right       ; no, go to next one
    ld a,h
    sub 1
    ld h,a
right:
    ld a,b           ; restore a
    and $8           ; should have 8 in a
    cp $8            ; do we have 8 in a?
    jp nz,fire       ; no, go to next one
    ld a,h
    inc a
    ld h,a
fire:
    ld a,b           ; restore a
    and $10           ; should have 16 in a
    cp $10            ; do we have 16 in a?
    ; do nothing

    ld (playerNew),hl
    ret
    endmodule

; ###############################################################
; Tests whether player is in the swamp
swampCheck:
    module swampCheck:

    ld bc,(playerNew)   ; B = X, C = Y
    ; X check 2 - 19
    ld a,b
    cp 2
    jp z, dead
    cp 19
    jp z, dead
    ; Y check 1 - 19
    ld a,c
    cp 1
    jp z, dead
    cp 19
    jp z, dead

    ret
dead:
    ld a,1
    ld (playerCollidedS),a
    ld (gameOver),a
    ret
    endmodule

tidyup:
    ld a,(zombieCount)
    cp 0
    jp z,gameWon
    ld a,(playerCollidedS)
    cp 1
    jp z,inSwamp
    ld a,(playerCollidedQ)
    cp 1
    jp z,inQs
    ld a,(playerCollidedZ)
    cp 1
    jp z,eaten

gameWon:
    ld de,wonTxt
    ld b,1
    ld c,21
    call printat
    jp gameover:
inQs:
    ld de,quicksandTxt
    ld b,1
    ld c,21
    call printat
    jp gameover:
inSwamp:
    ld de,swampTxt
    ld b,1
    ld c,21
    call printat
    jp gameover:
eaten:
    ld de,eatenTxt
    ld b,1
    ld c,21
    call printat
    jp gameover:

gameover:
    ld de,gameoverTxt
    ld b,1
    ld c,22
    call printat
    ret

; ###############################################################
; Tests whether the player has touched a zombie
; sets a to 1 if they have
playertouchzombie:
    module playerzombie:

    ld hl, zombies                
    ld b, 4                         ;; i = 0
loop:
    push bc
    ; check if it overlaps
    ; if it does, a will be 1 jump to loop_exit
    ; if it doesn't, loop
    ld de,(hl)                      ; de = current zombie's pos
    ld bc,(playerNew)               ; Where player wants to be
    call comparepoints
    ;;
    pop bc  ; pop first, otherwise ret will fail
    cp 1
    jp z, loop_exit
    inc hl             ;; move pointer on 3
    inc hl
    inc hl
    djnz loop
loop_exit:
    ld (playerCollidedZ),a
    cp 1            ; if collided, set gameover flag, else leave it alone
    jp nz,exit
    ld (gameOver),a
exit:
    ret
    endmodule

; ###############################################################
; Tests whether the player has touched quicksand
; sets a to 1 if they have
playertouchqs:
    module playertouchqs:

    ld hl, quicksand                
    ld b, 8                        
loop:
    push bc
    ; check if it overlaps
    ; if it does, a will be 1 jump to loop_exit
    ; if it doesn't, loop
    ld de,(hl)                      ; de = current qs's pos
    ld bc,(playerNew)               ; Where player wants to be
    call comparepoints
    ;;
    pop bc  ; pop first, otherwise ret will fail
    cp 1
    jp z, loop_exit
    inc hl             ;; move pointer on 2
    inc hl
    djnz loop
loop_exit:
    ld (playerCollidedQ),a
    cp 1            ; if collided, set gameover flag, else leave it alone
    jp nz,exit
    ld (gameOver),a
exit:
    ret
    endmodule

    include titles.asm
    include utils.asm
    include ansi.asm
    include debugprint.asm
    include zombieai.asm

gameOver:
    db 0
playerCollidedZ:
    db 0
playerCollidedQ:
    db 0
playerCollidedS:
    db 0
stickPressed:
    db 0


quicksand:
    db 1,1, 1,2, 1,3, 1,4, 1,5, 1,6, 1,7, 1,8

playerCur:
    db 0,0
playerNew:
    db 0,0

gameoverTxt:
    db $1B, "[1;31;40m", "- = G A M E - O V E R = -\r\n"
    dz $1B, "[1;33;40m", "Press Fire to continue!"
wonTxt:
    db $1B, "[1;30;42m", "You  ESCAPED!\r\n"
    dz $1B,"[0m"
quicksandTxt:
    db $1B, "[1;30;43m", "You drowned in quicksand!\r\n"
    dz $1B,"[0m"
swampTxt:
    db $1B, "[1;30;44m", "You fell in the swamp!\r\n"
    dz $1B,"[0m"
eatenTxt:
    db $1B, "[1;30;41m", "You were eaten by a zombie!\r\n"
    dz $1B,"[0m"
screentop:
    dz $1B,"[2;44;32m", " ################## \r\n"
screenmid:
    dz $1B,"[2;44;32m", " #", $1B,"[2;42;32m","                ",$1B,"[2;44;32m", "# \r\n"
zombieChar:
    dz $1B,"[2;35;42m", "Z"
quicksandChar:
    dz $1B,"[2;33;44m", "%"
playerChar:
    dz $1B,"[1;5;37;42m", "@"
