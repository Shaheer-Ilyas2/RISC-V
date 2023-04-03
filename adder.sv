
module adder #(
   parameter data = 32
)(
   input  logic [data-1:0] in0,
   input  logic [data-1:0] in1,

   output logic [data-1:0] out
);


assign out = in0 + in1;

endmodule

