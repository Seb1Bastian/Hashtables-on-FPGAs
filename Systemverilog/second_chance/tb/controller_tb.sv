module controller_tb;

localparam KEY_WIDTH = 4;
localparam DATA_WIDTH = 8;
localparam NUMBER_OF_TABLES = 3;
localparam BUCKET_SIZE = 2;
localparam integer HASH_TABLE_MAX_SIZE = 4;



logic                                               clk;
logic                                               clk_en;
logic                                               reset;
logic [KEY_WIDTH-1:0]                               key_i;
logic [DATA_WIDTH-1:0]                              data_i;
logic [HASH_TABLE_MAX_SIZE-1:0]                     hash_adr_i          [NUMBER_OF_TABLES-1:0];
logic [1:0]                                         delete_write_read_i;
logic [BUCKET_SIZE-1:0][KEY_WIDTH-1:0]              read_out_keys_i     [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0][DATA_WIDTH-1:0]             read_out_data_i     [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0][HASH_TABLE_MAX_SIZE-1:0]    read_out_hash_adr_i [NUMBER_OF_TABLES-2:0];
logic [BUCKET_SIZE-1:0]                             valid_flags_0_i     [NUMBER_OF_TABLES-1:0];
logic [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]            valid_flags_1_i     [NUMBER_OF_TABLES-1:1];
logic [DATA_WIDTH-1:0]                              CAM_data_i;
logic                                               CAM_valid_i;


wire [BUCKET_SIZE-1:0]                              write_en_o          [NUMBER_OF_TABLES-1:0];
wire                                                write_shift_o       [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0][BUCKET_SIZE-1:0]             write_shift_b_o     [NUMBER_OF_TABLES-2:0];
wire [BUCKET_SIZE-1:0]                              write_og_b_o        [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                              write_valid_flag_o  [NUMBER_OF_TABLES-1:0];
wire [KEY_WIDTH-1:0]                                keys_o              [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                               data_o              [NUMBER_OF_TABLES-1:0];
wire [HASH_TABLE_MAX_SIZE-1:0]                      hash_adr_o          [NUMBER_OF_TABLES-1:0];
wire [DATA_WIDTH-1:0]                               read_data_o;
wire                                                valid_o;
wire [KEY_WIDTH-1:0]                                CAM_key_o;
wire [DATA_WIDTH-1:0]                               CAM_data_o;
wire                                                CAM_write_en_o;
wire                                                CAM_delete_o;
wire                                                no_deletion_target_o;
wire                                                no_write_space_o;
wire                                                no_element_found_o;
wire                                                key_already_present_o;



controller #(
    .KEY_WIDTH(KEY_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .BUCKET_SIZE(BUCKET_SIZE),
    .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
    .HASH_TABLE_MAX_SIZE(HASH_TABLE_MAX_SIZE)
) uut (
    .clk(clk),
    .clk_en(clk_en),
    .reset(reset),
    .key_i(key_i),
    .data_i(data_i),
    .hash_adr_i(hash_adr_i),
    .delete_write_read_i(delete_write_read_i),      // 00 = do nothing | 01 = read | 10 = write | 11 = delete
    .read_out_keys_i(read_out_keys_i),
    .read_out_data_i(read_out_data_i),
    .read_out_hash_adr_i(read_out_hash_adr_i),
    .valid_flags_0_i(valid_flags_0_i),
    .valid_flags_1_i(valid_flags_1_i),

    .CAM_data_i(CAM_data_i),
    .CAM_valid_i(CAM_valid_i),

    .write_en_o(write_en_o),
    .write_shift_o(write_shift_o),
    .write_shift_b_o(write_shift_b_o),
    .write_og_b_o(write_og_b_o),
    .write_valid_flag_o(write_valid_flag_o),
    .keys_o(keys_o),
    .data_o(data_o),
    .hash_adr_o(hash_adr_o),
    .read_data_o(read_data_o),
    .valid_o(valid_o),

    .CAM_key_o(CAM_key_o),
    .CAM_data_o(CAM_data_o),
    .CAM_write_en_o(CAM_write_en_o),
    .CAM_delete_o(CAM_delete_o),

    .no_deletion_target_o(no_deletion_target_o),
    .no_write_space_o(no_write_space_o),
    .no_element_found_o(no_element_found_o),
    .key_already_present_o(key_already_present_o)
);

initial begin
    
    clk = 1'b0;
    forever begin
        #5;
        clk = ~clk;
    end
end


initial begin
    clk_en = 1'b1;
    reset = 1'b1;
    #10ns;
    reset = 1'b0;

    CAM_data_i = 4'h0;
    CAM_valid_i = 1'b0;

    key_i = 4'hA;
    data_i = 8'hBB;
    hash_adr_i = '{4'h3, 4'h2, 4'h1};
    delete_write_read_i = 2'b10;
    read_out_keys_i = '{{4'h6,4'h5},{4'h4,4'h3},{4'h2,4'h1}};
    read_out_data_i = '{{8'h6,8'h5},{8'h4,8'h3},{8'h2,8'h1}};
    read_out_hash_adr_i = '{{4'h7,4'h6},{4'h5,4'h4}};
    valid_flags_0_i = '{2'b00,2'b00,2'b00};
    valid_flags_1_i = '{4'b0000,4'b0000};
    #10ns;
    valid_flags_0_i = '{2'b00,2'b00,2'b01};
    #10ns;
    valid_flags_0_i = '{2'b00,2'b00,2'b11};
    #10ns;
    valid_flags_0_i = '{2'b00,2'b11,2'b11};
    valid_flags_1_i = '{4'b0000,4'b1011};
    #10ns;

    #10ns;
    $finish;
end


endmodule