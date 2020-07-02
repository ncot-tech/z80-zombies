    OUTPUT printchar.z80
    
    ORG $8000
    LD  A,  $21
    LD  C,  2
    CALL $30
    RET