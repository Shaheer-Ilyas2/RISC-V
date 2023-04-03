module CSR_reg(
   input  logic        clk,
   input  logic        reset,
   input  logic [31:0] pc,
   input  logic [11:0] addr,
   input  logic [31:0] wdata,
   input  logic        reg_write,
   input  logic        reg_rd,
   input  logic        MTI,
   input  logic        EI,
   input  logic        interrupt,
   output logic [31:0] rdata,
   output logic [31:0] epc,
   output logic        exception
);

logic [31:0] mstatus;
logic [31:0] mie;
logic [31:0] mtvec;
logic [31:0] mepc;
logic [31:0] mcause;
logic [31:0] mip;

logic [1:0]  MT_mip;
logic [1:0]  MT_mie;
logic        MT_mstatus;
logic        x1, x2;
logic        y1, y2;
logic [31:0] METI;



//handling interrupts

always_comb begin
   if ( MTI || EI ) begin
      MT_mip[0] = mip[7];
      MT_mip[1] = mip[11];
      MT_mie[0] = mie[7];
      MT_mie[1] = mie[11];
      MT_mstatus = mstatus[3];

   end 
end

always_comb begin
   //exception='{default:1'b0};
   if (MTI || EI) begin
      x1 = MT_mip[0] && MT_mie[0];
      x2 = MT_mip[1] && MT_mie[1];
      y1 = x1 && MT_mstatus;
      y2 = x2 && MT_mstatus;
      exception = y1 || y2; //output signal
      METI      = mcause[31:0];
      epc       = METI << 2;
   end
   else if (interrupt) begin
      epc       = mepc;
      exception = 1;
   end
   else if (!interrupt) begin
      exception = 0;
   end
end


// CSR read operation

always_comb begin 
   rdata  = '0;
   if (reg_rd) begin
      case (addr)
      12'h300 : rdata = mstatus;
      12'h304 : rdata = mie;
      12'h305 : rdata = mtvec;
      12'h341 : rdata = mepc;
      12'h342 : rdata = mcause;
      12'h344 : rdata = mip; 
      endcase

   end
end
// CSR write operation

always_ff @( negedge clk, posedge reset ) begin : write_operation
   if (reset) begin
      mip     <= '0;
      mcause  <= '0;
      mepc    <= '0;
      mtvec   <= '0;
      mie     <= '0;
      mstatus <= '0;
   end
   if (reg_write) begin
      case(addr)
      12'h300 :  mstatus <= wdata;
      12'h304 :  mie     <= wdata;
      12'h305 :  mtvec   <= wdata;
      12'h341 :  mepc    <= wdata;
      12'h342 :  mcause  <= wdata;
      12'h344 :  mip     <= wdata; 
      endcase     
   end
   if (MTI) begin
      mip[7]      <= 1; 
      mcause      <= 2;
      mepc        <= pc;  
   end
   if (EI) begin
      mip[11]      <= 1;
      mcause       <= 3;
      mepc         <= pc; 
   end
end

endmodule