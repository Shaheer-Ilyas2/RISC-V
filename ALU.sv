`timescale 1 ns/1 ps
module alu (
  output logic [31:0] out,
  input  logic [31:0] A,
  input  logic [31:0] B,
  input  logic [3:0] ALUcontrol
);

  always_comb begin
    case (ALUcontrol)
      4'd0: out=A+B; //ADD
      4'd1: out=A-B; //SUB
      4'd2: out=A<<B; //SLL SHIFT A by 'B' bits
      4'd3: out = ( $signed(A) < $signed(B) ) ? 1 : 0; // SLT
      4'd4: out=A&B; //AND
      4'd5: out=A|B; //OR
      4'd6: out=A^B; //XOR
      4'd7: out=A>>B; //SRL SHIFT A by 'B' bits
      4'd8: out=A>>>B; //SRA SHIFT A by 'B' bits
      4'd9: out=( A < B ) ? 1 : 0;  //SET IF B IS GREATER THAN A (SLTU)
      4'd10: out = B;  //LUI
    endcase

  end
endmodule