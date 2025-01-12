module raw_mulitplexer_buckets #(parameter DATA_LINES  = 4,
                                 parameter BUCKET_SIZE = 1,
                                 parameter BUCKET_WITDH = 16)(
    input   logic [BUCKET_SIZE-1:0][BUCKET_WITDH-1:0]  data_in [DATA_LINES-1:0],
    input   logic [DATA_LINES-1:0][BUCKET_SIZE-1:0] sel,

    output  wire [BUCKET_WITDH-1:0] data_out
); 
//--------------Internal variables----------------

wire [DATA_LINES-1:0][BUCKET_SIZE-1:0][BUCKET_WITDH-1:0] data_and;
wire [DATA_LINES-1:0][BUCKET_WITDH-1:0][BUCKET_SIZE-1:0] data_and_2;
wire [BUCKET_WITDH-1:0][DATA_LINES-1:0] data_input_or;


//--------------Code Starts Here------------------ 
genvar i, j, l;
generate
    for (i = 0; i < DATA_LINES; i = i + 1) begin : and_gen
        for (j = 0; j < BUCKET_SIZE ; j++ ) begin
            assign data_and[i][j] = data_in[i][j] & {BUCKET_WITDH{sel[i][j]}};
        end
        
    end
endgenerate

generate
    for (i = 0; i < DATA_LINES; i = i + 1) begin : and_gen_transpos
        for (j = 0; j < BUCKET_SIZE ; j++ ) begin
            for (l = 0; l < BUCKET_WITDH ; l++ ) begin
                assign data_and_2[i][l][j] = data_and[i][j][l];
            end
        end
    end
endgenerate

generate
    for (i = 0; i < DATA_LINES; i = i + 1) begin : outer_loop
        for (j = 0; j < BUCKET_WITDH; j = j + 1) begin : inner_loop
            assign data_input_or[j][i] = |data_and_2[i][j];
        end
    end
endgenerate

generate
    for (i = 0; i < BUCKET_WITDH; i = i + 1) begin : column_or_gen
        assign data_out[i] = | data_input_or[i];
    end
endgenerate


endmodule // End of Module ram_sp_sr_sw