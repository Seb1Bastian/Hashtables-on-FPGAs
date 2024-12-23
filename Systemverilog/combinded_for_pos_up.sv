module whole_forward_updater #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2,
    parameter NUMBER_OF_TABLES = 4,
    parameter FORWARDED_CLOCK_CYCLES = 2,
    parameter MAX_HASH_ADR_WIDTH = 2,
    parameter integer HASH_TABLE_ADR_WIDTH[NUMBER_OF_TABLES-1:0] = {2,2}
)(
    input logic clk,
    input logic reset,
    input logic clk_en,
    input logic [MAX_HASH_ADR_WIDTH-1:0] new_hash_adr_i [NUMBER_OF_TABLES-1:0],
    input logic [DATA_WIDTH-1:0] new_data_i [NUMBER_OF_TABLES-1:0],
    input logic [KEY_WIDTH-1:0] new_key_i [NUMBER_OF_TABLES-1:0],
    input logic new_valid_i [NUMBER_OF_TABLES-1:0],
    input logic [MAX_HASH_ADR_WIDTH-1:0]new_shift_adr_i [NUMBER_OF_TABLES-1:0],
    input logic new_shift_valid_i [NUMBER_OF_TABLES-2:0],                           //von i nach i+1

    input logic [MAX_HASH_ADR_WIDTH-1:0] forward_hash_adr_i [NUMBER_OF_TABLES-1:0],
    input logic [DATA_WIDTH-1:0] forward_data_i [NUMBER_OF_TABLES-1:0],
    input logic [KEY_WIDTH-1:0] forward_key_i [NUMBER_OF_TABLES-1:0],
    input logic forward_updated_mem_i [NUMBER_OF_TABLES-1:0],
    input logic forward_valid_i [NUMBER_OF_TABLES-1:0],
    input logic [MAX_HASH_ADR_WIDTH-1:0] forward_shift_hash_adr_i [NUMBER_OF_TABLES-2:0],
    input logic forward_shift_valid_i [NUMBER_OF_TABLES-2:0],
//    input logic [MAX_HASH_ADR_WIDTH-1:0] forward_next_mem_hash_adr_i [NUMBER_OF_TABLES-2:0],
//    input logic forward_next_mem_updated_i [NUMBER_OF_TABLES-2:0],
//    input logic forward_next_mem_valid_i [NUMBER_OF_TABLES-2:0],

    output wire [KEY_WIDTH-1:0] correct_key_o [NUMBER_OF_TABLES-1:0],
    output wire [DATA_WIDTH-1:0] correct_data_o [NUMBER_OF_TABLES-1:0],
    output wire correct_is_valid_o [NUMBER_OF_TABLES-1:0],
    output wire [MAX_HASH_ADR_WIDTH-1:0] shift_adr_corrected_o [NUMBER_OF_TABLES-2:0],
    output wire shift_valid_corrected_o [NUMBER_OF_TABLES-2:0]
);


logic [MAX_HASH_ADR_WIDTH-1:0] forward_hash_adr [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
logic [DATA_WIDTH-1:0] forward_data [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
logic [KEY_WIDTH-1:0] forward_key [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
logic forward_updated_mem [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
logic forward_valid [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
logic [MAX_HASH_ADR_WIDTH-1:0] forward_shift_hash_adr [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];
logic forward_shift_valid [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];
logic [MAX_HASH_ADR_WIDTH-1:0] forward_next_mem_hash_adr [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];
logic forward_next_mem_updated [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];
logic forward_next_mem_valid [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];


wire inbetween_valid_corrected [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire inbetween_key_corrected [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire inbetween_data_corrected [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire inbetween_shift_hash_adr_corrected [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire inbetween_shift_valid_corrected [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];


genvar i,j;
always @(posedge clk) begin
    if (reset == 1) begin
        forward_hash_adr <= '{default: '0};
        forward_data <= '{default: '0};
        forward_key <= '{default: '0};
        forward_updated_mem <= '{default: '0};
        forward_valid <= '{default: '0};
        forward_shift_hash_adr <= '{default: '0};
        forward_shift_valid <= '{default: '0};
        forward_next_mem_hash_adr <= '{default: '0};
        forward_next_mem_updated <= '{default: '0};
        forward_next_mem_valid <= '{default: '0};
    end else begin
        forward_hash_adr[1] = forward_hash_adr_i;
        forward_data[1] = forward_data_i;
        forward_key[1] = forward_key_i;
        forward_updated_mem[1] = forward_updated_mem_i;
        forward_valid[1] = forward_valid_i;
        forward_shift_hash_adr[1] = forward_shift_hash_adr_i;
        forward_shift_valid[1] = forward_shift_valid_i;
