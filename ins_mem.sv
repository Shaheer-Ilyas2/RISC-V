`timescale 1 ns/1 ps
module ins_mem(
  input    logic [31:0] address,
  output   logic [31:0] instr
   );

  logic [31:0] lns_memory [31:0];

  initial begin
    $readmemh("C:/Users/MUHAMMAD SHAHEER/OneDrive/Desktop/plic_github/RISC/imem.txt", lns_memory);
    
  end
  assign instr = lns_memory[address[31:2]];   //byte addresible memory

endmodule
