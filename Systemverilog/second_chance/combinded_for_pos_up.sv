module whole_forward_updater #(
    parameter DATA_WIDTH = 4,
    parameter KEY_WIDTH = 2,
    parameter NUMBER_OF_TABLES = 4,
    parameter FORWARDED_CLOCK_CYCLES = 2,
    parameter MAX_HASH_ADR_WIDTH = 2,
    parameter BUCKET_SIZE = 1,
    parameter integer HASH_TABLE_ADR_WIDTH[NUMBER_OF_TABLES-1:0] = {2,2,2,2}
)(
    input logic clk,
    input logic reset,
    input logic clk_en,
    input logic [MAX_HASH_ADR_WIDTH-1:0]                    new_hash_adr_i      [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]           new_data_i          [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]            new_key_i           [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0]                           new_valid_i         [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]   new_shift_adr_i     [NUMBER_OF_TABLES-2:0],
    input logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          new_shift_valid_i   [NUMBER_OF_TABLES-2:0],                           //von i nach i+1

    input logic [MAX_HASH_ADR_WIDTH-1:0]                    forward_hash_adr_i          [NUMBER_OF_TABLES-1:0],
    input logic [DATA_WIDTH-1:0]                            forward_data_i              [NUMBER_OF_TABLES-1:0],
    input logic [KEY_WIDTH-1:0]                             forward_key_i               [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0]                           forward_updated_mem_i       [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0]                           forward_valid_i             [NUMBER_OF_TABLES-1:0],
    input logic [BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]   forward_shift_hash_adr_i    [NUMBER_OF_TABLES-2:0],
    input logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          forward_shift_valid_i       [NUMBER_OF_TABLES-2:0],
    input logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          forward_shift_shift_valid_i [NUMBER_OF_TABLES-1:2],
    input logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          forward_write_shift_i       [NUMBER_OF_TABLES-2:0],

    output wire [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]            correct_key_o           [NUMBER_OF_TABLES-1:0],
    output wire [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]           correct_data_o          [NUMBER_OF_TABLES-1:0],
    output wire [BUCKET_SIZE-1:0]                           correct_is_valid_o      [NUMBER_OF_TABLES-1:0],
    output wire [BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]   shift_adr_corrected_o   [NUMBER_OF_TABLES-2:0],
    output wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          shift_valid_corrected_o [NUMBER_OF_TABLES-2:0]
);

wire [MAX_HASH_ADR_WIDTH-1:0]                   forward_hash_adr                [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                           forward_data                    [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH-1:0]                            forward_key                     [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                          forward_updated_mem             [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                          forward_valid                   [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]  forward_shift_hash_adr          [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]         forward_shift_valid             [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]         forward_not_shift_shift_valid   [NUMBER_OF_TABLES-2:0];


logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0] delayed_forward_write_shift [NUMBER_OF_TABLES-2:0];


wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]                           inbetween_valid_corrected           [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0]; //Last dimension is not important only [0] value is being used
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0][KEY_WIDTH-1:0]            inbetween_key_corrected             [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0]; //Last dimension is not important only [0] value is being used
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0][DATA_WIDTH-1:0]           inbetween_data_corrected            [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-1:0]; //Last dimension is not important only [0] value is being used
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0][MAX_HASH_ADR_WIDTH-1:0]   inbetween_shift_hash_adr_corrected  [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0]; //Last dimension is not important only [0] value is being used
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]          inbetween_shift_valid_corrected     [FORWARDED_CLOCK_CYCLES-1:0][NUMBER_OF_TABLES-2:0];

genvar i,j,k,l;
generate
    for (j = 0; j < NUMBER_OF_TABLES-1 ; j = j+1 ) begin
        siso_register #(
            .DATA_WIDTH(BUCKET_SIZE*BUCKET_SIZE), .DELAY(1))
        forward_hash_adr_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_write_shift_i[j]),
            .data_o(delayed_forward_write_shift[j]));
    end
endgenerate

