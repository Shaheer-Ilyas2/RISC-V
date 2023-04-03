`timescale 1ns/1ps

module datapath(
   input  logic  clk,
   input  logic  reset,
   input  logic  MTI,
   input  logic  EI
   );

   logic [31:0]  pc_in, mux2x1_out_A, instr, raddr1, raddr2, wdata, rdata1, rdata2;
   logic [31:0]  address, pc_next, imm_result, mux2x1_out, alu_out, datamem_out, mux3x1in;
   logic         reg_write, mem_write, rd_en, Imm_sel, sel_A, br_taken, cs;
   logic [3:0]   alucontrol;
   logic [3:0]   mask;
   logic [2:0]   imm_control;
   logic [1:0]   wb_sel;
   logic [31:0]  addr_out, data_store, rdata;
   // wires for pipelining
   logic [31:0]  pc_F, instr_F, pc_E, alu_o_E, rdata2_E, instr_E;
   logic         mem_write_E, reg_write_E, rd_en_E,  cs_E;
   logic [1:0]   wb_sel_E;
   // wires for forwarding, flushing and stalling
   logic        forA, forB, stall, stall_MW, flush;
   logic [31:0] mxAfu, mxBfu;
   // wires for csr
   logic [31:0] csr_rdata, csr_wdata_E, epc, pc_int;
   logic [11:0] csr_addr, csr_addr_E;
   logic        csr_reg_rd, csr_reg_rd_E, csr_reg_wr, csr_reg_wr_E, exception;
   logic        interrupt, flush_mret;
   // uart 
   logic        cs_uart, done, busy, cs_dm;
   logic [7:0]  uart_out;
   
   adder #(.data(32)) i_adder(
      .in0(address),
      .in1(4),
      .out(pc_next)
   );
   mux_2x1 mxpc(
      .in1(pc_next),
      .in2(alu_out),
      .sel(br_taken),
      .out(pc_in)
   );  


   PC #(.data(32) ) p_c(
      .clk(clk),
      .reset(reset),
      .pc_next(pc_int),
      .pc(address),
      .stall(stall)
   );

   ins_mem insmem(
      .address(address),
      .instr(instr)
   );
   
   reg_file  #( .length(32), .size(32)) registerfile(
      .raddr1(instr_F[19:15]),
      .raddr2(instr_F[24:20]),
      .waddr(instr_E[11:7]),
      .clk(clk),
      .reset(reset),
      .reg_write(reg_write_E),
      .wdata(wdata),
      .rdata1(rdata1),
      .rdata2(rdata2)
   );

   ALU_decoder alu_dec(
      .funct3(instr_F[14:12]),
      .funct7(instr_F[31:25]),
      .opcode(instr_F[6:0]),
      .ALUcontrol(alucontrol),
      .reg_write(reg_write),
      .mem_write(mem_write),
      .Imm_sel(Imm_sel),
      .wb_sel(wb_sel),
      .rd_en(rd_en),
      .imm_control(imm_control),
      .sel_A(sel_A),
      .cs(cs),
      .csr_reg_rd(csr_reg_rd),
      .csr_reg_wr(csr_reg_wr),
      .interrupt(interrupt),
      .flush_mret(flush_mret),
      .cs_uart(cs_uart),
      .cs_dm(cs_dm)
   );

   immediate_gen imm_gen(
      .instr(instr_F),
      .imm_control(imm_control),
      .Imm_out(imm_result),
      .imm_csr(csr_addr)
   );
   branch_cond br_cond(
      .rs1(mxAfu),
      .rs2(mxBfu),
      .br_type(instr_F[14:12]),
      .br_taken(br_taken),
      .opcode(instr_F[6:0])
   );

   mux_2x1  mx(
      .in1(mxBfu),
      .in2(imm_result),
      .sel(Imm_sel),
      .out(mux2x1_out)
   );

   LS_unit ls_unit(
      .ALU_out(alu_o_E),
      .data_loaded(datamem_out),
      .rdata2(rdata2_E),
      .funct3(instr_E[14:12]),
      .mask(mask),
      .data_store(data_store),
      .rdata(rdata),
      .addr_out(addr_out),
      .instr_E(instr_E)
   );
assign cs_dm   = addr_out[10];
assign cs_uart = addr_out[11];
//assign cs_dm   = 1'b1;
//assign cs_uart = 1'b1;
   Uart8Transmitter uart(
      .clk(clk),
      .en(1'b1),
      .start(cs_uart),
      .in(data_store[7:0]),
      .out(uart_out),
      .done(done),
      .busy(busy)
   );

   data_memory  #(.size(32), .length(50))  dm(
      .clk(clk),
      .reset(reset),
      .addr(addr_out),
      .wdata(data_store),
      .cs(cs_dm),  //cs_E
      .mem_write(mem_write_E),
      .rd_en(rd_en_E),
      .rdata(datamem_out),
      .mask(mask)
);
   adder #(.data(32)) muxadder(
      .in0(pc_E),
      .in1(4),
      .out(mux3x1in)
   );
 
   mux_4x1 mux4(
      .in1(alu_o_E),
      .in2(rdata),
      .in3(mux3x1in),
      .in4(csr_rdata),
      .sel(wb_sel_E),
      .out(wdata)
);

   mux_2x1 mxA(
      .in1(pc_F),
      .in2(mxAfu),
      .sel(sel_A),
      .out(mux2x1_out_A)
   );

   alu arith_lu (
      .A(mux2x1_out_A),
      .B(mux2x1_out),
      .ALUcontrol(alucontrol),
      .out(alu_out)
   );
// aditional datapath for pipelining

   stage1_reg st1_reg(
      .clk(clk),
      .reset(reset),
      .pc(address),
      .instr(instr),
      .flush(flush),
      .pc_F(pc_F),
      .instr_F(instr_F),
      .stall(stall)
   );

   stage2_reg st2_reg(
      .clk(clk),
      .reset(reset),
      .pc(pc_F),
      .rdata2(rdata2),
      .alu_o(alu_out),
      .instr_F(instr_F),
      .pc_E(pc_E),
      .rdata2_E(rdata2_E),
      .alu_o_E(alu_o_E),
      .instr_E(instr_E),
      .stall_MW(1'b0),
      .csr_addr(csr_addr),
      .csr_wdata(mxAfu),
      .csr_addr_E(csr_addr_E),
      .csr_wdata_E(csr_wdata_E)
   );

   control_stage2 cn_st2(
      .clk(clk),
      .reset(reset),
      .reg_write(reg_write),
      .mem_write(mem_write),
      .rd_en(rd_en),
      .wb_sel(wb_sel),
      .cs(cs),
      .reg_write_E(reg_write_E),
      .mem_write_E(mem_write_E),
      .rd_en_E(rd_en_E),
      .wb_sel_E(wb_sel_E),
      .cs_E(cs_E),
      .stall_MW(stall_MW),
      .csr_reg_wr(csr_reg_wr),
      .csr_reg_rd(csr_reg_rd),
      .csr_reg_rd_E(csr_reg_rd_E),
      .csr_reg_wr_E(csr_reg_wr_E)
   );
// forwarding and stalling
   forwarding_unit fu(
      .instr_F(instr_F),
      .instr_E(instr_E),
      .reg_write_E(reg_write_E),
      .forA(forA),
      .forB(forB),
      .stall(stall),
      .stall_MW(stall_MW),
      .br_taken(br_taken),
      .flush(flush),
     .flush_mret(flush_mret)
   );

   mux_2x1 mxfuA(
      .in1(rdata1),
      .in2(alu_o_E),
      .sel(forA),
      .out(mxAfu)
   );
   mux_2x1 mxfuB(
      .in1(rdata2),
      .in2(alu_o_E),
      .sel(forB),
      .out(mxBfu)
   );

   // csr implementation and interrupt handler
   CSR_reg csr_reg(
      .clk(clk),
      .reset(reset),
      .pc(pc_E),
      .addr(csr_addr_E),
      .wdata(csr_wdata_E),
      .reg_write(csr_reg_wr_E),
      .reg_rd(csr_reg_rd_E),
      .rdata(csr_rdata),
      .epc(epc),
      .interrupt(interrupt),
      .exception(exception),
      .MTI(MTI),
      .EI(EI)
   );

   mux_2x1 mx_int(
      .in1(pc_in),
      .in2(epc),
      .sel(exception),
      .out(pc_int)
   );



endmodule

