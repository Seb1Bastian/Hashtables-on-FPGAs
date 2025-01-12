module forwarder_unit #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2,
    parameter NUMBER_OF_TABLES = 4,
    parameter BUCKET_SIZE = 1,
    parameter MAX_HASH_ADR_WIDTH = 2,
    parameter integer HASH_TABLE_ADR_WIDTH[NUMBER_OF_TABLES-1:0] = {2,2}
)(
    input logic clk,
    input logic reset,
    input logic clk_en,
    input logic [MAX_HASH_ADR_WIDTH-1:0]                    new_hash_adr_i          [NUMBER_OF_TABLES-1:0],
    input logic [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0]  new_content_i           [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0]                           new_valid_i             [NUMBER_OF_TABLES-1:0],

    input logic [MAX_HASH_ADR_WIDTH-1:0]                    forward_hash_adr_i      [NUMBER_OF_TABLES-1:0],
    input logic [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0]  forward_content_i       [NUMBER_OF_TABLES-1:0],
    input logic                                             forward_updated_mem_i   [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0]                           forward_valid_i         [NUMBER_OF_TABLES-1:0],

    output wire [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0]  correct_content_o       [NUMBER_OF_TABLES-1:0],
    output wire [BUCKET_SIZE-1:0]                           correct_is_valid_o      [NUMBER_OF_TABLES-1:0]
);


wire [MAX_HASH_ADR_WIDTH-1:0]                   forward_hash_adr    [NUMBER_OF_TABLES-1:0];
wire [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0] forward_content     [NUMBER_OF_TABLES-1:0];
wire                                            forward_updated_mem [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                          forward_valid       [NUMBER_OF_TABLES-1:0];


wire                            inbetween_valid_corrected           [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH-1:0]            inbetween_key_corrected             [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]           inbetween_data_corrected            [NUMBER_OF_TABLES-1:0];
wire [MAX_HASH_ADR_WIDTH-1:0]   inbetween_shift_hash_adr_corrected  [NUMBER_OF_TABLES-2:0];
wire                            inbetween_shift_valid_corrected     [NUMBER_OF_TABLES-2:0];


genvar i,j;
generate
    for (j = 0; j < NUMBER_OF_TABLES ; j = j+1 ) begin
        siso_register #(
            .DATA_WIDTH(MAX_HASH_ADR_WIDTH), .DELAY(1))
        forward_hash_adr_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_hash_adr_i[j]),
            .data_o(forward_hash_adr[j]));

        siso_register #(
            .DATA_WIDTH((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE), .DELAY(1))
        forward_data_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_content_i[j]),
            .data_o(forward_content[j]));

        siso_register #(
            .DATA_WIDTH(1), .DELAY(1))
        forward_updated_mem_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_updated_mem_i[j]),
            .data_o(forward_updated_mem[j]));

        siso_register #(
            .DATA_WIDTH(BUCKET_SIZE), .DELAY(1))
        forward_valid_reg(
            .clk(clk), .reset(reset), .write_en(clk_en), 
            .data_i(forward_valid_i[j]),
            .data_o(forward_valid[j]));
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        assign correct_content_o[i]    = (forward_hash_adr[i] == new_hash_adr_i[i] && forward_updated_mem[i] == 1'b1) ? forward_content[i] : new_content_i[i];
        assign correct_is_valid_o[i]   = (forward_hash_adr[i] == new_hash_adr_i[i] && forward_updated_mem[i] == 1'b1) ? forward_valid[i]   : new_valid_i[i];
    end
endgenerate    
endmodule