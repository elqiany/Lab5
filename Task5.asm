; Running RISC240 + Multiplication Coprocessor on the FPGA

    .ORG $0000
    BRA  START  ; branch to the start of the program

    .ORG $0100
START

    ;load A into r1
    LI r4, A
    LW r1, r4, $0

    ;load B into R2
    LI r4, B
    LW r2, r4, $0

    ;utilize multiplication coprocessor
    ;MUL r3, r1, r2 
    ;16'0110000_011_001_010 -> opcode_selRD_selRS1_selRS2
    .DW $60CA 

    ;write result to MMIO
    LI r4, RES
    SW r4, r3, $0000

    ;MULI instructions

    ;MULI r4, r1, $0005
    ;16'0110011_100_001_000
    .DW $6708
    .DW $0005    ; provide immediate

    ;MULI r2, r2, $FFFC
    ;16'0110011_010_010_000
    .DW $6690
    .DW $FFFC    ; provide immediate

    STOP

; Memory-mapped I/O ports
RES .EQU $B000
A   .EQU $B010
B   .EQU $B012