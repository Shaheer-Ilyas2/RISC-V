`timescale 1ns/1ps

module tb_datapath( );
   logic clk;
   logic reset;
   logic MTI;
   logic EI;

   datapath dp(
      .clk(clk),
      .reset(reset),
      .MTI(MTI),
      .EI(EI)
   );

   //GENERATE CLOCK
   initial begin
      clk = 0;
      forever begin 
      #5; clk = ~clk;
      end
   end
   
   initial begin

      #10;
      reset <= 1;
      #7;
      reset <= 0;
   end

   initial begin
      #180; MTI = 1; #20; MTI = 0;
   end
endmodule
