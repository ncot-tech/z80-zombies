; compares two x,y points to see if they overlap
; bc - point 1, de - point 2
; a - 1 if they overlap, else 0
comparepoints:
; x pos
    ld a,b  ; compare b-d
    cp d
    jp z, ypos
    jp nocollide
ypos:
    ld a,c  ; compare c-e
    cp e
    jp z, collide
    jp nocollide
collide:
    ld a,1
    ret

nocollide:
    ld a,0
    ret

; convert 8 bit integer into ascii
; put number into c
; put address of string position in ix
; a changed
itoa:
    push bc
    push de
    ld d,10
    call C_Div_D
    add a,$30
    ld (ix+1),a
    ld a,c
    add $30
    ld (ix),a
    pop de
    pop bc
    ret

;-----> Generate a random number
; output a=answer 0<=a<=255
; all registers are preserved except: af
random:
        push    hl
        push    de
        ld      hl,(randData)
        ld      a,r
        ld      d,a
        ld      e,(hl)
        add     hl,de
        add     a,l
        xor     h
        ld      (randData),hl
        pop     de
        pop     hl
        ret

randData:
    db 0,0

C_Div_D:
;Inputs:
;     C is the numerator (C/d)
;     D is the denominator (c/D)
;Outputs:
;     A is the remainder
;     B is 0
;     C is the result of C/D
;     D,E,H,L are not changed
;
    ld b,8
    xor a
    sla c
    rla
    cp d
    jr c,$+4
        inc c
        sub d
    djnz $-8
    ret

; Delays for bc * de times
delay:
    LD BC, 100h            ;Loads BC with hex 1000
Outer:
    LD DE, 100h            ;Loads DE with hex 1000
Inner:
    DEC DE                  ;Decrements DE
    LD A, D                 ;Copies D into A
    OR E                    ;Bitwise OR of E with A (now, A = D | E)
    JP NZ, Inner            ;Jumps back to Inner: label if A is not zero
    DEC BC                  ;Decrements BC
    LD A, B                 ;Copies B into A
    OR C                    ;Bitwise OR of C with A (now, A = B | C)
    JP NZ, Outer            ;Jumps back to Outer: label if A is not zero
    RET                     ;Return from call to this subroutine