generate
    for (j = 0; j < NUMBER_OF_TABLES ; j = j+1 ) begin
        siso_register #(
            .DATA_WIDTH(MAX_HASH_ADR_WIDTH), .DELAY(1))
        forward_hash_adr_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_hash_adr_i[j]),
            .data_o(forward_hash_adr[FORWARDED_CLOCK_CYCLES-1][j]));

        siso_register #(
            .DATA_WIDTH(DATA_WIDTH), .DELAY(1))
        forward_data_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_data_i[j]),
            .data_o(forward_data[FORWARDED_CLOCK_CYCLES-1][j]));

        siso_register #(
            .DATA_WIDTH(KEY_WIDTH), .DELAY(1))
        forward_key_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_key_i[j]),
            .data_o(forward_key[FORWARDED_CLOCK_CYCLES-1][j]));

        siso_register #(
            .DATA_WIDTH(BUCKET_SIZE), .DELAY(1))
        forward_updated_mem_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_updated_mem_i[j]),
            .data_o(forward_updated_mem[FORWARDED_CLOCK_CYCLES-1][j]));

        siso_register #(
            .DATA_WIDTH(BUCKET_SIZE), .DELAY(1))
        forward_valid_reg(
            .clk(clk), .reset(reset), .write_en(clk_en),
            .data_i(forward_valid_i[j]),
            .data_o(forward_valid[FORWARDED_CLOCK_CYCLES-1][j]));
        
        if (j <= NUMBER_OF_TABLES-2) begin
            siso_register #(
                .DATA_WIDTH(MAX_HASH_ADR_WIDTH*BUCKET_SIZE), .DELAY(1))
            forward_shift_hash_adr_reg(
                .clk(clk), .reset(reset), .write_en(clk_en),
                .data_i(forward_shift_hash_adr_i[j]),
                .data_o(forward_shift_hash_adr[FORWARDED_CLOCK_CYCLES-1][j]));

            siso_register #(
                .DATA_WIDTH(BUCKET_SIZE*BUCKET_SIZE), .DELAY(1))
            forward_shift_valid_reg(
                .clk(clk), .reset(reset), .write_en(clk_en),
                .data_i(forward_shift_valid_i[j]),
                .data_o(forward_not_shift_shift_valid[j]));
        end
    end
endgenerate

generate
    assign forward_shift_valid[FORWARDED_CLOCK_CYCLES-1][0] = forward_not_shift_shift_valid[0];
    for (i = 1; i < NUMBER_OF_TABLES-1 ; i = i+1 ) begin
        for (k = 0; k < BUCKET_SIZE ; k = k + 1 ) begin
            for (l = 0; l < BUCKET_SIZE ; l = l + 1) begin // different indexes used one shift from i to i+1 and one other from i-1 to i
                assign forward_shift_valid[FORWARDED_CLOCK_CYCLES-1][i][k][l] = (delayed_forward_write_shift[i-1][k][l] == 1'b1) ? forward_shift_shift_valid_i[i+1][k][l] : forward_not_shift_shift_valid[i][k][l];
            end
        end
    end
endgenerate

generate
    for (i = FORWARDED_CLOCK_CYCLES-1; i > 0; i = i-1) begin
        for (j = 0; j < NUMBER_OF_TABLES; j = j+1) begin
            siso_register #(
                .DATA_WIDTH(MAX_HASH_ADR_WIDTH), .DELAY(1))
            forward_hash_adr_reg_l(
                .clk(clk), .reset(reset), .write_en(clk_en),
                .data_i(forward_hash_adr[i][j]),
                .data_o(forward_hash_adr[i-1][j]));

            siso_register #(
                .DATA_WIDTH(DATA_WIDTH), .DELAY(1))
            forward_data_reg_l(
                .clk(clk), .reset(reset), .write_en(clk_en),
                .data_i(forward_data[i][j]),
                .data_o(forward_data[i-1][j]));

            siso_register #(
                .DATA_WIDTH(KEY_WIDTH), .DELAY(1))
            forward_key_reg_l(
                .clk(clk), .reset(reset), .write_en(clk_en),
                .data_i(forward_key[i][j]),
                .data_o(forward_key[i-1][j]));

            siso_register #(
                .DATA_WIDTH(BUCKET_SIZE), .DELAY(1))
            forward_updated_mem_reg_l(
                .clk(clk), .reset(reset), .write_en(clk_en),
                .data_i(forward_updated_mem[i][j]),
                .data_o(forward_updated_mem[i-1][j]));

            siso_register #(
                .DATA_WIDTH(BUCKET_SIZE), .DELAY(1))
            forward_valid_reg_l(
                .clk(clk), .reset(reset), .write_en(clk_en),
                .data_i(forward_valid[i][j]),
                .data_o(forward_valid[i-1][j]));

            if (j <= NUMBER_OF_TABLES-2) begin
                siso_register #(
                    .DATA_WIDTH(MAX_HASH_ADR_WIDTH*BUCKET_SIZE), .DELAY(1))
                forward_shift_hash_adr_reg_l(
                    .clk(clk), .reset(reset), .write_en(clk_en),
                    .data_i(forward_shift_hash_adr[i][j]),
                    .data_o(forward_shift_hash_adr[i-1][j]));

                siso_register #(
                    .DATA_WIDTH(BUCKET_SIZE*BUCKET_SIZE), .DELAY(1))
                forward_shift_valid_reg_l(
                    .clk(clk), .reset(reset), .write_en(clk_en),
                    .data_i(forward_shift_valid[i][j]),
                    .data_o(forward_shift_valid[i-1][j]));
            end
            
        end
    end
