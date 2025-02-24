module matrix_wrapper #(parameter NUMBER_OF_TABLES = 4,
                        parameter HASH_ADR_WIDTH   = 5,
                        paramter KEY_WIDTH = 2)(
    output  wire  [NUMBER_OF_TABLES*HASH_ADR_WIDTH*KEY_WIDTH-1:0]  matrixes_o
); 


matrix_generator #(
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .HASH_ADR_WIDTH(HASH_ADR_WIDTH),
    .KEY_WIDTH(KEY_WIDTH)
) generator (
    .matrixes_o(matrixes_o)
)

endmodule