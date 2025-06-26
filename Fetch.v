`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2025 09:36:00 PM
// Design Name: 
// Module Name: Fetch
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


module Fetch(
input [7:0] current_pc,
output [13:0] instruction 
    );
    
//    InstructionMemory inst(
//    .address(current_pc),
//    .instruction(instruction)
//    );

    //Instantiate ROM instruction memory. 
    dist_mem_gen_0 instruction_mem(
    .a(current_pc),
    .spo(instruction)
    );
    

    
    
endmodule

