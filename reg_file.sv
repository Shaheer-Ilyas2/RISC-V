`timescale 1ns/1ps

module reg_file#(
   parameter length = 32,
   parameter size   = 32
   )
   (
      input   logic [4:0]   raddr1,
      input   logic [4:0]   raddr2,
      input   logic [4:0]   waddr,      
      input   logic         clk,
      input   logic         reg_write,
      input   logic         reset,
      input   logic [31:0]  wdata,
      output  logic [31:0]  rdata1,
      output  logic [31:0]  rdata2
   );

   logic [size-1:0] registers [length-1:0];
   
   assign rdata1 = registers[raddr1];
   assign rdata2 = registers[raddr2]; 
   
   always_ff @( negedge clk, posedge reset) begin  // write operation
      if (reset ) begin
         registers <= '{default : '0};
      end
      else if (reg_write && waddr != 0 ) begin
         registers[waddr] <= wdata;
      end
   end

   
endmodule
      