//        forward_next_mem_hash_adr[1] = forward_next_mem_hash_adr_i;
//        forward_next_mem_updated[1] = forward_next_mem_updated_i;
//        forward_next_mem_valid[1] = forward_next_mem_valid_i;
        for (int i = 1; i < FORWARDED_CLOCK_CYCLES-1; i = i + 1) begin
            forward_hash_adr[i+1] = forward_hash_adr[i];
            forward_data[i+1] = forward_data[i];
            forward_key[i+1] = forward_key[i];
            forward_updated_mem[i+1] = forward_updated_mem[i];
            forward_valid[i+1] = forward_valid[i];
            forward_shift_hash_adr[i+1] = forward_shift_hash_adr[i];
            forward_shift_valid[i+1] = forward_shift_valid[i];
            forward_next_mem_hash_adr[i+1] = forward_next_mem_hash_adr[i];
            forward_next_mem_updated[i+1] = forward_next_mem_updated[i];
            forward_next_mem_valid[i+1] = forward_next_mem_valid[i];
        end
    end
end


generate
    for (i = 0; i < FORWARDED_CLOCK_CYCLES; i = i + 1 ) begin
        if (i == 0) begin
            for (j = 0; j < NUMBER_OF_TABLES; j = j + 1 ) begin
                if (j < NUMBER_OF_TABLES-1) begin
                    forward_position_updater #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .KEY_WIDTH(KEY_WIDTH),
                        .HASH_ADR_WIDTH(HASH_TABLE_ADR_WIDTH[j]),
                        .SHIFT_HASH_ADR_WIDTH(HASH_TABLE_ADR_WIDTH[j+1])
                    )oldest (
                        .clk(clk),
                        .reset(reset),
                        .clk_en(clk_en),
                        .new_hash_adr_i(new_hash_adr_i[j]),
                        .new_data_i(new_data_i[j]),
                        .new_key_i(new_key_i[j]),
                        .new_shift_adr_i(new_shift_adr_i[j]), //
                        .new_valid_i(new_valid_i[j]), 
                        .new_shift_valid_i(new_shift_valid_i[j]), //
                        .forward_hash_adr_i(forward_hash_adr_i[i][j]),
                        .forward_data_i(forward_data_i[i][j]),
                        .forward_key_i(forward_key_i[i][j]),
                        .forward_updated_mem_i(forward_updated_mem_i[i][j]),
                        .forward_valid_i(forward_valid_i[i][j]),
                        .forward_shift_hash_adr_i(forward_shift_hash_adr_i[i][j]), //
                        .forward_shift_valid_i(forward_shift_valid_i[i][j]),       //
                        .forward_next_mem_hash_adr_i(forward_hash_adr_i[i+1][j]), //
                        .forward_next_mem_updated_i(forward_updated_mem_i[i+1][j]),   //
                        .forward_next_mem_valid_i(forward_valid_i[i+1][j]),       //
                        .correct_key(inbetween_key_corrected[i][j]),
                        .correct_data(inbetween_data_corrected[i][j]),
                        .correct_is_valid(inbetween_valid_corrected[i][j]),
                        .correct_shift_hash_adr(inbetween_shift_hash_adr_corrected[i][j]),
                        .correct_shift_valid(inbetween_shift_valid_corrected[i][j])
                    );
                end else if (j == NUMBER_OF_TABLES-1) begin
                    forward_position_updater #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .KEY_WIDTH(KEY_WIDTH),
                        .HASH_ADR_WIDTH(HASH_TABLE_ADR_WIDTH[j]),
                        .SHIFT_HASH_ADR_WIDTH(1)
                    )oldest (
                        .clk(clk),
                        .reset(reset),
                        .clk_en(clk_en),
                        .new_hash_adr_i(new_hash_adr_i[j]),
                        .new_data_i(new_data_i[j]),
                        .new_key_i(new_key_i[j]),
                        .new_shift_adr_i(0), //
                        .new_valid_i(new_valid_i[j]), 
                        .new_shift_valid_i(0), //
                        .forward_hash_adr_i(forward_hash_adr_i[i][j]),
                        .forward_data_i(forward_data_i[i][j]),
                        .forward_key_i(forward_key_i[i][j]),
                        .forward_updated_mem_i(forward_updated_mem_i[i][j]),
                        .forward_valid_i(forward_valid_i[i][j]),
                        .forward_shift_hash_adr_i(0), //
                        .forward_shift_valid_i(0),       //
                        .forward_next_mem_hash_adr_i(0), //
                        .forward_next_mem_updated_i(0),   //
                        .forward_next_mem_valid_i(0),       //
                        .correct_key(inbetween_key_corrected[i][j]),
                        .correct_data(inbetween_data_corrected[i][j]),
                        .correct_is_valid(inbetween_valid_corrected[i][j]),
                        .correct_shift_hash_adr(),
                        .correct_shift_valid()
                    );
                end
                
            end
        end else begin
            for (j = 0; j < NUMBER_OF_TABLES; j = j + 1 ) begin
                if (j < NUMBER_OF_TABLES-1) begin
                    forward_position_updater #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .KEY_WIDTH(KEY_WIDTH),
                        .HASH_ADR_WIDTH(HASH_TABLE_ADR_WIDTH[j]),
                        .SHIFT_HASH_ADR_WIDTH(HASH_TABLE_ADR_WIDTH[j+1])
                    )newest (
                        .clk(clk),
                        .reset(reset),
                        .clk_en(clk_en),
                        .new_hash_adr_i(new_hash_adr_i[j]),
                        .new_data_i(inbetween_data_corrected[i-1][j]),
                        .new_key_i(inbetween_key_corrected[i-1][j]),
                        .new_shift_adr_i(inbetween_shift_hash_adr_corrected[i-1][j]), //
                        .new_valid_i(inbetween_valid_corrected[i-1][j]), 
                        .new_shift_valid_i(inbetween_shift_valid_corrected[i-1][j]), //
                        .forward_hash_adr_i(forward_hash_adr_i[i][j]),
                        .forward_data_i(forward_data_i[i][j]),
                        .forward_key_i(forward_key_i[i][j]),
                        .forward_updated_mem_i(forward_updated_mem_i[i][j]),
                        .forward_valid_i(forward_valid_i[i][j]),
                        .forward_shift_hash_adr_i(forward_shift_hash_adr_i[i][j]), //
                        .forward_shift_valid_i(forward_shift_valid_i[i][j]),       //
                        .forward_next_mem_hash_adr_i(forward_hash_adr_i[i+1][j]), //
                        .forward_next_mem_updated_i(forward_updated_mem_i[i+1][j]),   //
                        .forward_next_mem_valid_i(forward_valid_i[i+1][j]),       //
                        .correct_key(inbetween_key_corrected[i][j]),
                        .correct_data(inbetween_data_corrected[i][j]),
                        .correct_is_valid(inbetween_valid_corrected[i][j]),
                        .correct_shift_hash_adr(inbetween_shift_hash_adr_corrected[i][j]),
                        .correct_shift_valid(inbetween_shift_valid_corrected[i][j])
                    );
                end else if (j == NUMBER_OF_TABLES-1) begin
                    forward_position_updater #(
                        .DATA_WIDTH(DATA_WIDTH),
                        .KEY_WIDTH(KEY_WIDTH),
                        .HASH_ADR_WIDTH(HASH_TABLE_ADR_WIDTH[j]),
                        .SHIFT_HASH_ADR_WIDTH(1)
                    )newest (
                        .clk(clk),
                        .reset(reset),
                        .clk_en(clk_en),
                        .new_hash_adr_i(new_hash_adr_i[j]),
                        .new_data_i(inbetween_data_corrected[i-1][j]),
                        .new_key_i(inbetween_key_corrected[i-1][j]),
                        .new_shift_adr_i(0), //
                        .new_valid_i(inbetween_valid_corrected[i-1][j]), 
                        .new_shift_valid_i(0), //
                        .forward_hash_adr_i(forward_hash_adr_i[i][j]),
                        .forward_data_i(forward_data_i[i][j]),
                        .forward_key_i(forward_key_i[i][j]),
                        .forward_updated_mem_i(forward_updated_mem_i[i][j]),
                        .forward_valid_i(forward_valid_i[i][j]),
                        .forward_shift_hash_adr_i(0), //
                        .forward_shift_valid_i(0),       //
                        .forward_next_mem_hash_adr_i(0), //
                        .forward_next_mem_updated_i(0),   //
                        .forward_next_mem_valid_i(0),       //
                        .correct_key(inbetween_key_corrected[i][j]),
                        .correct_data(inbetween_data_corrected[i][j]),
                        .correct_is_valid(inbetween_valid_corrected[i][j]),
                        .correct_shift_hash_adr(),
                        .correct_shift_valid()
                    );
                end
                
            end
        end
    end
endgenerate


generate
    //for (j = 0; j < NUMBER_OF_TABLES-1 ; j = j + 1 ) begin
        assign correct_key_o = inbetween_key_corrected[FORWARDED_CLOCK_CYCLES-1];
        assign correct_data_o = inbetween_data_corrected[FORWARDED_CLOCK_CYCLES-1];
        assign correct_is_valid_o = inbetween_valid_corrected[FORWARDED_CLOCK_CYCLES-1];
        assign shift_adr_corrected_o = inbetween_shift_hash_adr_corrected[FORWARDED_CLOCK_CYCLES-1];
        assign shift_valid_corrected_o = inbetween_shift_valid_corrected[FORWARDED_CLOCK_CYCLES-1];
    //end
endgenerate

    
endmodule