endgenerate

generate
    for (i = 0; i < FORWARDED_CLOCK_CYCLES; i++ ) begin
        if (i == 0) begin
            for (j = 0; j < NUMBER_OF_TABLES; j++ ) begin
                for (k = 0; k < BUCKET_SIZE; k++) begin
                    for (l = 0; l < BUCKET_SIZE; l++ ) begin
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
                                .new_data_i(new_data_i[j][k]),
                                .new_key_i(new_key_i[j][k]),
                                .new_shift_adr_i(new_shift_adr_i[j][k]),
                                .new_valid_i(new_valid_i[j][k]),
                                .new_shift_valid_i(new_shift_valid_i[j][k][l]),
                                .forward_hash_adr_i(forward_hash_adr[i][j][HASH_TABLE_ADR_WIDTH[j]-1:0]),
                                .forward_data_i(forward_data[i][j]),
                                .forward_key_i(forward_key[i][j]),
                                .forward_updated_mem_i(forward_updated_mem[i][j][k]),
                                .forward_valid_i(forward_valid[i][j][k]),
                                .forward_shift_hash_adr_i(forward_shift_hash_adr[i][j][k]),
                                .forward_shift_valid_i(forward_shift_valid[i][j][k][l]),
                                .forward_next_mem_hash_adr_i(forward_hash_adr[i][j+1][HASH_TABLE_ADR_WIDTH[j+1]-1:0]),
                                .forward_next_mem_updated_i(forward_updated_mem[i][j+1][k]),
                                .forward_next_mem_valid_i(forward_valid[i][j+1][k]),
                                .correct_key(inbetween_key_corrected[i][j][k][l]),
                                .correct_data(inbetween_data_corrected[i][j][k][l]),
                                .correct_is_valid(inbetween_valid_corrected[i][j][k][l]),
                                .correct_shift_hash_adr(inbetween_shift_hash_adr_corrected[i][j][k][l]),
                                .correct_shift_valid(inbetween_shift_valid_corrected[i][j][k][l])
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
                                .new_data_i(new_data_i[j][k]),
                                .new_key_i(new_key_i[j][k]),
                                .new_shift_adr_i(1'b0),
                                .new_valid_i(new_valid_i[j][k]),
                                .new_shift_valid_i(1'b0),
                                .forward_hash_adr_i(forward_hash_adr[i][j][HASH_TABLE_ADR_WIDTH[j]-1:0]),
                                .forward_data_i(forward_data[i][j]),
                                .forward_key_i(forward_key[i][j]),
                                .forward_updated_mem_i(forward_updated_mem[i][j][k]),
                                .forward_valid_i(forward_valid[i][j][k]),
                                .forward_shift_hash_adr_i(1'b0), //
                                .forward_shift_valid_i(1'b0),       //
                                .forward_next_mem_hash_adr_i(1'b0), //
                                .forward_next_mem_updated_i(1'b0),   //
                                .forward_next_mem_valid_i(1'b0),       //
                                .correct_key(inbetween_key_corrected[i][j][k][l]),
                                .correct_data(inbetween_data_corrected[i][j][k][l]),
                                .correct_is_valid(inbetween_valid_corrected[i][j][k][l]),
                                .correct_shift_hash_adr(),
                                .correct_shift_valid()
                            );
                        end
                    end
                end
            end
        end else begin
            for (j = 0; j < NUMBER_OF_TABLES; j++) begin
                for (k = 0; k < BUCKET_SIZE; k++) begin
                    for (l = 0; l < BUCKET_SIZE; l++ ) begin
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
                                .new_data_i(inbetween_data_corrected[i-1][j][k][0]),
                                .new_key_i(inbetween_key_corrected[i-1][j][k][0]),
                                .new_shift_adr_i(inbetween_shift_hash_adr_corrected[i-1][j][k][0]),
                                .new_valid_i(inbetween_valid_corrected[i-1][j][k][0]),
                                .new_shift_valid_i(inbetween_shift_valid_corrected[i-1][j][k][l]), //
                                .forward_hash_adr_i(forward_hash_adr[i][j][HASH_TABLE_ADR_WIDTH[j]-1:0]),
                                .forward_data_i(forward_data[i][j]),
                                .forward_key_i(forward_key[i][j]),
                                .forward_updated_mem_i(forward_updated_mem[i][j][k]),
                                .forward_valid_i(forward_valid[i][j][k]),
                                .forward_shift_hash_adr_i(forward_shift_hash_adr[i][j][k]), //
                                .forward_shift_valid_i(forward_shift_valid[i][j][k][l]),       //
                                .forward_next_mem_hash_adr_i(forward_hash_adr[i][j+1][HASH_TABLE_ADR_WIDTH[j+1]-1:0]), //
                                .forward_next_mem_updated_i(forward_updated_mem[i][j+1][k]),   //
                                .forward_next_mem_valid_i(forward_valid[i][j+1][k]),       //
                                .correct_key(inbetween_key_corrected[i][j][k][l]),
                                .correct_data(inbetween_data_corrected[i][j][k][l]),
                                .correct_is_valid(inbetween_valid_corrected[i][j][k][l]),
                                .correct_shift_hash_adr(inbetween_shift_hash_adr_corrected[i][j][k][l]),
                                .correct_shift_valid(inbetween_shift_valid_corrected[i][j][k][l])
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
                                .new_data_i(inbetween_data_corrected[i-1][j][k][0]),
                                .new_key_i(inbetween_key_corrected[i-1][j][k][0]),
                                .new_shift_adr_i(1'b0), //
                                .new_valid_i(inbetween_valid_corrected[i-1][j][k][0]), 
                                .new_shift_valid_i(1'b0), //
                                .forward_hash_adr_i(forward_hash_adr[i][j][HASH_TABLE_ADR_WIDTH[j]-1:0]),
                                .forward_data_i(forward_data[i][j]),
                                .forward_key_i(forward_key[i][j]),
                                .forward_updated_mem_i(forward_updated_mem[i][j][k]),
                                .forward_valid_i(forward_valid[i][j][k]),
                                .forward_shift_hash_adr_i(1'b0), //
                                .forward_shift_valid_i(1'b0),       //
                                .forward_next_mem_hash_adr_i(1'b0), //
                                .forward_next_mem_updated_i(1'b0),   //
                                .forward_next_mem_valid_i(1'b0),    //
                                .correct_key(inbetween_key_corrected[i][j][k][l]),
                                .correct_data(inbetween_data_corrected[i][j][k][l]),
                                .correct_is_valid(inbetween_valid_corrected[i][j][k][l]),
                                .correct_shift_hash_adr(),
                                .correct_shift_valid()
                            );
                        end
                    end
                end
            end
        end
    end
endgenerate


generate
    for (j = 0; j < BUCKET_SIZE; j++) begin
        for (i = 0; i < NUMBER_OF_TABLES; i++) begin
            if(i == NUMBER_OF_TABLES-1) begin
                assign correct_key_o[NUMBER_OF_TABLES-1][j]      = inbetween_key_corrected   [FORWARDED_CLOCK_CYCLES-1][NUMBER_OF_TABLES-1][j][0];
                assign correct_data_o[NUMBER_OF_TABLES-1][j]     = inbetween_data_corrected  [FORWARDED_CLOCK_CYCLES-1][NUMBER_OF_TABLES-1][j][0];
                assign correct_is_valid_o[NUMBER_OF_TABLES-1][j] = inbetween_valid_corrected [FORWARDED_CLOCK_CYCLES-1][NUMBER_OF_TABLES-1][j][0];
            end else begin
                assign correct_key_o[i][j]            = inbetween_key_corrected               [FORWARDED_CLOCK_CYCLES-1][i][j][0];
                assign correct_data_o[i][j]           = inbetween_data_corrected              [FORWARDED_CLOCK_CYCLES-1][i][j][0];
                assign correct_is_valid_o[i][j]       = inbetween_valid_corrected             [FORWARDED_CLOCK_CYCLES-1][i][j][0];
                assign shift_adr_corrected_o[i][j]    = inbetween_shift_hash_adr_corrected    [FORWARDED_CLOCK_CYCLES-1][i][j][0]; 
            end
        end
    end
endgenerate
assign shift_valid_corrected_o  = inbetween_shift_valid_corrected       [FORWARDED_CLOCK_CYCLES-1];


    
endmodule