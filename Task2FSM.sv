`default_nettype none

//FSM for Task2 of Lab5
//Outputs signals like enables and clear
//but also outputs done and ZN flag
module Task2FSM(
    output logic prod_en,
    output logic prod_clr,
    output logic a_en,
    output logic a_ld,
    output logic b_en,
    output logic b_ld,
    output logic ct_en,
    output logic ct_clear,
    output logic ct_ld,
    output logic prod_sel,
    output logic a_sel,
    output logic b_sel,
    output logic done,
    output logic [1:0] ZN_flags,
    input logic start,
    input logic lsbB1,
    input logic N_flag,
    input logic Z_flag,
    input logic clock,
    input logic reset,
    input logic exit_loop);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        INIT = 3'b001,
        SHIFT = 3'b010,
        ADD = 3'b011,
        CHECK = 3'b100,
        FINISH  = 3'b101
    } state_t;

    state_t currState, nextState;

    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            currState <= IDLE;
        else
            currState <= nextState;
    end

    always_comb begin
        prod_en = 1'b0;
        prod_clr = 1'b0;
        a_en = 1'b0;
        a_ld = 1'b0;
        b_en = 1'b0;
        b_ld = 1'b0;
        ct_en = 1'b0;
        ct_clear = 1'b0;
        ct_ld = 1'b0;
        prod_sel = 1'b0;
        a_sel = 1'b0;
        b_sel = 1'b0;
        done = 1'b0;
        ZN_flags = 2'b00;
        nextState = currState;

        case(currState)
            IDLE: begin
                if (start) begin
                    nextState = INIT;
                    prod_en = 1'b1;
                    prod_sel = 1'b0;
                    a_en = 1'b1;
                    a_sel = 1'b0;
                    b_en = 1'b1;
                    b_sel = 1'b0;
                    ct_en = 1'b1;
                    ct_ld = 1'b1;
                end
            end

            INIT: begin
                if (lsbB1) begin
                    nextState = ADD;
                    prod_en = 1'b1;
                    prod_sel = 1'b1;
                    a_en = 1'b0;
                    a_sel = 1'b1;
                    b_en = 1'b0;
                    b_sel = 1'b1;
                    ct_en = 1'b0;
                    ct_ld = 1'b0;
                end
                else begin
                    nextState = SHIFT;
                    prod_en = 1'b0;
                    prod_sel = 1'b1;
                    a_en = 1'b1;
                    a_sel = 1'b1;
                    b_en = 1'b1;
                    b_sel = 1'b1;
                    ct_en = 1'b1;
                    ct_ld = 1'b0;
                end
            end

            ADD: begin
                nextState = SHIFT;
                prod_en = 1'b0;
                prod_sel = 1'b1;
                a_en = 1'b1;
                a_sel = 1'b1;
                b_en = 1'b1;
                b_sel = 1'b1;
                ct_en = 1'b1;
                ct_ld = 1'b0;

            end

            SHIFT: begin
                if (exit_loop) begin
                    nextState = CHECK;
                    prod_en = 1'b0;
                    prod_sel = 1'b1;
                    a_en = 1'b0;
                    a_sel = 1'b1;
                    b_en = 1'b0;
                    b_sel = 1'b1;
                    ct_en = 1'b0;
                    ct_ld = 1'b0;
                end
                else begin
                    //check
                    nextState = INIT;
                    prod_en = 1'b0;
                    prod_sel = 1'b1;
                    a_en = 1'b0;
                    a_sel = 1'b1;
                    b_en = 1'b0;
                    b_sel = 1'b1;
                    ct_en = 1'b0;
                    ct_ld = 1'b0;
                end
            end

            CHECK: begin
                if (N_flag == 1'b0 & Z_flag == 1'b0) begin
                    nextState = FINISH;
                    done = 1'b1;
                    ZN_flags = 2'b00;
                end
                if (N_flag == 1'b0 & Z_flag == 1'b1) begin
                    nextState = FINISH;
                    done = 1'b1;
                    ZN_flags = 2'b10;
                end
                if (N_flag == 1'b1 & Z_flag == 1'b0) begin
                    nextState = FINISH;
                    done = 1'b1;
                    ZN_flags = 2'b01;
                end
            end

            FINISH: begin
                nextState = FINISH;
            end

            default: begin
                nextState = IDLE;
            end
        endcase
    end

endmodule : Task2FSM
