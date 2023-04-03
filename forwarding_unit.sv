module forwarding_unit(
   input  logic  [31:0] instr_F,
   input  logic  [31:0] instr_E,
   input  logic         reg_write_E,
   input  logic         br_taken,
   input  logic         flush_mret,
   output logic         forA,
   output logic         forB,
   output logic         stall,
   output logic         stall_MW,
   output logic         flush
);

// Hazard detection and Forwarding
always_comb begin
   if ((instr_E[11:7] == instr_F[19:15]) & (reg_write_E) & (instr_E[11:7] != 0) ) begin
      forA = 1;
   end
   else begin
      forA = 0;
   end
   if ((instr_E[11:7] == instr_F[24:20]) & (reg_write_E) & (instr_E[11:7] != 0) ) begin
      forB = 1;
   end
   else begin
      forB = 0;
   end

//   default : begin
//      forA = '0;
//      forB = '0;
//   end

end
// stalling
always_comb begin
   if (((instr_E[6:0] == 7'b0000011) && 
      ((instr_E[11:7] == instr_F[24:20]) || (instr_E[11:7] == instr_F[19:15]))) && 
      (reg_write_E)) begin
      stall    = 1;
      stall_MW = 1;
   end
   else begin
      stall    = 0;
      stall_MW = 0;
   end
end
// flushing
always_comb begin
   if (br_taken || flush_mret) begin
      flush = 1;
   end
   else begin
      flush = 0;
   end
end

endmodule