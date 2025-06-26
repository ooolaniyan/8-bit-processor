`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/16/2025 06:54:42 PM
// Design Name: 
// Module Name: writeback
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


module writeback(
    input i_enable,  
    input [1:0]i_dest_reg_addr, 
    input [7:0] i_data,
    output reg [7:0] o_gpr_write_data,
    output reg [1:0] o_gpr_write_addr
    );
    
    always @(*) begin 
        if(i_enable) begin
            o_gpr_write_data = i_data ; 
            o_gpr_write_addr = i_dest_reg_addr; 
        end else begin 
          o_gpr_write_data = 8'b0; 
          o_gpr_write_addr = 2'b0;   
        end 
    end
    
//    always @(posedge clk or posedge reset) begin
//        if(reset) begin
//            output_results <= 8'b0; 
//            destReg <= 2'b0; 
//            end
//        else if(enable) begin 
//            output_results <= results; 
//            destReg <= inputReg; 
//        end
        
//    end
    
endmodule
