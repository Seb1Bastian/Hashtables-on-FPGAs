module forward_position_updater #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2,
    parameter HASH_ADR_WIDTH = 2,
    parameter SHIFT_HASH_ADR_WIDTH = 2
)(
    input logic clk,
    input logic reset,
    input logic clk_en,
    input logic [HASH_ADR_WIDTH-1:0] new_hash_adr_i,
    input logic [DATA_WIDTH-1:0] new_data_i,
    input logic [KEY_WIDTH-1:0] new_key_i,
    input logic [SHIFT_HASH_ADR_WIDTH-1:0] new_shift_adr_i,
    input logic new_valid_i,
    input logic new_shift_valid_i,

    input logic [HASH_ADR_WIDTH-1:0] forward_hash_adr_i,
    input logic [DATA_WIDTH-1:0] forward_data_i,
    input logic [KEY_WIDTH-1:0] forward_key_i,
    input logic forward_updated_mem_i,
    input logic forward_valid_i,
    input logic [SHIFT_HASH_ADR_WIDTH-1:0] forward_shift_hash_adr_i,
    input logic forward_shift_valid_i,
    input logic [SHIFT_HASH_ADR_WIDTH-1:0] forward_next_mem_hash_adr_i,
    input logic forward_next_mem_updated_i,
    input logic forward_next_mem_valid_i,

    output wire [KEY_WIDTH-1:0] correct_key,
    output wire [DATA_WIDTH-1:0] correct_data,
    output wire correct_is_valid,
    output wire [SHIFT_HASH_ADR_WIDTH-1:0] correct_shift_hash_adr,
    output wire correct_shift_valid
);

wire same_hash_adr_and_update;
wire first_check_shift_adr;
wire first_check_shift_valid;
wire shift_same_hash_adr_and_update;


assign same_hash_adr_and_update = (forward_hash_adr_i == new_hash_adr_i && forward_updated_mem_i == 1'b1) ? 1'b1 : 1'b0;
assign correct_key = (same_hash_adr_and_update == 1'b1) ? forward_key_i : new_key_i;
assign correct_data = (same_hash_adr_and_update == 1'b1) ? forward_data_i : new_data_i;
assign correct_is_valid = (same_hash_adr_and_update == 1'b1) ? forward_valid_i : new_valid_i;
assign first_check_shift_adr = (same_hash_adr_and_update == 1'b1) ? forward_shift_hash_adr_i : new_shift_adr_i;
assign first_check_shift_valid = (same_hash_adr_and_update == 1'b1) ? forward_shift_valid_i : new_shift_valid_i;

assign shift_same_hash_adr_and_update = (first_check_shift_adr == forward_next_mem_hash_adr_i && forward_next_mem_updated_i == 1'b1) ? 1'b1 : 1'b0;
assign correct_shift_hash_adr = first_check_shift_adr;
assign correct_shift_valid = (shift_same_hash_adr_and_update == 1'b1) ? forward_next_mem_valid_i : first_check_shift_valid;
    
endmodule