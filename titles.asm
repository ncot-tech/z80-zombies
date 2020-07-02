showTitles:
    ld de,titleTxt
    call print
; wait until the user lets go of the stick/buttons
wait_stickup:
    in a,($1)
    cp 0
    jp nz ,wait_stickup
; now accept input
wait_input:
    in a,($1)
    and $10           ; should have 16 in a
    cp $10            ; do we have 16 in a?
    jp nz,wait_input
    ret

titleTxt:
    db $1B, "[1;37;40m", "           - = Z o m b i e s ! = -\r\n\r\n"
    db $1B, "[2;37;40m", "         A turn based strategy game\r\n\r\n"
    db $1B, "[1;34;40m", "RC2014 version (c)2020 James Grimwood\r\n"
    db $1B, "[1;34;40m", "     https://ncot.uk - @ncot_tech\r\n\r\n"
    db $1B, "[1;33;40m", "Characters\r\n"
    db $1B, "[1;31;40m", "     @ - You!          Z - Zombie\r\n"
    db $1B, "[1;31;40m", "     # - Swamp         % - Quicksand\r\n\r\n"
    db $1B, "[1;33;40m", "Objective\r\n"
    db $1B, "[1;31;40m", "Survive by luring the zombies into the quicksand.\r\n"
    db $1B, "[1;31;40m", "Zombies will move in straight lines towards you.\r\n"
    db $1B, "[1;31;40m", "Zombies will eat you; do not fall into the quicksand or\r\n"
    db $1B, "[1;31;40m", "swamp otherwise you will drown!\r\n\r\n"
    db $1B, "[1;33;40m", "Controls\r\n"
    db $1B, "[1;34;40m", "Requires RC2014 Joystick input\r\n"
    db $1B, "[1;34;40m", "Up/Down/Left/Right to move.\r\n"
    db $1B, "[1;34;40m", "Fire to stand still.\r\n"
    db $1B, "[1;34;40m", "Zombies always take one step after your go.\r\n\r\n"
    dz $1B, "[1;33;40m", "Press Fire to play!"
