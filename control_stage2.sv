module control_stage2(
   input  logic clk,
   input  logic reset,
   input  logic reg_write,
   input  logic mem_write,
   input  logic rd_en,
   input  logic [1:0] wb_sel,
   input  logic cs,
   input  logic csr_reg_rd,
   input  logic csr_reg_wr,
   input  logic stall_MW,
   output logic reg_write_E,
   output logic mem_write_E,
   output logic rd_en_E,
   output logic [1:0] wb_sel_E, 
   output logic cs_E,
   output logic csr_reg_rd_E,
   output logic csr_reg_wr_E
);

always_ff @( posedge clk, posedge reset ) begin
   if(reset) begin
      reg_write_E  <= 0;
      mem_write_E  <= 0;
      rd_en_E      <= 0;
      wb_sel_E     <= 0;
      cs_E         <= 1;
      csr_reg_rd_E <= 0;
      csr_reg_wr_E <= 0;
   end
   else if (!stall_MW) begin
      reg_write_E  <= reg_write;
      mem_write_E  <= mem_write;
      rd_en_E      <= rd_en;
      wb_sel_E     <= wb_sel;
      cs_E         <= cs; 
      csr_reg_rd_E <= csr_reg_rd;
      csr_reg_wr_E <= csr_reg_wr;   
   end

end

endmodule
