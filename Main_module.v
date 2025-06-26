`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2025 08:34:20 PM
// Design Name: 
// Module Name: Main_module
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


module Main_module(
    input clk,
    input reset, 
    //output [7:0]final_result,
    //output  [7:0]current_pc
    output  [6:0] LED_out,
    output  [3:0] Anode_Activate
    );
    
    wire [7:0] current_pc;
    reg [7:0] next_pc; 
    wire [13:0] instruction;
    wire flush; 
    wire pipeline_stall;
    //initialize fecth module
    Fetch fetch_inst(
    .current_pc(current_pc),
    .instruction(instruction) 
    ); 
    
    //register between fetch and decode for pipelining
    reg [13:0] dec_instruction;
    
    always @(posedge clk or posedge reset) begin
        if(reset | flush) begin 
            dec_instruction <= 14'b0; 
        end
        else if(pipeline_stall)
            dec_instruction <= dec_instruction; 
        else begin 
            dec_instruction <= instruction; 
       end
    end
    
    wire [7:0] reg1_read_data, reg2_read_data, gpr2_read_data;          //data from GPRs
    wire [3:0] opcode, reserved;                                       //opcode and reserved from decode
    wire [1:0]reg0_addr, reg1_addr, reg2_addr;                         //GPR addresses from instructions
    wire [7:0] operand0, operand1;                                     //operand from instructions
    
    
    //initialize deocde and general purpose register (GPR)
    Decode decode_inst(
    .i_instructions(dec_instruction),
    .i_reg1_read_data(reg1_read_data),
    .i_reg2_read_data(reg2_read_data),
    .o_opcode(opcode),
    .o_reg0_addr(reg0_addr),
    .o_reg1_addr(reg1_addr),
    .o_reg2_addr(reg2_addr), 
    .o_reserved(reserved),
    .o_operand0(operand0), 
    .o_operand1(operand1)
    );

    wire [1:0]write_reg_addr;                                     //address to write in GPR
    wire writeback_enable;                                         //control to write in GPR
    wire [7:0] gpr_write_data;                                    //data to write in GPR
    
    GP_register GPR_inst(
    .clk(clk),
    .reset(reset),
    .i_write_reg_addr(write_reg_addr),
    .i_read_reg1_addr(reg1_addr), 
    .i_read_reg2_addr(reg2_addr),
    .i_write_enable(writeback_enable), 
    .i_write_data(gpr_write_data),
    .o_reg1_data(reg1_read_data),
    .o_reg2_data(reg2_read_data),
    .o_GPR2_data(gpr2_read_data)
    );
    
    //pipeline between decode and ALU
    reg [3:0] alu_opcode, alu_reserved; 
    reg [1:0] alu_reg0_addr, alu_reg1_addr, alu_reg2_addr; 
    reg [7:0] alu_operand0, alu_operand1, alu_GPR2_data;
    
    
    always @ (posedge clk or posedge reset ) begin
        if(reset | flush ) begin
            alu_opcode <= 4'b0 ; 
            alu_reserved <= 4'b0; 
            alu_reg0_addr <= 2'b0; 
            alu_reg1_addr <= 2'b0; 
            alu_reg2_addr <= 2'b0; 
            alu_operand0 <= 8'b0; 
            alu_operand1 <= 8'b0; 
            alu_GPR2_data <= 8'b0; 
        end else if(pipeline_stall) begin 
            alu_opcode <= alu_opcode ; 
            alu_reserved <= alu_reserved; 
            alu_reg0_addr <= alu_reg0_addr; 
            alu_reg1_addr <= alu_reg1_addr; 
            alu_reg2_addr <= alu_reg2_addr; 
            alu_operand0 <= alu_operand0; 
            alu_operand1 <= alu_operand1; 
            alu_GPR2_data <= alu_GPR2_data; 
        end else begin
        
            alu_opcode <= opcode ; 
            alu_reserved <= reserved; 
            alu_reg0_addr <= reg0_addr; 
            alu_reg1_addr <= reg1_addr; 
            alu_reg2_addr <= reg2_addr; 
            alu_operand0 <= operand0; 
            alu_operand1 <= operand1;
            alu_GPR2_data <= gpr2_read_data; 
            end
    end
    
    wire [1:0] ALU_regdest;
    wire [7:0] ALU_results, ALU_st_data;  
    wire branch_taken, flag, alu_mem_write,alu_mem_read, reg_write, jmp, hlt; 
    
    reg [7:0] alu_muxA_output, alu_muxB_output; 
    wire [1:0] alu_muxA_sel, alu_muxB_sel; 
    reg [7:0] mem_ALU_results, mem_st_data;
    reg [7:0] wb_reg_data;
    
        //writeback output pipeline
    reg [7:0] wb_out_data; 
    reg [1:0] wb_out_addr; 
    reg wb_out_write_reg; 
    
    
    always @ (*) begin 
        alu_muxA_output = alu_operand0; 
        alu_muxB_output = alu_operand1; 
        
         if(alu_muxA_sel == 2'b11) 
            alu_muxA_output = wb_out_data; 
         if(alu_muxB_sel == 2'b11) 
            alu_muxB_output = wb_out_data;   
            
        if(alu_muxA_sel == 2'b10) 
            alu_muxA_output = wb_reg_data; 
         if(alu_muxB_sel == 2'b10) 
            alu_muxB_output = wb_reg_data;   
            
        if(alu_muxA_sel == 2'b01) 
            alu_muxA_output = mem_ALU_results; 
        if(alu_muxB_sel == 2'b01)
            alu_muxB_output = mem_ALU_results;
          
    end

    ALU ALU_inst(
    .i_opcode(alu_opcode), 
    .i_reserved(alu_reserved), 
    .i_reg0_addr(alu_reg0_addr),
    .i_reg1_addr(alu_reg1_addr),
    .i_reg2_addr(alu_reg2_addr),
    .i_operand0(alu_muxA_output),
    .i_operand1(alu_muxB_output),
    .i_GPR2_data(alu_GPR2_data), 
    .o_ALU_regdest(ALU_regdest),
    .o_results(ALU_results),
    .o_st_data(ALU_st_data),
    .o_flag(flag), 
    .o_mem_write(alu_mem_write), 
    .o_mem_read(alu_mem_read),
    .o_reg_write(reg_write), 
    .o_hlt(hlt), 
    .o_branch_taken(branch_taken), 
    .o_jmp(jmp)
    );
    
    //pipeline between ALU and MEM
    
    reg [1:0] mem_dest;
    reg mem_branch_taken , mem_flag, mem_mem_write, mem_mem_read, mem_reg_write, mem_jmp, mem_hlt; 
    always @ (posedge clk or posedge reset) begin
        if(reset | flush) begin
            mem_ALU_results <= 8'b0; 
            mem_dest <= 2'b0;
            mem_branch_taken <= 1'b0; 
            mem_flag <= 1'b0; 
            mem_mem_write <= 1'b0; 
            mem_mem_read <= 1'b0; 
            mem_reg_write <= 1'b0; 
            mem_jmp <= 1'b0; 
            mem_hlt <= 1'b0; 
            mem_st_data <= 1'b0; 
         end
        else begin 
            mem_ALU_results <= ALU_results; 
            mem_dest <= ALU_regdest;
            mem_branch_taken <= branch_taken;
            mem_flag <= flag; 
            mem_mem_write <= alu_mem_write;
            mem_mem_read <= alu_mem_read;
            mem_reg_write <= reg_write;
            mem_jmp <= jmp;
            mem_hlt <= hlt;
            mem_st_data <= ALU_st_data; 
        end
    end
    assign flush = mem_jmp | mem_branch_taken ; 
    wire [7:0] mem_output;
    
    //mem and writeback initialization
    
    MEM mem_inst(
    .a(mem_ALU_results),
    .d(mem_st_data),
    .clk(clk),
    .we(mem_mem_write),
    .spo(mem_output)    
    );
     
     wire [7:0] data_to_wb; 
     
    
     assign data_to_wb = mem_mem_read ? mem_output : mem_ALU_results; 
    // mem and writeback pipeline 
     
    reg [1:0] wb_reg_addr;
    reg wb_write_reg, wb_mem_read; 
    reg wb_hlt, wb_jmp; 
    
     assign  writeback_enable = wb_write_reg && ~wb_hlt;
    always @(posedge clk or posedge reset) begin 
        if(reset) begin
            wb_reg_data <= 8'b0; 
            wb_reg_addr <= 2'b0; 
            wb_write_reg <= 1'b0;
            wb_mem_read <= 1'b0;
            wb_hlt <= 1'b0; 
            wb_jmp <= 1'b0; 
        end else begin
            wb_reg_data <= data_to_wb; 
            wb_reg_addr <= mem_dest;
            wb_write_reg <= mem_reg_write;
            wb_mem_read <= mem_mem_read; 
            wb_hlt <= mem_hlt; 
            wb_jmp <= mem_jmp; 
        end
    end

    writeback writeback_inst(
    .i_enable(wb_write_reg),  
    .i_dest_reg_addr(wb_reg_addr), 
    .i_data(wb_reg_data),
    .o_gpr_write_data(gpr_write_data),
    .o_gpr_write_addr(write_reg_addr)
    );
    

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            wb_out_data <= 8'b0; 
            wb_out_addr <= 2'b0; 
            wb_out_write_reg <= 1'b0; 
        end else begin
            wb_out_data <= wb_reg_data; 
            wb_out_addr <= wb_reg_addr; 
            wb_out_write_reg <= wb_write_reg; 
        end
    end
    
    
    //assign final_result = gpr_write_data; 
        //pc control logic 
//    always @ (posedge clk or posedge reset) begin
//        if(reset) begin
//                next_pc <=8'b00000001; 
//                current_pc <= 8'b0;
//            end
//        else begin
//            next_pc <= current_pc + 1; 
//            current_pc <= next_pc;
//            if(jmp) next_pc <= pipeline_ALU_results; 
//            if(branch) next_pc <= current_pc + pipeline_GPR2_data;  
//            if(hlt) next_pc <= current_pc; 
//            end
//    end
    
    reg [7:0] pc;

    assign current_pc = pc;

always @(posedge clk or posedge reset) begin
    if(reset)
        pc <= 8'b00000000;
    else if(mem_hlt | pipeline_stall)
        pc <= pc; // hold
    else if(mem_jmp | mem_branch_taken)
        pc <= mem_ALU_results;
    else
        pc <= pc + 1; 
end

    //hazard unit instantiation 
    
    hazard_unit hazard_inst (
    .i_idex_rs1_addr(alu_reg1_addr), 
    .i_idex_rs2_addr(alu_reg2_addr), 
    .i_idex_opcode(alu_opcode), 
    .i_exmem_rd_addr(mem_dest),
    .i_exmem_write(mem_reg_write),
    .i_exmem_read(mem_mem_read),
    .i_memwb_write(wb_write_reg),
    .i_memwb_addr(wb_reg_addr),
    .i_wb_addr(wb_out_addr),
    .i_wb_write(wb_out_write_reg),
    .o_muxA_select(alu_muxA_sel),
    .o_muxB_select(alu_muxB_sel), 
    .o_pipeline_stall(pipeline_stall)
    );
    wire [15:0] counter; 
    
    cycle_counter counter_inst (
    .clk(clk), 
    .reset(reset),
    .i_processor_hlt(wb_hlt),
    .o_cycle_counter(counter)
    );
    
    seven_segment seg_inst(
    .clk(clk),
    .reset(reset),
    .displayed_number(counter),
    .Anode_Activate(Anode_Activate),
    .LED_out(LED_out)
    );

endmodule
