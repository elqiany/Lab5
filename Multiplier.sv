//`default_nettype none

// Muliplication Coprocessor
module Multiplier (
  input logic                start, reset, clock,
  input logic  signed [7:0]  a, b,
  output logic               done,
  output logic        [1:0]  ZN_flags,
  output logic signed [15:0] out);


  // FSM
  MultiplierFSM fsm (.*);

  // Control points
  logic prod_en, prod_clr, prod_sel;
  logic a_en, a_ld, a_sel;
  logic b_en, b_ld, b_sel;
  logic ct_en, ct_clr, ct_ld;

  // Status points
  logic lsbB1, msbB1, exit_loop, N_flag, Z_flag;

  // Datapath

  // Track the number of bits that have been processed
  logic [15:0] bitCount;
  Counter #(16) bitTracker (.en(ct_en), .clear(ct_clr), .load(ct_ld),
                            .up(1'b0), .D(16'd8), .clock(clock), .Q(bitCount));
  Comparator #(16) loopGuard (.A(bitCount), .B(16'd0), .AeqB(exit_loop));

  // Handles B
  logic signed [15:0] B_pos, B_neg, B_inv, B_abs, B1, B2, B_shift;

  // Converts B from 8-bit to 16-bit
  assign B_pos = {8'b0000_0000, b};
  assign B_neg = {8'b1111_1111, b};

  // Performs the absolute value of B
  assign B_inv = ~B_neg;
  Adder #(16) BAbs (.cin(1'b0), .A(B_inv), .B(16'd1), .sum(B_abs), .cout());

  // Determine original msb of B
  assign msbB1 = b[7];

  Mux2to1 #(16) BSel (.I0(B_pos), .I1(B_abs), .Y(B1), .S(msbB1));
  Mux2to1 #(16) BShiftSel (.I0(B1), .I1(B2), .Y(B_shift), .S(b_sel));

  ShiftRegisterPIPO #(16) BShift (.en(b_en), .left(1'b0), .load(b_ld),
                                  .D(B_shift), .clock(clock), .Q(B2));

  // Determine the least significant bit of B currently
  assign lsbB1 = B2[0];

  // Handles A and calculating the product
  logic signed [15:0] A_pos, A_neg, A1, A2, A_shift;

  // Converts A from 8-bit to 16-bit
  assign A_pos = {8'b0000_0000, a};
  assign A_neg = {8'b1111_1111, a};

  // Determine original msb of A
  logic msbA1;
  assign msbA1 = a[7];

  Mux2to1 #(16) ASel (.I0(A_pos), .I1(A_neg), .Y(A1), .S(msbA1));
  Mux2to1 #(16) AShiftSel (.I0(A1), .I1(A2), .Y(A_shift), .S(a_sel));

  ShiftRegisterPIPO #(16) AShift (.en(a_en), .left(1'b1), .load(a_ld),
                                  .D(A_shift), .clock(clock), .Q(A2));

  // Stores the updating product
  logic signed [15:0] prod_D, prod_Q, prod_new;
  Mux2to1 #(16) PSel (.I0(16'd0), .I1(prod_new), .Y(prod_D), .S(prod_sel));
  Register #(16) PStore (.en(prod_en), .clear(prod_clr), .D(prod_D),
                         .clock(clock), .Q(prod_Q));
  Adder #(16) PTrack (.cin(1'b0), .A(prod_Q), .B(A2), .sum(prod_new), .cout());

  // Handles negating the product if B was originally negative
  logic signed [15:0] prod_Q_not, prod_Q_negated;
  assign prod_Q_not = ~prod_Q;
  Adder #(16) PNegate (.cin(1'b0), .A(prod_Q_not), .B(16'd1),
                       .sum(prod_Q_negated), .cout());
  Mux2to1 #(16) finalPSel (.I0(prod_Q), .I1(prod_Q_negated),
                           .Y(out), .S(msbB1));

  // Sets the flags bits based on the results of the multiplication
  MagComp #(16) flags (.A(out), .B(16'd0), .AltB(N_flag),
                       .AeqB(Z_flag), .AgtB());

endmodule : Multiplier


