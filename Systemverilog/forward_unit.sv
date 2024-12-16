module forward_position_updater #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2,
    parameter HASH_ADR_WIDTH = 2,
    parameter SHIFT_HASH_ADR_WIDTH = 2,
    parameter NUMBER_OF_TABLES = 4,
    parameter CLK_CYCLE_FORWARD = 2;
)(
    input logic clk,
    input logic reset,
    input logic clk_en,
    input logic [HASH_ADR_WIDTH-1:0] new_hash_adr_i [NUMBER_OF_TABLES-1:0],
    input logic [DATA_WIDTH-1:0] new_data_i [NUMBER_OF_TABLES-1:0],
    input logic [KEY_WIDTH-1:0] new_key_i [NUMBER_OF_TABLES-1:0],
    input logic [SHIFT_HASH_ADR_WIDTH-1:0] new_shift_adr_i [NUMBER_OF_TABLES-2:0],
    input logic new_valid_i [NUMBER_OF_TABLES-1:0],
    input logic new_shift_valid_i [NUMBER_OF_TABLES-2:0],

    input logic [HASH_ADR_WIDTH-1:0] forward_hash_adr_i [NUMBER_OF_TABLES-1:0],
    input logic [DATA_WIDTH-1:0] forward_data_i [NUMBER_OF_TABLES-1:0],
    input logic [KEY_WIDTH-1:0] forward_key_i [NUMBER_OF_TABLES-1:0],
    input logic forward_updated_mem_i [NUMBER_OF_TABLES-1:0],
    input logic forward_valid_i [NUMBER_OF_TABLES-1:0],
    input logic [SHIFT_HASH_ADR_WIDTH-1:0] forward_shift_hash_adr_i [NUMBER_OF_TABLES-2:0],
    input logic forward_shift_valid_i [NUMBER_OF_TABLES-2:0],

    output wire [KEY_WIDTH-1:0] correct_key [NUMBER_OF_TABLES-1:0],
    output wire [DATA_WIDTH-1:0] correct_data [NUMBER_OF_TABLES-1:0],
    output wire correct_is_valid [NUMBER_OF_TABLES-1:0],
    output wire [SHIFT_HASH_ADR_WIDTH-1:0] correct_shift_hash_adr [NUMBER_OF_TABLES-2:0],
    output wire correct_shift_valid [NUMBER_OF_TABLES-2:0]
);

genvar i,j;

generate
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1 ) begin
        forward_position_updater #(
            .DATA_WIDTH(DATA_WIDTH),
            .KEY_WIDTH(KEY_WIDTH),
            .HASH_ADR_WIDTH(HASH_ADR_WIDTH),
            .SHIFT_HASH_ADR_WIDTH(SHIFT_HASH_ADR_WIDTH)
        ) forwarder (
            .clk(clk),
            .reset(reset),
            .clk_en(clk_en),
            .new_hash_adr_i(new_hash_adr_i[i]),
            .new_data_i(new_data_i[i]),
            .new_key_i(new_key_i[i]),
            .new_shift_adr_i(new_shift_adr_i[i]),
            .new_valid_i(new_valid_i[i]),
            .new_shift_valid_i(new_shift_valid_i[i]),
        
            .forward_hash_adr_i(forward_hash_adr_i[i]),
            .forward_data_i(forward_data_i[i]),
            .forward_key_i(forward_key_i[i]),
            .forward_updated_mem_i(forward_updated_mem_i[i]),
            .forward_valid_i(forward_valid_i[i]),
            .forward_shift_hash_adr_i(forward_shift_hash_adr_i[i]),
            .forward_shift_valid_i(forward_shift_valid_i[i]),
        
            .correct_key(correct_key[i]),
            .correct_data(correct_data[i]),
            .correct_is_valid(correct_is_valid[i]),
            .correct_shift_hash_adr(correct_shift_hash_adr[i]),
            .correct_shift_valid(correct_shift_valid[i])
        )
        for (j = 1; j < CLK_CYCLE_FORWARD ; j = j + 1 ) begin
            
        end
    end
endgenerate


endmodule;