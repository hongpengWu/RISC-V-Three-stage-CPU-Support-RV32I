module add
#(
    parameter BW=4
)
(
   input choose_add_sub,
   input [BW-1:0]add_1,
   input [BW-1:0]add_2,
   input [BW-1:0]add_2_inv,
   output [BW-1:0]result
);

logic [BW-1:0]add_3;

assign add_3 = (choose_add_sub == 1'b0)? add_2:(add_2_inv + 1'b1);

assign result = add_1 + add_3;










endmodule


