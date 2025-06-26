`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 04:30:33 PM
// Design Name: 
// Module Name: Main_module_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module Main_module_tb;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
  //  wire [7:0] final_result;
   // wire [7:0] current_pc;
   
       wire  [6:0] seg;
       wire [3:0] an;

    // Instantiate the Main_module
    Main_module uut (
        .clk(clk),
        .reset(reset),
        .LED_out(seg),
        .Anode_Activate(an)
    );

    // Clock generation: 10ns period (100MHz)
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;

        #20;
        reset = 0;

        #300;

        $display("Simulation finished.");
        $finish;
    end

endmodule
