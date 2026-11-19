`timescale 1ns / 1ps
// Simulation-only stand-ins for the two Vivado IP blocks used by the design.
// Do NOT add this file to the Vivado project; it is for xsim runs from sim/run.ps1.

// Instruction ROM (replaces dist_mem_gen_0). Program file comes from +PROG=<file.hex>.
module dist_mem_gen_0(input [7:0] a, output [13:0] spo);
  reg [13:0] rom [0:255];
  reg [1023:0] prog;
  integer i;
  initial begin
    for (i = 0; i < 256; i = i + 1) rom[i] = 14'h0;
    if ($value$plusargs("PROG=%s", prog))
      $readmemh(prog, rom);
    else
      $display("ip_models: no +PROG=<file> given, ROM is all NOPs");
  end
  assign spo = rom[a];
endmodule

// Data RAM (replaces MEM): synchronous write, asynchronous read.
module MEM(input [7:0] a, input [7:0] d, input clk, input we, output [7:0] spo);
  reg [7:0] ram [0:255];
  integer i;
  initial for (i = 0; i < 256; i = i + 1) ram[i] = 8'h0;
  always @(posedge clk) if (we) ram[a] <= d;
  assign spo = ram[a];
endmodule
