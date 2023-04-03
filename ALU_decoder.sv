module ALU_decoder(
   input  logic [2:0] funct3,
   input  logic [6:0] funct7,
   input  logic [6:0] opcode,
   output logic [3:0] ALUcontrol,
   output logic       reg_write, mem_write, Imm_sel, rd_en, sel_A, cs, csr_reg_rd, 
   output logic       csr_reg_wr, interrupt, flush_mret, cs_dm, cs_uart, 
   output logic [1:0] wb_sel,
   output logic [2:0] imm_control
   );

always_comb begin
  interrupt ='{default:1'b0};
  if(opcode == 7'b0110011) begin
      reg_write = 1;
      sel_A       = 1;
      sel_A       = 1;
      Imm_sel     = 0;
      wb_sel      = 0;
      interrupt = 0;
      flush_mret  = 0;
      case(funct3)
         3'b000 : begin if (funct7 == 7'b0000000) begin
                           ALUcontrol = 0; //add
                        end else begin 
                           ALUcontrol = 1;  // subtraction
                        end
                  end

         3'b001 : ALUcontrol = 2; //SLL 
         3'b010 : ALUcontrol = 3; // SLT
         3'b111 : ALUcontrol = 4; // AND
         3'b110 : ALUcontrol = 5; // OR
         3'b100 : ALUcontrol = 6; //XOR
         3'b101 : begin if (funct7 == 7'b0000000) begin
                           ALUcontrol = 7; //srl
                        end else begin 
                           ALUcontrol = 8;  // sra
                        end
                  end 
         3'b011 : ALUcontrol = 9; // sltu
      endcase
   end
   else if (opcode == 7'b0010011 ) begin // I type (not load)
      reg_write = 1;
      Imm_sel   = 1;
      wb_sel    = 0;
      sel_A     = 1;
      Imm_sel   = 1;
      wb_sel    = 0;
      interrupt = 0;
      flush_mret  = 0;
      case(funct3) 
         3'b000 : begin //addi
                     ALUcontrol = 0;
                     imm_control = 0;
         end
         3'b010 : begin //slti
                     ALUcontrol = 3;
                     imm_control = 0;
         end 
         3'b011 : begin //sltiu
                     ALUcontrol = 9;
                     imm_control = 0;
         end
         3'b100 : begin //xori
                     ALUcontrol = 6;
                     imm_control = 0;
         end
         3'b110 : begin //ori
                     ALUcontrol = 5;
                     imm_control = 0;
         end
         3'b111 : begin //andi
                     ALUcontrol = 4;
                     imm_control = 0;
         end
         3'b001 : begin  //slli
                     ALUcontrol = 2;
                     imm_control = 0;
         end
         3'b101 : begin if (funct7 == 7'b0000000) begin
                  ALUcontrol = 7; //srli
                  imm_control = 0;
               end else begin 
                  ALUcontrol = 8;
                  imm_control = 0;  // srai
               end
         end
      
         endcase
      end

   else if(opcode == 7'b0000011)begin  // I type (load)
         reg_write = 1;
         Imm_sel   = 1;
         rd_en     = 1;
         wb_sel    = 1;
         mem_write = 0;
         imm_control = 0;
         ALUcontrol  = 0;
         sel_A       = 1;
         cs          = 0;
         interrupt = 0;
         flush_mret  = 0;
   end
   else if (opcode == 7'b0100011 ) begin   // s type
         reg_write   = 0;
         Imm_sel     = 1;
         imm_control = 1;
         ALUcontrol  = 0;
         mem_write   = 1;
         wb_sel      = 0;
         sel_A       = 1;
         cs          = 0; 
         interrupt = 0;
         flush_mret  = 0;
         //cs_dm       = 1;
         cs_uart     = 1; 
      end
   else if (opcode == 7'b0110111) begin  // LUI type
         reg_write   = 1;
         Imm_sel     = 1;
         imm_control = 2;
         ALUcontrol  = 10;
         wb_sel      = 0;
         sel_A       = 1;
         interrupt = 0;
         flush_mret  = 0;
      end   

   else if (opcode == 7'b0010111) begin // LUIPC
         reg_write   = 1;
         Imm_sel     = 1;
         imm_control = 2;
         ALUcontrol  = 0;
         wb_sel      = 0;
         sel_A       = 0;
         interrupt = 0;
         flush_mret  = 0;
      end
   else if (opcode == 7'b1100011) begin //Branch
         reg_write   = 0;
         Imm_sel     = 1;
         imm_control = 3;
         ALUcontrol  = 0;
         sel_A       = 0;
         interrupt = 0;
         flush_mret  = 0;
      end
   else if (opcode == 7'b1101111) begin // JAL
         reg_write   = 1;
         Imm_sel     = 1;
         imm_control = 4;
         ALUcontrol  = 0;
         sel_A       = 0;
         wb_sel      = 2;
         interrupt = 0;
         flush_mret  = 0;
      end  
   else if (opcode == 7'b1110011) begin //csr and mret
         if (funct3 == 3'b001) begin
            imm_control = 5;
            wb_sel      = 3;
            csr_reg_wr  = 1;
            csr_reg_rd  = 1;
            interrupt   = 0;
           flush_mret  =  0;
         end 
         if (funct3 == 3'b000) begin
            interrupt   = 1;
            flush_mret  = 1;
         end
   end


end
endmodule
