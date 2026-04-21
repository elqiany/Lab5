//`default_nettype none


// w-bit Comparator (non-magnitude variety)
module Comparator
 #(parameter WIDTH = 8)
  (input logic  [WIDTH-1:0] A,
   input logic  [WIDTH-1:0] B,
   output logic             AeqB);

  assign AeqB = (A == B);

endmodule: Comparator


// w-bit magnitude comparator
module MagComp
 #(parameter WIDTH= 8)
  (input logic signed [WIDTH-1:0] A,
   input logic signed [WIDTH-1:0] B,
   output logic             AltB,
   output logic             AeqB,
   output logic             AgtB);

  assign AltB = (A < B);
  assign AeqB = (A == B);
  assign AgtB = (A > B);

endmodule: MagComp


// w-bit Adder
module Adder
 #(parameter WIDTH= 8)
  (input  logic             cin,
   input  logic [WIDTH-1:0] A, B,
   output logic             cout,
   output logic [WIDTH-1:0] sum);

  assign {cout, sum} = A + B + cin;

endmodule : Adder


// w-bit Subtracter
module Subtracter
 #(parameter WIDTH= 8)
  (input  logic             bin,
   input  logic [WIDTH-1:0] A, B,
   output logic             bout,
   output logic [WIDTH-1:0] diff);

  assign {bout, diff} = A - B - bin;

endmodule : Subtracter


// w:1 Multiplexer
module Multiplexer
 #(parameter WIDTH= 8)
  (input logic  [WIDTH-1:0]         I,
   input logic  [$clog2(WIDTH)-1:0] S,
   output logic                     Y);

  assign Y = I[S];

endmodule: Multiplexer


