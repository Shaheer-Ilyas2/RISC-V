`timescale 1ns/1ps

module immediate_gen(
        input  logic [31:0] instr,
        input  logic [2:0] imm_control, 
        output logic [31:0] Imm_out,
        output logic [11:0] imm_csr
    );
    
   
    
   always_comb begin
        if      (imm_control == 3'b000) Imm_out = {{20{instr[31]}}, instr[31:20]};//I-type
        else if (imm_control == 3'b001) Imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]}; //S-type
        else if (imm_control == 3'b010) Imm_out = {instr[31:12], 12'b0}; // for U type
        else if (imm_control == 3'b011) Imm_out = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0}; // B-type
        else if (imm_control == 3'b100) Imm_out = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0}; //jAL
        else if (imm_control == 3'b101) imm_csr = {instr[31:20]}; // csr
   end 
    
endmodule