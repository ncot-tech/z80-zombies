; c changed
; de - address of text to print
print:
    push hl
    ld c,$06
    rst $30
    pop hl
    ret

; de - address of text to print
; bc - x,y position
printat:
    push ix
    push de ; for later
    push bc ; so we don't lose it

    ; x pos first, stored in b
    ld ix,cursoransi+5  ; column (x) comes second
    ld c,b
    call itoa

    ; y pos now
    pop bc
    ld ix,cursoransi+2  ; row (y)
    call itoa
    
    ; print ansi escape sequence
    ld de,cursoransi
    call print

    ; print text
    pop de
    call print
    pop ix
    ret

cls:
    ld de,clsansi
    ld c,$06
    rst $30
    ret

; ###############################################################
; Clear a character
clearchar:
    push de
    ld de,clearChar
    call printat
    pop de
    ret

clearChar:
    dz $1B,"[1;5;37;42m", " "
clsansi:
    db $1B,"[30;40m"
    dz $1B,"[2J",$1B,"[0;0f"
cursoransi:
    dz $1B,"[00;00f"