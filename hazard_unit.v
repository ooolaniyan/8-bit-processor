`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/24/2025 03:00:16 PM
// Design Name: 
// Module Name: hazard_unit
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


module hazard_unit(
    input [1:0] i_idex_rs1_addr, 
    input [1:0] i_idex_rs2_addr, 
    input [3:0] i_idex_opcode, 
    input [1:0] i_exmem_rd_addr,
    input i_exmem_write,
    input i_exmem_read,
    input i_memwb_write,
    input [1:0]i_memwb_addr,
    input [1:0]i_wb_addr,
    input i_wb_write,
    output reg [1:0] o_muxA_select,
    output reg [1:0] o_muxB_select, 
    output reg o_pipeline_stall
        );
     //module to detect RAW hazards. When hazard detected, 
     //forward to idex pipeline inputs from GPR or ex/mem pipeline or mem/wb pipeline  
     //option to stall pipeline if necessary
     
     wire ex_read_rs1; 
     wire ex_read_rs2; 
     
     assign ex_read_rs1 = ( (i_idex_opcode) == 4'b0011 || (i_idex_opcode) == 4'b0) ? 1'b0 : 1'b1;  
     assign ex_read_rs2 = ( (i_idex_opcode) == 4'b1100 || (i_idex_opcode) == 4'b0011 || (i_idex_opcode) == 4'b0 || (i_idex_opcode) == 4'b0111 || (i_idex_opcode) == 4'b1010  ) ? 1'b0 : 1'b1;  
     
        always @ (*) begin 
            o_muxA_select = 2'b0; 
            o_muxB_select = 2'b0; 
            o_pipeline_stall = 1'b0; 
            
            if( i_exmem_write && !i_exmem_read && (i_exmem_rd_addr == i_idex_rs1_addr) && ex_read_rs1) 
                o_muxA_select = 2'b01; 
            else if( i_memwb_write && (i_memwb_addr == i_idex_rs1_addr) && ex_read_rs1) 
                o_muxA_select = 2'b10; 
            else if( i_wb_write && (i_wb_addr == i_idex_rs1_addr) && ex_read_rs1) 
                o_muxA_select = 2'b11; 
                    
            if( i_exmem_write && !i_exmem_read && (i_exmem_rd_addr == i_idex_rs2_addr) && ex_read_rs2)
                o_muxB_select = 2'b01; 
            else if( i_memwb_write && (i_memwb_addr == i_idex_rs2_addr) && ex_read_rs2) 
                 o_muxB_select = 2'b10;
            else if( i_wb_write && (i_wb_addr == i_idex_rs2_addr) && ex_read_rs2) 
                o_muxB_select = 2'b11; 
                
            if( i_exmem_read && i_exmem_write && ( (ex_read_rs1 && (i_exmem_rd_addr == i_idex_rs1_addr) ) || (ex_read_rs2 && (i_exmem_rd_addr == i_idex_rs2_addr) ) ) )  begin
                o_pipeline_stall = 1'b1; 
                end
          end  
    
endmodule
