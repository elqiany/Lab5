;Performs multiplication on RISC240

    .ORG $0100

    ;load A into r1
    LI r4, $B010
    LW r1, r4, $0

    ;load B into R2
    LI r4, $B012
    LW r2, r4, $0

    ;r3 = product = 0
    LI r3, $0000

    ;save og B sign
    MV r5, r2
    ;r5 = 8000 if neg else 0
    LI r6, $8000
    AND r5, r5, r6

    ;take abs val of B if negative
    BRZ CHECK
    ;if r5 == 0 skip
    NOT r2, r2
    ADDI r2, r2, $1

CHECK
    ;loop counter = 8
    LI r6, $0008

LOOP
    ;check LSB of r2
    LI r7, $0001
    AND r7, r2, r7
    BRZ SKIP_ADD

    ADD r3, r3, r1

SKIP_ADD

    ;shift B right
    SRLI r2, r2, $0001

    ;shift A left
    SLLI r1, r1, $0001

    ;decrement counter
    ADDI r6, r6, $FFFF
    BRZ DONE

    BRA LOOP

DONE
    ;if original B neg -> neg res
    OR r5, r5, r0
    BRZ STORE;
    NOT r3, r3
    ADDI r3, r3, $0001

STORE
    ;store result to mem
    LI r4, $B000
    SW r4, r3, $0000

    STOP

;data

    .ORG $B010
A   .DW  $007F
B   .DW  $FF80


