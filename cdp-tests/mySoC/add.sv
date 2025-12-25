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
// if {choose_add_sub == 1} addd_1 - add_2 else  add_1 + add_2

assign result = add_1 + (choose_add_sub ? add_2_inv : add_2) + (choose_add_sub ? 1'b1 : 1'b0);

endmodule

