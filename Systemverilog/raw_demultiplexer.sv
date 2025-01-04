module raw_demulitplexer #(parameter DATA_WIDTH = 32,
                           parameter DATA_LINES = 4)(
    input   logic [DATA_WIDTH-1:0] data_in,
    input   logic [DATA_LINES-1:0] sel,

    output  wire [DATA_LINES-1:0][DATA_WIDTH-1:0] data_out
); 
//--------------Internal variables----------------

logic [DATA_LINES-1:0][DATA_WIDTH-1:0] data_and;


//--------------Code Starts Here------------------ 
genvar i, j;
generate
    for (i = 0; i < DATA_LINES; i = i + 1) begin : and_gen
        for(j = 0; j < DATA_WIDTH; j = j + 1) begin : and_gen2
            assign data_out[i][j] = data_in[j] & sel[i];
        end
    end
endgenerate


endmodule