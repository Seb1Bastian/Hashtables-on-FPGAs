module raw_mulitplexer_cam #(parameter DATA_WIDTH = 32,
                   parameter DATA_LINES = 4)(
    input   logic [DATA_LINES-1:0][DATA_WIDTH-1:0] data_in,
    input   logic [DATA_LINES-1:0] sel,

    output  wire [DATA_WIDTH-1:0] data_out
); 
//--------------Internal variables----------------

wire [DATA_LINES-1:0][DATA_WIDTH-1:0] data_and;
wire [DATA_WIDTH-1:0][DATA_LINES-1:0] data_input_or;


//--------------Code Starts Here------------------ 
genvar i, j;
generate
    for (i = 0; i < DATA_LINES; i = i + 1) begin : and_gen
        assign data_and[i] = data_in[i] & {DATA_WIDTH{sel[i]}};
    end
endgenerate

generate
    for (i = 0; i < DATA_LINES; i = i + 1) begin : outer_loop
        for (j = 0; j < DATA_WIDTH; j = j + 1) begin : inner_loop
            assign data_input_or[j][i] = data_and[i][j];
        end
    end
endgenerate

generate
    for (i = 0; i < DATA_WIDTH; i = i + 1) begin : column_or_gen
        assign data_out[i] = | data_input_or[i];
    end
endgenerate


endmodule // End of Module ram_sp_sr_sw