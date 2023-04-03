`timescale 1ns/1ps
module PC#(
   parameter data = 32
   )
   (
      input  logic  clk,
      input  logic  reset,

      input  logic [data-1:0]  pc_next,
      input  logic             stall,
      output logic [data-1:0]  pc
   );


   always_ff @( posedge clk  ) begin 
      if (reset) begin
         pc <= 0;
      end else if (!stall) begin
         pc <= pc_next;
      end   
   end
endmodule

