`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/20/2025 09:44:03 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
input [3:0] i_opcode, i_reserved, 
input [1:0] i_reg0_addr, i_reg1_addr, i_reg2_addr,
input [7:0] i_operand0, i_operand1, i_GPR2_data, 
output reg [1:0] o_ALU_regdest,
output reg [7:0] o_results, 
output reg [7:0] o_st_data,
output reg o_flag, o_mem_write, o_mem_read,o_reg_write, o_hlt, o_branch_taken, o_jmp
    );
    
    //Do all 16 instructions
    localparam NOP = 4'b0000; 
    localparam ADD = 4'b0001; 
    localparam SUB = 4'b0010; 
    localparam LDI = 4'b0011; 
    localparam AND = 4'b0100; 
    localparam OR = 4'b0101; 
    localparam XOR = 4'b0110; 
    localparam NOT = 4'b0111; 
    localparam SLL = 4'b1000; 
    localparam SRL = 4'b1001; 
    localparam LDM = 4'b1010; 
    localparam ST = 4'b1011;
    localparam JMP = 4'b1100; 
    localparam BEQ = 4'b1101; 
    localparam BENQ = 4'b1110; 
    localparam HLT = 4'b1111; 
    // overflow only handled for ADD
    reg [8:0] temp; 
    always @(*) begin 
        o_ALU_regdest = i_reg0_addr; 
        o_results = 8'b0; 
        o_flag = 1'b0;
        o_mem_write = 1'b0;
        o_mem_read = 1'b0;
        o_reg_write = 1'b0;
        o_hlt = 1'b0;
        o_branch_taken = 1'b0;
        o_jmp = 1'b0;
        o_st_data = 8'b0; 
        
        case(i_opcode)
            ADD: begin
                o_results = i_operand0 + i_operand1;
                o_reg_write = 1'b1;
                if(o_results < i_operand0) 
                    o_flag = 1'b1;
            end
            SUB: begin 
                o_results = i_operand0 - i_operand1;
                o_reg_write = 1'b1;
                temp = {1'b0, i_operand0} - {1'b0, i_operand1}; 
                o_flag = ~temp[8]; 
            end
            NOP: begin
                o_reg_write = 1'b0; 
            end
            AND: begin
                o_results = i_operand0 & i_operand1; 
                o_reg_write = 1'b1; 
            end
            OR:begin
                o_results = i_operand0 | i_operand1;
                o_reg_write = 1'b1;
            end
            XOR: begin 
                o_results = i_operand0 ^ i_operand1; 
                o_reg_write = 1'b1;
            end 
            NOT: begin
                o_results = ~i_operand0; 
                o_reg_write = 1'b1;                
            end
            SLL: begin 
                o_results = i_operand0 << i_operand1; 
                o_reg_write = 1'b1;
            end
            SRL: begin 
                o_results = i_operand0 >> i_operand1; 
                o_reg_write = 1'b1;
            end
            LDI: begin
                o_results = {i_reg1_addr,i_reg2_addr,i_reserved};  //immediate load
                o_reg_write = 1'b1;
            end
            LDM: begin
                o_results = i_operand0 + {4'b0, i_reserved};       //mem address to load
                o_mem_read = 1'b1; 
                o_reg_write = 1'b1;
            end
            ST: begin
                o_results = i_operand0 + {4'b0, i_reserved};       //mem address to store 
                o_mem_write = 1'b1;
                o_st_data = i_operand1;                               //data to store
            end
            JMP: begin
                o_results = i_operand0;                        // target instruction address
                o_jmp = 1'b1;
            end
            BEQ: begin
                if( i_operand0 == i_operand1) begin
                    o_branch_taken = 1'b1; 
                    o_results = i_GPR2_data + {4'b0, i_reserved};      //target address from GPR + offset
                    end
            end
            BENQ: begin
                if(i_operand0 != i_operand1) begin 
                    o_branch_taken = 1'b1;  
                    o_results = i_GPR2_data + {4'b0, i_reserved};      //target address from GPR + offset                          //address = current pc + reg2_data
                end
            end
            HLT: begin 
            o_hlt = 1'b1; 
            end
        endcase 
    end
 
endmodule
