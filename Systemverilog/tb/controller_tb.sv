module controller_tb;

localparam KEY_WIDTH = 4;
localparam DATA_WIDTH = 8;
localparam NUMBER_OF_TABLES = 3;
localparam integer HASH_TABLE_MAX_SIZE = 4;
logic clk;
logic [KEY_WIDTH-1:0] key_i;
logic [DATA_WIDTH-1:0] data_i;
logic [HASH_TABLE_MAX_SIZE-1:0] hash_adr_i [NUMBER_OF_TABLES-1:0];
logic [1:0] delete_write_read_i;      // 00 = do nothing | 01 = read | 10 = write | 11 = delete
logic [KEY_WIDTH+DATA_WIDTH-1:0] read_out_keys_data_i [NUMBER_OF_TABLES-1:0];
logic [HASH_TABLE_MAX_SIZE-1:1] read_out_hash_adr_i [NUMBER_OF_TABLES-1:0];
logic valid_flags_0_i [NUMBER_OF_TABLES-1:0];
logic valid_flags_1_i [NUMBER_OF_TABLES-1:1];

wire write_en_o [NUMBER_OF_TABLES-1:0];
wire write_valid_flag_o [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH+DATA_WIDTH-1:0] keys_data_o [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0] hash_adr_o [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0] read_data_o;
wire no_deletion_target_o;
wire no_write_space_o;
wire no_element_found_o;



controller #(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .HASH_TABLE_MAX_SIZE(HASH_TABLE_MAX_SIZE)
) uut (
    .clk(clk),
    .key_i(key_i),
    .data_i(data_i),
    .hash_adr_i(hash_adr_i),
    .delete_write_read_i(delete_write_read_i),      // 00 = do nothing | 01 = read | 10 = write | 11 = delete
    .read_out_keys_data_i(read_out_keys_data_i),
    .read_out_hash_adr_i(read_out_hash_adr_i),
    .valid_flags_0_i(valid_flags_0_i),
    .valid_flags_1_i(valid_flags_1_i),
    .write_en_o(write_en_o),
    .write_valid_flag_o(write_valid_flag_o),
    .keys_data_o(keys_data_o),
    .hash_adr_o(hash_adr_o),
    .read_data_o(read_data_o),
    .no_deletion_target_o(no_deletion_target_o),
    .no_write_space_o(no_write_space_o),
    .no_element_found_o(no_element_found_o)
);

initial begin
    clk = 1'b0;
    forever begin
        #5;
        clk = ~clk;
    end
end


initial begin
    key_i = 4'hA;
    data_i = 8'hBB;
    delete_write_read_i = 2'b10;
    read_out_keys_data_i = '{0,0,0};
    hash_adr_i = '{4'hA, 4'hB, 4'hC};
    valid_flags_0_i = '{0,0,0};
    valid_flags_1_i = '{0,0};

    #10;

    delete_write_read_i = 2'b01;
    read_out_keys_data_i = '{0,12'hAAA,0};
    valid_flags_0_i = '{0,1,0};

    #10;

    key_i = 4'hF;
    data_i = 8'hFF;
    hash_adr_i = '{4'h3, 4'h7, 4'hF};
    delete_write_read_i = 2'b10;
    read_out_keys_data_i = '{12'h444,12'h888,12'hBBB};
    read_out_hash_adr_i = '{4'h4,4'h8,4'hB};
    valid_flags_0_i = '{0,1,1};
    valid_flags_1_i = '{0,0};

    #10;

    valid_flags_1_i = '{0,1};

    #10;

    key_i = 4'hF;
    data_i = 8'hFF;
    hash_adr_i = '{4'hF, 4'h7, 4'h3};
    delete_write_read_i = 2'b11;
    read_out_keys_data_i = '{12'hFFF,12'h888,12'hBBB};
    read_out_hash_adr_i = '{3'h0,3'h8,3'h6};
    valid_flags_0_i = '{1,0,0};
    valid_flags_1_i = '{0,1};

    #10;

    valid_flags_0_i = '{0,1,0};

    #10;


    $finish;
end


endmodule