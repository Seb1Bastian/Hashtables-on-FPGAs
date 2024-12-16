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
    input logic new_shift_valid_i

    input logic [HASH_ADR_WIDTH-1:0] forward_hash_adr_i,
    input logic [DATA_WIDTH-1:0] forward_data_i,
    input logic [KEY_WIDTH-1:0] forward_key_i,
    input logic forward_updated_mem_i,
    input logic forward_valid_i,
    input logic [SHIFT_HASH_ADR_WIDTH-1:0] forward_shift_hash_adr_i,
    input logic forward_shift_valid_i,

    output wire [KEY_WIDTH-1:0] correct_key,
    output wire [DATA_WIDTH-1:0] correct_data,
    output wire correct_is_valid,
    output wire [SHIFT_HASH_ADR_WIDTH-1:0] correct_shift_hash_adr,
    output wire correct_shift_valid
);

logic [HASH_ADR_WIDTH-1:0] forward_hash_adr;
logic [DATA_WIDTH-1:0] forward_data;
logic [KEY_WIDTH-1:0] forward_key;
logic forward_updated_mem;
logic forward_valid;
logic [SHIFT_HASH_ADR_WIDTH-1:0] forward_shift_hash_adr;
logic forward_shift_valid;

genvar i;
always @(posedge clk) begin
    if (reset == 1) begin
        forward_hash_adr <= '{default: '0};
        forward_data <= '{default: '0};
        forward_key <= '{default: '0};
        forward_updated_mem <= '{default: '0};
        forward_valid <= '{default: '0};
        forward_shift_hash_adr <= '{default: '0};
        forward_shift_valid <= '{default: '0};
    end else begin
        forward_hash_adr = forward_hash_adr_i;
        forward_data = forward_data;
        forward_key = forward_key;
        forward_updated_mem = forward_updated_mem;
        forward_valid = forward_valid;
        forward_shift_hash_adr = forward_shift_hash_adr;
        forward_shift_valid = forward_shift_valid;
    end
end

assign same_hash_adr = (hash_regs == new_hash_adr_i) ? 1'b1 : 1'b0;
assign correct_key = (same_hash_adr == 1'b1 && forward_updated_mem == 1'b1) ? forward_key : new_key_i;
assign correct_data = (same_hash_adr == 1'b1 && forward_updated_mem == 1'b1) ? forward_data : new_data_i;
assign correct_is_valid = (same_hash_adr == 1'b1 && forward_updated_mem == 1'b1) ? forward_valid : new_valid_i;
assign correct_sh = (same_hash_adr == 1'b1 && forward_updated_mem == 1'b1) ? forward_key : new_key_i;
assign correct_shift_hash_adr = (same_hash_adr == 1'b1 && forward_updated_mem == 1'b1) ? forward_shift_hash_adr : new_shift_adr_i;
assign correct_shift_valid = (same_hash_adr == 1'b1 && forward_updated_mem == 1'b1) ? forward_shift_valid : new_shift_valid_i;
    
endmodule