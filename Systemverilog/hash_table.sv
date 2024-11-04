module hash_table #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter integer HASH_TABLE_SIZE [NUMBER_OF_TABLES-1:0]   = '{2,2,2},
                    parameter logic [KEY_WIDTH-1:0] Q_MATRIX[NUMBER_OF_TABLES-1:0][HASH_TABLE_SIZE[0]-1:0]  = '{'{2'b01, 2'b01},'{2'b01, 2'b01},'{2'b01, 2'b01}})(
    input   logic clk,
    input   logic reset,
    input   logic [KEY_WIDTH-1:0] key_in,
    input   logic [DATA_WIDTH-1:0] data_in,
    input   logic [1:0] delete_write_read_i,
    output  wire [DATA_WIDTH-1:0] read_data_o,
    output  wire no_deletion_target_o,
    output  wire no_write_space_o,
    output  wire no_element_found_o
);
localparam HASH_TABLE_MAX_SIZE = HASH_TABLE_SIZE[0];

wire [KEY_WIDTH-1:0] key_in_delayed;
wire [DATA_WIDTH-1:0] data_in_delayed;
wire [1:0]delete_write_read_i_delayed;

wire [HASH_TABLE_MAX_SIZE-1:0]  hash_adrs_out [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]  hash_adrs_out_delayed [NUMBER_OF_TABLES-1:0];
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]  hash_adrs_out_packed;
wire [(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES)-1:0]  hash_adrs_out_packed_delayed;
wire [KEY_WIDTH+DATA_WIDTH-1:0]                 data_out_of_block_ram [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH+DATA_WIDTH-1:0]                 data_out_of_block_ram_delayed [NUMBER_OF_TABLES-1:0];
wire [((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES)-1:0]                 data_out_of_block_ram_packed;
wire [((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES)-1:0]                 data_out_of_block_ram_packed_delayed;
wire [KEY_WIDTH-1:0]                            hash_adr_1 [NUMBER_OF_TABLES-1:1];
wire                                            flags_0 [NUMBER_OF_TABLES-1:0];
wire                                            flags_0_delayed [NUMBER_OF_TABLES-1:0];
wire [NUMBER_OF_TABLES-1:0]                     flags_0_packed;
wire [NUMBER_OF_TABLES-1:0]                     flags_0_packed_delayed;
wire                                            flags_1 [NUMBER_OF_TABLES-1:1];

wire write_en [NUMBER_OF_TABLES-1:0];
wire write_valid_flag [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH+DATA_WIDTH-1:0] keys_data [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0] hash_adr [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0] read_data;


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
            .wea(write_en[i]),
            .addra(hash_adr[i][HASH_TABLE_SIZE[i]-1:0]),
            .addrb(hash_adrs_out[i][HASH_TABLE_SIZE[i]-1:0]),
            .dia(keys_data[i]),
            .dob(data_out_of_block_ram[i])
        );
    end
endgenerate

generate
    flag_register 
            #(.SIZE(HASH_TABLE_SIZE[i])
        )
        flags_reg_0(
            .clk(clk),
            .reset(reset),
            .read_adr_0(data_out_of_block_ram[i][KEY_WIDTH+DATA_WIDTH-1:DATA_WIDTH]),
            //hashtable 0 is the first table. No elements swaped into this table so it does not need to check whether it can swap
            .read_adr_1(2'd0),
            .write_adr(hash_adr[0]),
            .write_en(write_en[0]),
            .write_is_valid(write_valid_flag[0]),
            .flag_out_0(flags_0[0])
        );
    for (i = 1; i < NUMBER_OF_TABLES; i = i + 1) begin
        flag_register 
            #(.SIZE(HASH_TABLE_SIZE[i])
        )
        flags_reg(
            .clk(clk),
            .reset(reset),
            .read_adr_0(data_out_of_block_ram[i][KEY_WIDTH+DATA_WIDTH-1:DATA_WIDTH]),
            .read_adr_1(hash_adr_1[i]),
            .write_adr(hash_adr[i]),
            .write_en(write_en[i]),
            .write_is_valid(write_valid_flag[i]),
            .flag_out_0(flags_0[i]),
            .flag_out_1(flags_1[i])
        );
    end
endgenerate


generate
    for (i = 1; i < NUMBER_OF_TABLES; i = i + 1) begin
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
    .read_out_keys_data_i(data_out_of_block_ram_delayed),
    .read_out_hash_adr_i(hash_adr_1),
    .valid_flags_0_i(flags_0_delayed),
    .valid_flags_1_i(flags_1),
    .write_en_o(write_en),
    .write_valid_flag_o(write_valid_flag),
    .keys_data_o(keys_data),
    .hash_adr_o(hash_adr),
    .read_data_o(read_data_o),
    .no_deletion_target_o(no_deletion_target_o),
    .no_write_space_o(no_write_space_o),
    .no_element_found_o(no_element_found_o)
);



//delaying signals to the right time

siso_register #(
    .DATA_WIDTH(DATA_WIDTH),
    .DELAY(2))
data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(1'b1),
    .data_i(data_in),
    .data_o(data_in_delayed));

siso_register #(
    .DATA_WIDTH(KEY_WIDTH),
    .DELAY(2))
key_delay(
    .clk(clk),
    .reset(reset),
    .write_en(1'b1),
    .data_i(key_in),
    .data_o(key_in_delayed));

siso_register #(
    .DATA_WIDTH(2),
    .DELAY(2))
op_delay(
    .clk(clk),
    .reset(reset),
    .write_en(1'b1),
    .data_i(delete_write_read_i),
    .data_o(delete_write_read_i_delayed));

siso_register #(
    .DATA_WIDTH((KEY_WIDTH+DATA_WIDTH)*NUMBER_OF_TABLES),
    .DELAY(1))
stored_data_delay(
    .clk(clk),
    .reset(reset),
    .write_en(1'b1),
    .data_i(data_out_of_block_ram_packed),
    .data_o(data_out_of_block_ram_packed_delayed));

assign data_out_of_block_ram_packed = { << { data_out_of_block_ram}};
assign data_out_of_block_ram_delayed = { << {data_out_of_block_ram_packed_delayed}};


siso_register #(
    .DATA_WIDTH(HASH_TABLE_MAX_SIZE*NUMBER_OF_TABLES),
    .DELAY(1))
hash_adr_delay(
    .clk(clk),
    .reset(reset),
    .write_en(1'b1),
    .data_i(hash_adrs_out_packed),
    .data_o(hash_adrs_out_packed_delayed));

assign hash_adrs_out_packed = { << { hash_adrs_out}};
assign hash_adrs_out_delayed = { << { hash_adrs_out_packed_delayed}};


siso_register #(
    .DATA_WIDTH(NUMBER_OF_TABLES),
    .DELAY(1))
flag_delay(
    .clk(clk),
    .reset(reset),
    .write_en(1'b1),
    .data_i(flags_0_packed),
    .data_o(flags_0_packed_delayed));

assign flags_0_packed = { << {flags_0}};
assign flags_0_delayed = { << { flags_0_packed_delayed}};


endmodule