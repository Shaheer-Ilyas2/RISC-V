`timescale 1ns/1ps
module branch_cond(
         input  logic [31:0] rs1,
         input  logic [31:0] rs2,
         input  logic [2:0] br_type,
         input  logic [6:0] opcode,
         output logic       br_taken
);

 always_comb begin
   if (opcode == 7'b1100011) begin //branch is there
      case(br_type) 
         3'b000 : br_taken = ( $signed(rs1) == $signed(rs2) ); //beq
         3'b001 : br_taken = ( $signed(rs1) != $signed(rs2) ); //bne
         3'b100 : br_taken = ( $signed(rs1) <  $signed(rs2) ); //blt
         3'b101 : br_taken = ( $signed(rs1) >= $signed(rs2) ); //bge
         3'b110 : br_taken = (         rs1  <          rs2  ); //bltu
         3'b111 : br_taken = (         rs1  >=         rs2  ); //bgtu
         
      endcase
   end
   else if (opcode == 7'd111 || opcode == 7'd103) begin
      br_taken = 1;
   end
   else begin
      br_taken = 0;
   end
end
endmodule