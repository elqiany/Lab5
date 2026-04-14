`default_nettype none

// Muliplication Coprocessor 
module Multiplier (
  input logic         start, reset, clock,
  input logic  [7:0]  a, b,
  output logic        done,
  output logic [1:0]  ZN_flags,  
  output logic [15:0] out);


  // Instantiate multiplier fsm here

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
  logic [15:0] B_pos, B_neg, B_inv, B_abs, B1, B2, B_shift;
  
  // Converts B from 8-bit to 16-bit
  assign B_pos = {8'b0000_0000, b};
  assign B_neg = {8'b1111_1111, b};

  // Performs the absolute value of B
  assign B_inv = ~B_neg;
  Adder #(16) BAbs (.cin(), .A(B_inv), .B(16'd1), .sum(B_abs), .cout());

  // Determine original msb of B
  logic       msbB1_not; 
  logic [7:0] msbB_og;
  assign msbB_og = (b & 8'b1000_0000);
  Comparator #(8) negBCheck (.A(msbB_og), .B(8'd0), .AeqB(msbB1_not));
  assign msbB1 = ~msbB1_not;

  Mux2to1 #(16) BSel (.I0(B_abs), .I1(B_pos), .Y(B1), .S(msbB1_not));
  Mux2to1 #(16) BShiftSel (.I0(B1), .I1(B2), .Y(B_shift), .S(b_sel));

  ShiftRegisterPIPO #(16) BShift (.en(b_en), .left(1'b0), .load(b_ld), 
                                  .D(B_shift), .clock(clock), .Q(B2));
  
  // Determine the least significant bit of B currently
  assign lsbB1 = (16'd1 & B2);

  // Handles A and calculating the product
  logic [15:0] A_pos, A_neg, A1, A2, A_shift;
  
  // Converts A from 8-bit to 16-bit
  assign A_pos = {8'b0000_0000, a};
  assign A_neg = {8'b1111_1111, a};

  // Determine original msb of A
  logic       msbA; 
  logic [7:0] msbA_og;
  assign msbA_og = (a & 8'b1000_0000);
  Comparator #(8) negACheck (.A(msbB_og), .B(8'd0), .AeqB(msbA));

  Mux2to1 #(16) ASel (.I0(A_neg), .I1(A_pos), .Y(A1), .S(msbA));
  Mux2to1 #(16) AShiftSel (.I0(A1), .I1(A2), .Y(A_shift), .S(a_sel));

  ShiftRegisterPIPO #(16) AShift (.en(a_en), .left(1'b1), .load(a_ld), 
                                  .D(A_shift), .clock(clock), .Q(A2));

  // Stores the updating product
  logic [15:0] prod_D, prod_Q, prod_new;
  Mux2to1 #(16) PSel (.I0(16'd0), .I1(prod_new), .Y(prod_D), .S(prod_sel));
  Register #(16) PStore (.en(prod_en), .clear(prod_clr), .D(prod_D), 
                         .clock(clock), .Q(prod_Q));
  Adder #(16) PTrack (.cin(), .A(prod_Q), .B(A2), .sum(prod_new), .cout());

  // Handles negating the product if B was originally negative
  logic [15:0] prod_Q_not, prod_Q_negated;
  assign prod_Q_not = ~prod_Q;
  Adder #(16) PNegate (.cin(), .A(prod_Q_not), .B(16'd1), 
                       .sum(prod_Q_negated), .cout());
  Mux2to1 #(16) finalPSel (.I0(prod_Q), .I1(prod_Q_negated), 
                           .Y(out), .S(msbB1));

  // Sets the flags bits based on the results of the multiplication
  MagComp #(16) flags (.A(out), .B(16'd0), .AltB(N_flag), 
                       .AeqB(Z_flag), .AgtB());                    

endmodule : Multiplier