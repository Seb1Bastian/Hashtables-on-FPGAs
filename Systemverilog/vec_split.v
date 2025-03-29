module vec_split #(
    parameter VEC_LENGTH_0 = 1,
    parameter VEC_LENGTH_1 = 1
)
(
    input [VEC_LENGTH_1+VEC_LENGTH_0-1:0] data_i,

    output [VEC_LENGTH_0-1:0] vec0_o,
    output [VEC_LENGTH_1-1:0] vec1_o
);

assign vec0_o = data_i[VEC_LENGTH_0-1 : 0];
assign vec1_o = data_i[VEC_LENGTH_0 +: VEC_LENGTH_1];


endmodule