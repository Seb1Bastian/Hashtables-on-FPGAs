module hash_table #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter [32*NUMBER_OF_TABLES-1:0] SIZES = 96'h000000020000000200000002,
                    parameter [KEY_WIDTH*NUMBER_OF_TABLES*2-1:0] MATRIX = 12'h0)(
    input   logic clk,
    input   logic reset,
    input   logic [KEY_WIDTH-1:0] key_in,
    input   logic [DATA_WIDTH-1:0] data_in,
    input   logic [1:0] delete_write_read_i,
    input   logic ready_i,
    input   logic valid_i,
    output  wire ready_o,
    output  wire valid_o,
    output  wire [DATA_WIDTH-1:0] read_data_o,
    output  wire no_deletion_target_o,
    output  wire no_write_space_o,
    output  wire no_element_found_o,
    output  wire key_already_present_o
);
localparam integer HASH_TABLE_SIZE[NUMBER_OF_TABLES-1:0] = '{SIZES[95:64],SIZES[63:32],SIZES[31:0]};
localparam [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0] = '{'{2'b00,2'b01},'{2'b10,2'b00},'{2'b00,2'b00}};
localparam HASH_TABLE_MAX_SIZE = HASH_TABLE_SIZE[0];

wire [KEY_WIDTH-1:0]    key_in_delayed;
wire [DATA_WIDTH-1:0]   data_in_delayed;
wire [1:0]              delete_write_read_i_valid;
wire [1:0]              delete_write_read_i_delayed;

wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adrs_out                           [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adrs_out_delayed                   [NUMBER_OF_TABLES-1:0];
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]       hash_adrs_out_packed;
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]       hash_adrs_out_packed_delayed;
wire [KEY_WIDTH+DATA_WIDTH-1:0]                         data_out_of_block_ram                   [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH+DATA_WIDTH-1:0]                         data_out_of_block_ram_delayed           [NUMBER_OF_TABLES-1:0];
wire [((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES)-1:0]    data_out_of_block_ram_packed;
wire [((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES)-1:0]    data_out_of_block_ram_packed_delayed;
wire [KEY_WIDTH-1:0]                                    key_delayed                             [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                                   data_delayed                            [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adr_1                              [NUMBER_OF_TABLES-2:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adr_1_delayed                      [NUMBER_OF_TABLES-2:0];
wire [(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-1))-1:0]   hash_adr_1_packed;
wire [(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-1))-1:0]   hash_adr_1_packed_delayed;
wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adr_2                              [NUMBER_OF_TABLES-2:1];
wire [HASH_TABLE_MAX_SIZE-1:0]                          hash_adr_2_delayed                      [NUMBER_OF_TABLES-2:1];
wire [(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-2))-1:0]   hash_adr_2_packed;
wire [(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-2))-1:0]   hash_adr_2_packed_delayed;
wire                                                    flags_0                                 [NUMBER_OF_TABLES-1:0];
wire                                                    flags_0_delayed                         [NUMBER_OF_TABLES-1:0];
wire [NUMBER_OF_TABLES-1:0]                             flags_0_packed;
wire [NUMBER_OF_TABLES-1:0]                             flags_0_packed_delayed;
wire                                                    flags_1                                 [NUMBER_OF_TABLES-1:1];
wire                                                    flags_2                                 [NUMBER_OF_TABLES-1:2];

wire                            write_en            [NUMBER_OF_TABLES-1:0];
wire                            write_valid_flag    [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH-1:0]            write_keys          [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]           write_data          [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]  hash_adr_write      [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]           read_data;

wire [HASH_TABLE_MAX_SIZE-1:0]  forward_shift_hash_adr  [NUMBER_OF_TABLES-2:0];
wire                            forward_shift_valid     [NUMBER_OF_TABLES-2:0];
wire                            write_shift             [NUMBER_OF_TABLES-2:0];

wire [KEY_WIDTH-1:0]            correct_key         [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]           correct_data        [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH+DATA_WIDTH-1:0] correct_key_data    [NUMBER_OF_TABLES-1:0];
wire                            correct_is_valid    [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]  correct_shift_adr   [NUMBER_OF_TABLES-2:0];
wire                            correct_shift_valid [NUMBER_OF_TABLES-2:0];


genvar i;
generate
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1) begin
        h3_hash_function 
            #(.KEY_WIDTH(KEY_WIDTH),
              .HASH_ADR_WIDTH(HASH_TABLE_SIZE[i]),
              .Q_MATRIX(Q_MATRIX[i][HASH_TABLE_MAX_SIZE-1:0])
        )
        hash_0(
            .key_in(key_in),
            .hash_adr_out(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0])
        );
    end
endgenerate


