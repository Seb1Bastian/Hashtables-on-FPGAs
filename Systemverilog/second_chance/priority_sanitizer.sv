module priority_sanitizer #(parameter DATA_WIDTH = 32)(
    input   wire [DATA_WIDTH-1:0]  data_in,
    output  wire [DATA_WIDTH-1:0]  data_out
); 
//--------------Internal variables---------------- 
genvar i;
generate
    for (i = 0; i < DATA_WIDTH; i = i + 1 ) begin : gen_block
        if (i == 0) begin
            assign data_out[i] = data_in[i];
        end else begin
            assign data_out[i] = data_in[i] & (!(|data_in[i-1:0]));
        end
    end
endgenerate
endmodule
