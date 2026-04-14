    .ORG $0100

    ;load A into r1
    LI r4, $B010
    LW R1, R4, $0

    ;load B into r2
    LI r4, $B012
    LW r2, r4, $0

    ;r3 = product = 0
    LI r3, $0000

    ;save og B sign
    MV r5, r2
    ;r5 = 8000 if neg else 0
    ANDI r5, r5, $8000

    ;take abs val of B if negative
    BRZ CHECK
    ;if r5 == 0 skip
    NOT r2, r2
    ADDI r2, r2, $1

CHECK:
    ;loop counter = 8
    LI r6, $0008

LOOP:
    ;check LSB of r2
    ANDI r7, r2, $0001
    BRZ SKIP_ADD

    ADD r3, r3, r1

SKIP_ADD:
    ;shift A left
    ADD r1, r1, r1

    ;shift B right
    SR r2, r2

    ;decrement counter
    ADDI r6, r6, $FFFF
    BRZ DONE

    BRA LOOP

DONE:
    ;if original B neg -> neg res
    BRZ STORE;
    NOT r3, r3
    ADDI r3, r3, $1

STORE:
    ;store result to mem
    LI r4, $B000
    SW r3, r4, $0

    STOP

;data

    .ORG $B010
A:  .DW  $0003
B:  .DW  $0004


