module forward_position_updater #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2,
    parameter FORWARDED_CLOCK_CYCLES = 2,
    parameter MAX_HASH_ADR_WIDTH = 2,
)(
    input logic clk,
    input logic reset,
    input logic clk_en,
    input logic [HASH_ADR_WIDTH-1:0] new_hash_adr_i [NUMBER_OF_TABLES-1:0],
    input logic [DATA_WIDTH-1:0] new_data_i,
    input logic [KEY_WIDTH-1:0] new_key_i,
    input logic new_valid_i,

    input logic [HASH_ADR_WIDTH-1:0] forward_hash_adr_i,
    input logic [DATA_WIDTH-1:0] forward_data_i,
    input logic [KEY_WIDTH-1:0] forward_key_i,
    input logic forward_updated_mem_i,
    input logic forward_valid_i,

    output wire [KEY_WIDTH-1:0] correct_key,
    output wire [DATA_WIDTH-1:0] correct_data,
    output wire correct_is_valid,
);


genvar i;

    
endmodule