generate
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1) begin
        simple_dual_one_clock 
            #(.MEM_SIZE(HASH_TABLE_SIZE[i]),
              .DATA_WIDTH(KEY_WIDTH+DATA_WIDTH)
        )
        block_ram(
            .clk(clk),
            .ena(1'b1),     //needs to be changed
            .enb(1'b1),     //needs to be changed
            .wea((write_en[i] && ready_i)),
            .addra(hash_adr_write[i][HASH_TABLE_SIZE[i]-1:0]),
            .addrb(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0]),
            .dia({write_keys[i], write_data[i]}),
            .dob(data_out_of_block_ram[i])
        );
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES; i = i + 1) begin
        if (i == 0) begin
            flag_register 
                #(.SIZE(HASH_TABLE_SIZE[i])
            )
            flags_reg_0(
                .clk(clk),
                .reset(reset),
                .read_adr_0(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0]),
                .read_adr_1({HASH_TABLE_SIZE[i]{1'b0}}),
                .read_adr_2({HASH_TABLE_SIZE[i]{1'b0}}),
                .write_adr(hash_adr_write[i]),
                .write_en((write_en[i] && ready_i)),
                .write_is_valid(write_valid_flag[i]),
                .flag_out_0(flags_0[i]),
                .flag_out_1(),
                .flag_out_2()
            );
        end else if (i == 1) begin
            flag_register 
                #(.SIZE(HASH_TABLE_SIZE[i])
            )
            flags_reg_1(
                .clk(clk),
                .reset(reset),
                .read_adr_0(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0]),   //from i-1 to i
                .read_adr_1(hash_adr_1[i-1][HASH_TABLE_SIZE[i]-1:0]),   // from i to i+1
                .read_adr_2({HASH_TABLE_SIZE[i]{1'b0}}),
                .write_adr(hash_adr_write[i]),
                .write_en((write_en[i] && ready_i)),
                .write_is_valid(write_valid_flag[i]),
                .flag_out_0(flags_0[i]),
                .flag_out_1(flags_1[i]),
                .flag_out_2()
            );
        end else if ( i > 1) begin
            flag_register 
                #(.SIZE(HASH_TABLE_SIZE[i])
            )
            flags_reg__(
                .clk(clk),
                .reset(reset),
                .read_adr_0(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0]),    //into i-te mem
                .read_adr_1(hash_adr_1[i-1][HASH_TABLE_SIZE[i]-1:0]),     //from i to i+1 mem
                .read_adr_2(hash_adr_2[i-1][HASH_TABLE_SIZE[i]-1:0]),     //from i to i+1 mem
                .write_adr(hash_adr_write[i]),
                .write_en((write_en[i] && ready_i)),
                .write_is_valid(write_valid_flag[i]),
                .flag_out_0(flags_0[i]),
                .flag_out_1(flags_1[i]),
                .flag_out_2(flags_2[i])
            );
        end
    end
endgenerate


generate
    for (i = 0; i < NUMBER_OF_TABLES-1; i = i + 1) begin
        h3_hash_function 
            #(.KEY_WIDTH(KEY_WIDTH),
              .HASH_ADR_WIDTH(HASH_TABLE_SIZE[i]),
              .Q_MATRIX(Q_MATRIX[i][HASH_TABLE_MAX_SIZE-1:0])
        )
        hash_1(
            .key_in(data_out_of_block_ram[i][KEY_WIDTH+DATA_WIDTH-1:DATA_WIDTH]),
            .hash_adr_out(hash_adr_1[i])
        );
    end
endgenerate

generate
    for (i = 1; i < NUMBER_OF_TABLES-1; i = i + 1) begin
        h3_hash_function 
            #(.KEY_WIDTH(KEY_WIDTH),
              .HASH_ADR_WIDTH(HASH_TABLE_SIZE[i]),
              .Q_MATRIX(Q_MATRIX[i][HASH_TABLE_MAX_SIZE-1:0])
        )
        hash_2(
            .key_in(data_out_of_block_ram[i-1][KEY_WIDTH+DATA_WIDTH-1:DATA_WIDTH]),
            .hash_adr_out(hash_adr_2[i])
        );
    end
endgenerate

generate
    assign forward_shift_hash_adr[0] = hash_adr_1[1];
    assign forward_shift_valid[0] = flags_1[1];
    for (i = 1; i < NUMBER_OF_TABLES-1 ; i = i+1 ) begin
        assign forward_shift_hash_adr[i] = (write_shift[i-1] == 1'b1) ? hash_adr_2[i] : hash_adr_1[i]; // if shifted from i to i+1 the shift values for i+2 must be updated
        assign forward_shift_valid[i] = (write_shift[i-1] == 1'b1) ? flags_2[i] : flags_1[i];
    end
endgenerate
generate
    for (i = 0; i < NUMBER_OF_TABLES ; i = i+1 ) begin
        assign key_delayed[i] = data_out_of_block_ram_delayed[i][KEY_WIDTH+DATA_WIDTH-1:DATA_WIDTH];
        assign data_delayed[i] = data_out_of_block_ram_delayed[i][DATA_WIDTH-1:0];
    end
endgenerate
whole_forward_updater #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEY_WIDTH(KEY_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .FORWARDED_CLOCK_CYCLES(2),
    .MAX_HASH_ADR_WIDTH(HASH_TABLE_MAX_SIZE),
    .HASH_TABLE_ADR_WIDTH(HASH_TABLE_SIZE)
) forward_updater (
    .clk(clk),
    .reset(reset),
    .clk_en(1'b1),                                              //no clk_en ?????
    .new_hash_adr_i(hash_adrs_out_delayed),
    .new_data_i(data_delayed),
    .new_key_i(key_delayed),
    .new_valid_i(flags_0_delayed),
    .new_shift_adr_i(hash_adr_1_delayed),
    .new_shift_valid_i(flags_1),

    .forward_hash_adr_i(hash_adr_write),
    .forward_data_i(write_data),
    .forward_key_i(write_keys),
    .forward_updated_mem_i(write_en),
    .forward_valid_i(write_valid_flag),
    .forward_shift_hash_adr_i(forward_shift_hash_adr),
    .forward_shift_valid_i(forward_shift_valid),
//    input .[SHIFT_HASH_ADR_WIDTH-1:0] forward_next_mem_hash_adr_i [NUMBER_OF_TABLES-2:0],
//    input .forward_next_mem_updated_i [NUMBER_OF_TABLES-2:0],
//    input .forward_next_mem_valid_i [NUMBER_OF_TABLES-2:0],

    .correct_key_o(correct_key),
    .correct_data_o(correct_data),
    .correct_is_valid_o(correct_is_valid),
    .shift_adr_corrected_o(correct_shift_adr),
    .shift_valid_corrected_o(correct_shift_valid)
);


generate
    for (i = 0; i < NUMBER_OF_TABLES ; i = i+1 ) begin
        assign correct_key_data[i] = {correct_key[i], correct_data[i]};
    end
endgenerate
controller #(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .HASH_TABLE_MAX_SIZE(HASH_TABLE_MAX_SIZE)
) big_ass_controller (
    .clk(clk),
    .data_i(data_in_delayed),
    .key_i(key_in_delayed),
    .hash_adr_i(hash_adrs_out_delayed), //
    .delete_write_read_i(delete_write_read_i_delayed),
    .read_out_keys_i(correct_key),
    .read_out_data_i(correct_data),
    .read_out_hash_adr_i(correct_shift_adr),
    .valid_flags_0_i(correct_is_valid),
    .valid_flags_1_i(correct_shift_valid),
    .write_en_o(write_en),
    .write_shift_o(write_shift),
    .write_valid_flag_o(write_valid_flag),
    .keys_o(write_keys),
    .data_o(write_data),
    .hash_adr_o(hash_adr_write),
    .read_data_o(read_data_o),
    .valid_o(valid_o),
    .no_deletion_target_o(no_deletion_target_o),
    .no_write_space_o(no_write_space_o),
    .no_element_found_o(no_element_found_o),
    .key_already_present_o(key_already_present_o)
);



//delaying signals to the right time

siso_register #(
    .DATA_WIDTH(DATA_WIDTH),
    .DELAY(2))
data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(data_in),
    .data_o(data_in_delayed));

siso_register #(
    .DATA_WIDTH(KEY_WIDTH),
    .DELAY(2))