// 2:1 multiplexer (for w-bit values)
module Mux2to1
 #(parameter WIDTH= 8)
  (input logic  [WIDTH-1:0] I0,
   input logic  [WIDTH-1:0] I1,
   input logic              S,
   output logic [WIDTH-1:0] Y);

  assign Y = (S == 1'b0) ? I0 : I1;

endmodule: Mux2to1


// log2(WIDTH):w Decoder With Enable
module Decoder
 #(parameter WIDTH = 8)
  (input logic  [$clog2(WIDTH)-1:0] I,
   input logic                      en,
   output logic [WIDTH-1:0]         D);

  always_comb begin
    D = 8'b00000000;
    if (en == 1'b1)
      D[I] = 1'b1;
  end

endmodule: Decoder


// DFlipFlop
module DFlipFlop
  (input logic  D,
   input logic  clock,
   input logic  preset_L,
   input logic  reset_L,
   output logic Q);

  always_ff @ (posedge clock) begin
    if (preset_L == 1'b0)
      Q <= 1'b1;
    else if (reset_L == 1'b0)
      Q <= 1'b0;
    else
      Q <= D;
  end

endmodule : DFlipFlop


// Register
module Register
 #(parameter WIDTH = 8)
  (input logic              en,
   input logic              clear,
   input logic  [WIDTH-1:0] D,
   input logic              clock,
   output logic [WIDTH-1:0] Q);

  always_ff @ (posedge clock) begin
    if (en == 1'b1) begin
      if (clear == 1'b1)
        Q <= '0;
      else
        Q <= D;
    end
  end

endmodule : Register


// w-bit Counter
module Counter
 #(parameter WIDTH = 8)
  (input  logic             en,
   input  logic             clear,
   input  logic             load,
   input  logic             up,
   input  logic [WIDTH-1:0] D,
   input  logic             clock,
   output logic [WIDTH-1:0] Q);

  always_ff @ (posedge clock) begin
    if (en == 1'b1) begin
      if (clear == 1'b1)
        Q <= '0;
      else if (load == 1'b1)
        Q <= D;
      else begin
        if (up == 1'b0)
          Q <= Q - 1;
        else // up == 1'b1
          Q <= Q + 1;
      end
    end
  end

endmodule : Counter


// ShiftRegisterSIPO
module ShiftRegisterSIPO
 #(parameter WIDTH = 8)
  (input logic              en,
   input logic              left,
   input logic              serial,
   input logic              clock,
   output logic [WIDTH-1:0] Q);

  always_ff @ (posedge clock) begin
    if (en == 1'b1) begin
      if (left == 1'b1) begin
        Q <= {Q[WIDTH-2:0], serial};
      end
      else begin // left == 1'b0 (right)
        Q <= {serial, Q[WIDTH-1:1]};
      end
    end
  end

endmodule : ShiftRegisterSIPO


// ShiftRegisterPIPO
module ShiftRegisterPIPO
 #(parameter WIDTH = 8)
  (input logic              en,
   input logic              left,
   input logic              load,
   input logic  [WIDTH-1:0] D,
   input logic              clock,
   output logic [WIDTH-1:0] Q);

  always_ff @ (posedge clock) begin
    if (en == 1'b1) begin
      if (load == 1'b1)
        Q <= D;
      else begin
        if (left == 1'b1)
          Q <= Q << 1;
        else // left == 1'b0 (right)
          Q <= Q >> 1;
      end
    end
  end

endmodule : ShiftRegisterPIPO


// BarrelShiftRegister (only shifts left by 0,1,2, or 3)
module BarrelShiftRegister
 #(parameter WIDTH = 8)
  (input logic              en,
   input logic              load,
   input logic  [1:0]       by,
   input logic  [WIDTH-1:0] D,
   input logic              clock,
   output logic [WIDTH-1:0] Q);

  always_ff @ (posedge clock) begin
    if (en == 1'b1) begin
      if (load == 1'b1)
        Q <= D;
      else
        Q <= Q << by;
    end
  end

endmodule : BarrelShiftRegister


// Synchronizer
module Synchronizer
  (input  logic async,
   input  logic clock,
   output logic sync);

  logic sync_buf;

  always_ff @ (posedge clock) begin
    sync_buf <= async;
    sync <= sync_buf;
  end

endmodule : Synchronizer


// BusDriver
module BusDriver
 #(parameter WIDTH= 8)
  (input  logic             en,
   input  logic [WIDTH-1:0] data,
   output logic [WIDTH-1:0] buff,
   inout  tri   [WIDTH-1:0] bus);

   assign bus = (en == 1'b1) ? data : 'bz;
   assign buff = bus;

endmodule : BusDriver


// Memory
module Memory
 #(parameter DW = 16,
              W = 256,
             AW = $clog2(W))
  (input  logic re, we, clock,
   input  logic [AW-1:0] addr,
   inout  tri   [DW-1:0] data);

  logic [DW-1:0] M[W];
  logic [DW-1:0] rData;

  assign data = (re == 1'b1) ? rData : 'bz;

  always_ff @ (posedge clock) begin
    if (we)
      M[addr] <= data;
  end

  always_comb begin
    rData = M[addr];
  end

endmodule : Memory

// SImple 3-state Moore FSM
// When it detects a rising edge on the input, it will assert the output for
// 1 cycle
// There is 1 cycle latency because it is Moore. I am too lazy to make it
// Mealy
module RisingEdgeDetector
    (input logic clock, reset, signal,
    output logic signal_rising);

    enum logic [1:0] {idle, rising, buffer} state, nextState;

    // next state selection
    // output is only asserted in the "rising" state, so we immediately send
    // it to buffer if the signal is still high
    // the buffer state waits for a falling edge to transition back to idle.
    always_comb begin
        case (state)
            idle: begin
                signal_rising = 0;
                if (signal) nextState = rising;
                else nextState = idle;
            end
            rising: begin
                signal_rising = 1;
                if (signal) nextState = buffer;
                if (~signal) nextState = idle;
            end
            buffer: begin
                signal_rising = 0;
                if (~signal) nextState = idle;
                else nextState = buffer;
            end
            default:
                nextState = idle;
        endcase
    end


    always_ff @(posedge clock)
        if (reset)
            state <= idle;
        else
            state <= nextState;
endmodule: RisingEdgeDetector
