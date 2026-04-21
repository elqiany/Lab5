;Performs multiplication using multiplication coprocessor 
;incorporated into RISC240

    .ORG $0100

    ;load A into r1
    LI r4, $B010
    LW r1, r4, $0

    ;load B into R2
    LI r4, $B012
    LW r2, r4, $0

    ;utilize multiplication coprocessor
    ;must load proper value into the IR 
    ;MUL r3, r1, r2 
    ;16'0110000_011_001_010 -> opcode_selRD_selRS1_selRS2
MUL .DW $60CA 

    ;store result to mem
    LI r4, $B000
    SW r4, r3, $0000

    STOP

;data

    .ORG $B010
A   .DW  $000C
B   .DW  $0005