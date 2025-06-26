`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2025 07:04:32 PM
// Design Name: 
// Module Name: CPI calculator
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

module cycle_counter (
    input wire clk,
    input wire reset,
    input wire i_processor_hlt,       
    output reg [15:0] o_cycle_counter 
);

    reg processor_has_halted; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            o_cycle_counter <= 0;
            processor_has_halted <= 1'b0;
        end else begin
            if (i_processor_hlt) begin
                processor_has_halted <= 1'b1; 
            end
            
            if (!processor_has_halted) begin 
                o_cycle_counter <= o_cycle_counter + 1;
            end
        end
    end

endmodule