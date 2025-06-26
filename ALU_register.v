`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/19/2025 09:42:16 PM
// Design Name: 
// Module Name: ALU_register
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


module GP_register(
    input clk,
    input reset,
    input [1:0] i_write_reg_addr,
    input [1:0] i_read_reg1_addr, 
    input [1:0] i_read_reg2_addr,
    input i_write_enable, 
    input [7:0] i_write_data,
    output [7:0] o_reg1_data,
    output [7:0] o_reg2_data,
    output [7:0] o_GPR2_data
    );
    
    reg [7:0] Register [3:0]; 
    integer i; 
    
    //combinational logic to read data from registers based on reg addr input
    assign o_reg1_data = Register[i_read_reg1_addr];
    assign o_reg2_data = Register[i_read_reg2_addr];  
    assign o_GPR2_data = Register[1];   
    
    //sequential logic to write registers. reset values to zero
    always @(posedge clk or posedge reset) begin
        if(reset) begin 
        for( i= 0; i < 4; i = i + 1)
            Register[i] <= 8'b0; 
        end 
        else if (i_write_enable) begin
            Register[i_write_reg_addr] <= i_write_data; 
        end
        
    end 
endmodule
