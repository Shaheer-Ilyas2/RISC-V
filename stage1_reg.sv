module stage1_reg(
   input  logic clk,
   input  logic reset,
   input  logic [31:0] pc,
   input  logic [31:0] instr,
   input  logic        stall,
   input  logic        flush,
   output logic [31:0] instr_F,
   output logic [31:0] pc_F
);

always_ff  @( posedge clk, posedge reset ) begin
   if (reset ) begin
      instr_F <= 0;
      pc_F    <= 0;
   end
   else if (!stall & !flush) begin // !stall
      instr_F <= instr;
      pc_F    <= pc;
   end
   else if (flush) begin
      instr_F <= 32'h00000013;
   end

end

endmodule