key_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(key_in),
    .data_o(key_in_delayed));

siso_register #(
    .DATA_WIDTH(2),
    .DELAY(2))
op_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(delete_write_read_i_valid),
    .data_o(delete_write_read_i_delayed));

siso_register #(
    .DATA_WIDTH((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES),
    .DELAY(1))
stored_data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(data_out_of_block_ram_packed),
    .data_o(data_out_of_block_ram_packed_delayed));

assign data_out_of_block_ram_packed = { << { data_out_of_block_ram}};
assign data_out_of_block_ram_delayed = { << {data_out_of_block_ram_packed_delayed}};


siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES),
    .DELAY(2))                                                  // war vorher 1
hash_adr_delay_0(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(hash_adrs_out_packed),
    .data_o(hash_adrs_out_packed_delayed));
assign hash_adrs_out_packed = { << { hash_adrs_out}};
assign hash_adrs_out_delayed = { << { hash_adrs_out_packed_delayed}};

siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-1)),
    .DELAY(1))
hash_adr_delay_1(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(hash_adr_1_packed),
    .data_o(hash_adr_1_packed_delayed));
assign hash_adr_1_packed = { << { hash_adr_1}};
assign hash_adr_1_delayed = { << { hash_adr_1_packed_delayed}};

siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*(NUMBER_OF_TABLES-2)),
    .DELAY(1))
hash_adr_delay_2(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(hash_adr_2_packed),
    .data_o(hash_adr_2_packed_delayed));
assign hash_adr_2_packed = { << { hash_adr_2}};
assign hash_adr_2_delayed = { << { hash_adr_2_packed_delayed}};


siso_register #(
    .DATA_WIDTH(NUMBER_OF_TABLES),
    .DELAY(1))
flag_delay(
    .clk(clk),
    .reset(reset),
    .write_en(ready_i),
    .data_i(flags_0_packed),
    .data_o(flags_0_packed_delayed));

assign flags_0_packed = { << {flags_0}};
assign flags_0_delayed = { << { flags_0_packed_delayed}};
assign ready_o = ready_i;


assign delete_write_read_i_valid = valid_i === 1'b1 ? delete_write_read_i : 2'b00; //nothing operation


endmodule