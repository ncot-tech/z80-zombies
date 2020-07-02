; ###############################################################
; Generate initial zombie positions
genzombs:
    module genzombs
    ld b, 4
    ld hl, zombies
loop:   
    call random
    and %00001111
    add 3
    ld (hl), a  ; y pos now in array
    inc hl

    call random
    and %00001111
    add 3

    ld (hl), a  ; x pos now in array
    inc hl
    ld (hl), 1  ; zombie is alive
    inc hl

    ;;
    djnz loop
    ret
    endmodule

; ###############################################################
; Print zombie positions
printzombs:
    module printzombs
    ld b, 4
    ld hl, zombies
loop:   
    
    push bc
    ; print zombies on screen
    ; de - address of text to print
    ; bc - x,y position
    
    ld bc,(hl)
    inc hl
    inc hl
    ld a,(hl)
    cp 0
    jp z, endloop   ; dead zombie
    
    ld de,zombieChar
    call printat
    
endloop:
    ;;
    inc hl
    pop bc
    djnz loop
    ret
    endmodule
    
; ###############################################################
; Moves zombies towards player
movezombies:
    module movezombies:

    ld a,(zombieCount)
    cp 0            ; are all zombies dead?
    jp nz, loop_init
    ld a,1
    ld (gameOver),a
    ret

loop_init:
    ld b, 4
    ld ix, zombies
loop:
    ; if zombie dead, skip it
    push bc
    ld de,(ix)  ; zombie xy pos
    ld a,(ix+2)   ; zombie dead flag
    cp 0
    jp z, endloop    ; dead zombie, ignore

    ; now calculate new zombie pos
    ; cp flags
    ; Z - a==d, NZ - a != d
    ; C - a<d
    ; NC - a >d
    ld bc, (playerNew)  ; player position
    ld a,b  ; x pos player
    cp d    ; x pos zombie
    jp z,xsame      ; player/zombie on same x
    jp c,xbehind    ; player behind zombie on x
    jp nc,xfront    ; player in front of zombie on x
    
xsame:
    jp checky
xbehind:
    ; subtract zombie's x pos
    dec d
    jp checky
xfront:
    inc d
    ; fall through to checky

checky:
    ld a,c  ; y pos player
    cp e    ; y pos zombie
    jp z,ysame
    jp c,ybehind
    jp nc,yfront
    
ysame:
    ; if Z still set, we've hit player
    ; otherwise, go update the pos
    jp updatecoords
ybehind:
    dec e
    jp updatecoords
yfront:
    inc e

updatecoords:

    ; clearing zombie's path doesn't work...
    ; clear current pos
    ld bc,(ix)
    call clearchar
    ; put new co-ords back
    ld (ix),de

    ; check zombie collide with quicksand
    ld hl, quicksand
    ld b, 8
qs_loop:
    push bc

    ld bc,(hl)  ; current qs
    ; de zombie pos
    call comparepoints
    pop bc
    cp 1
    jp z, dead_zomb

    inc hl: inc hl
    djnz qs_loop
    
    ; check zombie collide with player
    ld bc,(playerNew)
    call comparepoints
    cp 1
    jp nz,endloop

    ; touching player
    ld (playerCollidedZ),a
    ld (gameOver),a
    jp endloop

dead_zomb:
    ld (ix+2), 0    ; dead zombie
    ld a,(zombieCount)
    dec a
    ld (zombieCount),a

endloop:
    inc ix: inc ix: inc ix  ; move to next zombie
    pop bc
    ; djnz the long way
    dec b
    ld a,0
    cp b
    jp nz,loop
 
    ret
    endmodule

zombies:    ;x,y,deadflag
    db 0,0,0, 0,0,0, 0,0,0, 0,0,0
zombieCount:
    db 4