//FSM for Task2 of Lab5
//Outputs signals like enables and clear
//but also outputs done and ZN flag
module MultiplierFSM(
    output logic prod_en,
    output logic prod_clr,
    output logic a_en,
    output logic a_ld,
    output logic b_en,
    output logic b_ld,
    output logic ct_en,
    output logic ct_clr,
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

    //state defn
    typedef enum logic [2:0] {
        IDLE = 3'b000,
        CLEAR = 3'b001,
        INIT = 3'b010,
        CHECK = 3'b011,
        SHIFT = 3'b100,
        ADD = 3'b101,
        EXIT = 3'b110,
        FINISH  = 3'b111
    } state_t;

    state_t currState, nextState;

    always_ff @(posedge clock or posedge reset) begin
        if (reset)
            currState <= IDLE;
        else
            currState <= nextState;
    end

    // next state logic
    always_comb begin
      nextState = currState;
      case(currState)
        IDLE: begin
          if (start)
            nextState = CLEAR;
          else
            nextState = IDLE;
        end

        CLEAR: nextState = INIT;

        INIT: nextState = CHECK;

        CHECK: begin
          if (lsbB1)
            nextState = ADD;
          else
            nextState = SHIFT;
        end

        ADD: nextState = SHIFT;

        SHIFT: nextState = EXIT;

        EXIT: begin
          if (exit_loop)
            nextState = FINISH;
          else
            nextState = CHECK;
        end

        FINISH: begin
          if (start)
            nextState = FINISH;
          else
            nextState = IDLE;
        end
        default: nextState = IDLE;
      endcase
    end

    // output generation logic
    always_comb begin
      prod_en   = 1'b0;
      prod_clr  = 1'b0;
      a_en      = 1'b0;
      a_ld      = 1'b0;
      b_en      = 1'b0;
      b_ld      = 1'b0;
      ct_en     = 1'b0;
      ct_clr    = 1'b0;
      ct_ld     = 1'b0;
      prod_sel  = 1'b0;
      a_sel     = 1'b0;
      b_sel     = 1'b0;
      done      = 1'b0;
      ZN_flags  = 2'b00;

      case(currState)
        IDLE: begin
          prod_en = 1'b0;
          prod_clr = 1'b0;
          prod_sel = 1'b0;
          a_en = 1'b0;
          a_ld = 1'b0;
          a_sel = 1'b0;
          b_en = 1'b0;
          b_ld = 1'b0;
          b_sel = 1'b0;
          ct_en = 1'b0;
          ct_clr = 1'b0;
          ct_ld = 1'b0;
          done = 1'b0;
        end

        CLEAR: begin
          prod_en = 1'b1;
          prod_clr = 1'b1;
          prod_sel = 1'b0;
          a_en = 1'b0;
          a_ld = 1'b0;
          a_sel = 1'b0;
          b_en = 1'b0;
          b_ld = 1'b0;
          b_sel = 1'b0;
          ct_en = 1'b1;
          ct_clr = 1'b1;
          ct_ld = 1'b0;
          done = 1'b0;
        end

        INIT: begin
          prod_en = 1'b1;
          prod_clr = 1'b0;
          prod_sel = 1'b0;
          a_en = 1'b1;
          a_ld = 1'b1;
          a_sel = 1'b0;
          b_en = 1'b1;
          b_ld = 1'b1;
          b_sel = 1'b0;
          ct_en = 1'b1;
          ct_clr = 1'b0;
          ct_ld = 1'b1;
          done = 1'b0;
        end

        CHECK: begin
          prod_en = 1'b0;
          prod_clr = 1'b0;
          prod_sel = 1'b0;
          a_en = 1'b0;
          a_ld = 1'b0;
          a_sel = 1'b0;
          b_en = 1'b0;
          b_ld = 1'b0;
          b_sel = 1'b0;
          ct_en = 1'b0;
          ct_clr = 1'b0;
          ct_ld = 1'b0;
          done = 1'b0;
        end

        ADD: begin
          prod_en = 1'b1;
          prod_clr = 1'b0;
          prod_sel = 1'b1;
          a_en = 1'b0;
          a_ld = 1'b0;
          a_sel = 1'b1;
          b_en = 1'b0;
          b_ld = 1'b0;
          b_sel = 1'b1;
          ct_en = 1'b0;
          ct_clr = 1'b0;
          ct_ld = 1'b0;
          done = 1'b0;
        end

        // Shifts both a and b & decrements the counter
        SHIFT: begin
          prod_en = 1'b0;
          prod_clr = 1'b0;
          prod_sel = 1'b1;
          a_en = 1'b1;
          a_ld = 1'b0;
          a_sel = 1'b1;
          b_en = 1'b1;
          b_ld = 1'b0;
          b_sel = 1'b1;
          ct_en = 1'b1;
          ct_clr = 1'b0;
          ct_ld = 1'b0;
          done = 1'b0;
        end

        EXIT: begin
          prod_en = 1'b0;
          prod_clr = 1'b0;
          prod_sel = 1'b0;
          a_en = 1'b0;
          a_ld = 1'b0;
          a_sel = 1'b0;
          b_en = 1'b0;
          b_ld = 1'b0;
          b_sel = 1'b0;
          ct_en = 1'b0;
          ct_clr = 1'b0;
          ct_ld = 1'b0;
          done = 1'b0;
        end

        FINISH: begin
          prod_en = 1'b0;
          prod_clr = 1'b0;
          prod_sel = 1'b0;
          a_en = 1'b0;
          a_ld = 1'b0;
          a_sel = 1'b0;
          b_en = 1'b0;
          b_ld = 1'b0;
          b_sel = 1'b0;
          ct_en = 1'b0;
          ct_clr = 1'b0;
          ct_ld = 1'b0;
          done = 1'b1;
          ZN_flags = {Z_flag, N_flag};
        end

        default: begin end
      endcase
    end

endmodule : MultiplierFSM
