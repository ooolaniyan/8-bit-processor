`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2025 08:54:30 PM
// Design Name: 
// Module Name: Decode
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


module Decode(
    input [13:0]i_instructions,
    input [7:0] i_reg1_read_data, i_reg2_read_data,
    output reg [3:0] o_opcode,
    output reg [1:0] o_reg0_addr,
    output reg [1:0] o_reg1_addr,
    output reg [1:0] o_reg2_addr, 
    output reg [3:0] o_reserved,
    output reg[7:0] o_operand0, o_operand1 
    );
    
    //combinational logic deriving operands from instructions
    always @(*) begin 
        //default values first
        o_opcode = 4'b0;
        o_reg0_addr = 2'b0;
        o_reg1_addr = 2'b0;
        o_reg2_addr = 2'b0;
        o_reserved = 4'b0;
        o_operand0 = 8'b0;
        o_operand1 = 8'b0;
        
        //data input from registers
        o_operand0 = i_reg1_read_data;
        o_operand1 = i_reg2_read_data;
        o_opcode = i_instructions[13:10]; 
        o_reg0_addr = i_instructions[9:8]; 
        o_reg1_addr = i_instructions[7:6];
        o_reg2_addr = i_instructions[5:4];
        o_reserved = i_instructions[3:0];
        
    end 
    
  /*  always @(posedge clk or posedge reset)begin
        if(reset) begin
            Opcode <= 4'b0; 
            Reg0 <= 2'b0; 
            Reg1 <= 2'b0;
            Reg2 <=2'b0; 
            reserved <= 2'b0; 
            Operand0 <= 8'b0; 
            Operand1 <= 8'b0;
        end else begin
            Opcode <= instructions[13:10]; 
            Reg0 <= instructions[9:8];
            Reg1 <= instructions[7:6] ;
            Reg2 <= instructions[5:4];
            reserved <= instructions[3:0];
            Operand0 <= Reg1_data; 
            Operand1 <= Reg2_data;
        end
    
    end
    */
    
endmodule
