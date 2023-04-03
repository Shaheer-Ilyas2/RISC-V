`timescale  1ns/1ps

module data_memory#(
   parameter length = 1024,
   parameter size   = 32 
   )(
      input  logic            clk,
      input  logic            reset,
      input  logic [size-1:0] addr,
      input  logic [size-1:0] wdata,
      input  logic            cs, rd_en,
      input  logic            mem_write,
      input  logic [3:0]      mask,
      output logic [size-1:0] rdata
   );

   logic [size-1:0] data_mem [length-1:0];

 
   assign rdata = ((cs) && (rd_en)) ? data_mem[addr] : '0;
   

//   always_comb begin
//      case(funct3)
 //  always_ff @( negedge clk, posedge reset) begin  // write operation
 //     if (reset) begin
  //       data_mem <= '{default : '0};
   //   end
   //   else if ((mem_write) && (!cs) ) begin
    //     if (mask == 2'b00) begin
    //        data_mem[addr] <= wdata[7:0];
    //     end
    //     else if (mask == 2'b01) begin
    //        data_mem[addr] <= wdata[15:0];
    //     end
    //     else if (mask == 2'b10) begin
   //         data_mem[addr] <= wdata;
  //       end      
 //  end
 //  end

   always_ff @( negedge clk, posedge reset) begin  // write operation
      if (reset) begin
         data_mem <= '{default : '0};
      end
      else if ((mem_write) && (cs) ) begin
         if (mask[0]) begin
            data_mem[addr][7:0] <= wdata[7:0];
         end
         if (mask[1]) begin
            data_mem[addr][15:8] <= wdata[15:8];
         end
         if (mask[2]) begin
            data_mem[addr][23:16] <= wdata[23:16];
         end
         if (mask[3]) begin
            data_mem[addr][31:24] <= wdata[31:24];
         end
      end
   end

   // always_ff @( negedge clk, posedge reset) begin  // write operation
   //    if (reset) begin
   //       data_mem <= '{default : '0};
   //    end
   //    else if ((mem_write) && (!cs) ) begin
   //       if (mask[0]) begin
   //          data_mem[addr[31:2]][7:0] <= wdata[7:0];
   //       end
   //       if (mask[1]) begin
   //          data_mem[addr[31:2]][15:8] <= wdata[15:8];
   //       end
   //       if (mask[2]) begin
   //          data_mem[addr[31:2]][23:16] <= wdata[23:16];
   //       end
   //       if (mask[3]) begin
   //          data_mem[addr[31:2]][31:24] <= wdata[31:24];
   //       end
   //    end
   // end

endmodule
