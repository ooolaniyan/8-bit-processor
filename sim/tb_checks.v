`timescale 1ns / 1ps
// Self-checking testbench. Pick the test with +TEST=<name> and the program with +PROG=<file>.
// Prints PASS or FAIL lines and a final RESULT line.
module tb_checks;
  reg clk = 0, reset = 1;
  wire [6:0] seg; wire [3:0] an;
  Main_module uut(.clk(clk), .reset(reset), .LED_out(seg), .Anode_Activate(an));
  always #5 clk = ~clk;

  integer fails = 0;
  reg [8*32-1:0] test;
  reg [7:0] pc_mark;

  task check(input [8*24-1:0] what, input [7:0] got, input [7:0] want);
    if (got === want) $display("  PASS  %0s = %0d", what, got);
    else begin $display("  FAIL  %0s = %0d (expected %0d)", what, got, want); fails = fails + 1; end
  endtask

  task dump;
    $display("  state: R0=%0d R1=%0d R2=%0d R3=%0d mem[0]=%0d mem[1]=%0d pc=%0d cycles=%0d",
      uut.GPR_inst.Register[0], uut.GPR_inst.Register[1], uut.GPR_inst.Register[2],
      uut.GPR_inst.Register[3], uut.mem_inst.ram[0], uut.mem_inst.ram[1], uut.pc, uut.counter);
  endtask

  initial begin
    if (!$value$plusargs("TEST=%s", test)) test = "none";
    #20 reset = 0;
    #500;
    pc_mark = uut.pc;
    #100;
    $display("TEST %0s", test);
    dump;
    if (test == "load_use") begin
      // LDM R2 then ADD R2,R2,R2 must give 2*5 = 10
      check("R0", uut.GPR_inst.Register[0], 8'd5);
      check("mem[0]", uut.mem_inst.ram[0], 8'd5);
      check("R2", uut.GPR_inst.Register[2], 8'd10);
    end else if (test == "halt") begin
      // instruction before HLT completes, instructions after HLT never do, PC stops
      check("R0", uut.GPR_inst.Register[0], 8'd1);
      check("R2", uut.GPR_inst.Register[2], 8'd0);
      check("R3", uut.GPR_inst.Register[3], 8'd0);
      check("pc unchanged", uut.pc, pc_mark);
    end else if (test == "branch_r1") begin
      // BEQ right after LDI R1,8 must jump to R1+4 = 12 (sets R3=10), not 0+4 (sets R2=187)
      check("R1", uut.GPR_inst.Register[1], 8'd8);
      check("R2", uut.GPR_inst.Register[2], 8'd0);
      check("R3", uut.GPR_inst.Register[3], 8'd10);
    end else begin
      $display("  (no checks for this test, state dump only)");
    end
    if (fails == 0) $display("RESULT %0s: PASS", test);
    else            $display("RESULT %0s: FAIL (%0d)", test, fails);
    $finish;
  end
endmodule
