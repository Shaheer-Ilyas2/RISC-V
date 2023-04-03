module stage2_reg(
   input  logic        clk,
   input  logic        reset,
   input  logic [31:0] pc,
   input  logic [31:0] rdata2,
   input  logic [31:0] alu_o,
   input  logic [31:0] instr_F,
   input  logic [31:0] csr_wdata,
   input  logic [11:0] csr_addr,
   input  logic        stall_MW,
   output logic [31:0] rdata2_E,
   output logic [31:0] pc_E,
   output logic [31:0] alu_o_E,
   output logic [31:0] instr_E,
   output logic [31:0] csr_wdata_E,
   output logic [11:0] csr_addr_E
);

always_ff  @( posedge clk, posedge reset ) begin
   if (reset) begin
      rdata2_E    <= 0;
      pc_E        <= 0;
      alu_o_E     <= 0; 
      instr_E     <= 0;
      csr_addr_E  <= 0;
      csr_wdata_E <= 0;
   end
   else if (!stall_MW) begin
      rdata2_E    <= rdata2;
      pc_E        <= pc;
      alu_o_E     <= alu_o;
      instr_E     <= instr_F;
      csr_addr_E  <= csr_addr;
      csr_wdata_E <= csr_wdata; 
   end

end

endmodule