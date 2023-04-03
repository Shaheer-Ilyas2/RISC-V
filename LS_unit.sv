

module LS_unit(
	input  logic [31:0] ALU_out,
	input  logic [31:0] data_loaded,
	input  logic [31:0] rdata2,
	input  logic [2:0]  funct3,
	input  logic [31:0] instr_E,
	output logic [3:0]  mask,
	output logic [31:0] data_store,
	output logic [31:0] rdata,
	output logic [31:0] addr_out
);


	logic [7:0]  rdata_byte;
	logic [15:0] rdata_half_word;
	logic [31:0] rdata_word;
	assign addr_out = ALU_out;

	always_comb
	begin
		case (funct3)
		    3'b000,3'b100: begin  // LB & LBU
						   case(ALU_out[1:0])
								2'b00 : rdata_byte = data_loaded[7:0];
								2'b01 : rdata_byte = data_loaded[15:8];
								2'b10 : rdata_byte = data_loaded[23:16];
								2'b11 : rdata_byte = data_loaded[31:24];
						   endcase
						   end	
			3'b001,3'b101: begin  // HW & HWU
						   case(ALU_out[1])
								1'b0 : rdata_half_word = data_loaded[15:0];
								1'b1 : rdata_half_word = data_loaded[31:16];
						   endcase
						   end
			3'b010 : rdata_word = data_loaded; //LW	
        endcase
	end
	
	always_comb
	begin 
		if (instr_E[6:0] == 7'b0000011) begin
		case(funct3)
			3'b000 : rdata = {{24{rdata_byte[7]}},       rdata_byte};
			3'b100 : rdata = {24'b0,                     rdata_byte};
			3'b001 : rdata = {{16{rdata_half_word[15]}}, rdata_half_word};
			3'b101 : rdata = {16'b0,                     rdata_half_word};
			3'b010 : rdata = {                           rdata_word};
		endcase
		end
	end
	
	always_comb
	begin
		case (funct3)
		    3'b000 : begin // SB
					 case(ALU_out[1:0])
						2'b00 : begin
									data_store[7:0] = rdata2[7:0];
									mask = 4'b0001;
								end
						2'b01 : begin
									data_store[15:8] = rdata2[15:8];
									mask = 4'b0010;
								end
						2'b10 : begin
									data_store[23:16] = rdata2[23:16];
									mask = 4'b0100;
								end
						2'b11 : begin
									data_store[31:24] = rdata2[31:24];
									mask = 4'b1000;
								end
					 endcase
					 end
			3'b001 : begin // Store half word
					 case(ALU_out[1])
						1'b0 : begin
					    			data_store[15:0] = rdata2[15:0];
									mask = 4'b0011;
							   end
						1'b1 : begin
									data_store[31:16] = rdata2[31:16];
									mask = 4'b1100;
							   end
					 endcase
					 end
			3'b010 : begin  //SW
						data_store = rdata2;
						mask = 4'b1111;
					 end
	    endcase
	end


endmodule