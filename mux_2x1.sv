`timescale 1ns/1ps
module mux_2x1(
        input  logic  [31:0] in1, in2,
        input  logic              sel,
        output logic  [31:0]      out
    );
    
    
    always_comb begin
        if (sel == 1'b0) out = in1;
        if (sel == 1'b1) out = in2;
        if (sel == 1'bx) out = in1;
    end
    
endmodule