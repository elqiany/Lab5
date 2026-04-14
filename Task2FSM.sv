`default_nettype none

//FSM for Task2 of Lab5
//Outputs signals like enables and clear
module FSM(
    output logic prod_en,
    output logic prod_clr,
    output logic a_en,
    output logic a_ld,
    output logic b_en,
    output logic b_ld,
    output logic ct_en,
    output logic ct_clear,
    output logic ct_ld,
    output logic done,
    output logic [1:0] ZN flags,
    input logic start,
    input logic lsbB1,
    input logic N_flag,
    input logic Z_flag,
    input logic clock);

    typedef enum logic [2:0] {
        IDLE = 2'b000,
        INIT = 2'b001,
        SHIFT = 2'b010,
        ADD = 2'b011,
        CHECK = 2'b100,
        FINISH  = 2'b101
    } state_t;

    state_t currState, nextState;

    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            currState <= IDLE;
        else
            currState <= nextState;
    end

    always_comb begin
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
            end

            CHECK: begin
                if (N_flag = 1'b0 & Z_flag = 1'b0)
                    nextState = FINISH;
                    done = 1'b1;
                    ZN Flag = 2'b00;
                if (N_flag = 1'b0 & Z_flag = 1'b1)
                    nextState = FINISH;
                    done = 1'b1;
                    ZN Flag = 2'b10;
                if (N_flag = 1'b1 & Z_flag = 1'b0)
                    nextState = FINISH;
                    done = 1'b1;
                    ZN Flag = 2'b01;
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
