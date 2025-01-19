module controller #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter BUCKET_SIZE = 1,
                    parameter integer HASH_TABLE_MAX_SIZE = 2,
                    parameter CAM_SIZE = 64
                    )(
    input   logic                                               clk,
    input   logic                                               clk_en,
    input   logic                                               reset,
    input   logic [KEY_WIDTH-1:0]                               key_i,
    input   logic [DATA_WIDTH-1:0]                              data_i,
    input   logic [HASH_TABLE_MAX_SIZE-1:0]                     hash_adr_i          [NUMBER_OF_TABLES-1:0],
    input   logic [1:0]                                         delete_write_read_i,      // 00 = do nothing | 01 = read | 10 = write | 11 = delete
    input   logic [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0]    read_out_content_i  [NUMBER_OF_TABLES-1:0],
    input   logic [BUCKET_SIZE-1:0]                             valid_flags_0_i     [NUMBER_OF_TABLES-1:0],

    input   logic [DATA_WIDTH-1:0]                              CAM_data_i,
    input   logic                                               CAM_valid_i,

    output  wire                                                write_en_o          [NUMBER_OF_TABLES-1:0],
    output  wire [BUCKET_SIZE-1:0]                              write_valid_flag_o  [NUMBER_OF_TABLES-1:0],
    output  wire [((KEY_WIDTH+DATA_WIDTH)*BUCKET_SIZE)-1:0]     write_content_o     [NUMBER_OF_TABLES-1:0],
    output  wire [HASH_TABLE_MAX_SIZE-1:0]                      hash_adr_o          [NUMBER_OF_TABLES-1:0],
    output  wire [DATA_WIDTH-1:0]                               read_data_o,
    output  wire                                                valid_o,

    output  wire [KEY_WIDTH-1:0]                                CAM_key_o,
    output  wire [DATA_WIDTH-1:0]                               CAM_data_o,
    output  wire                                                CAM_write_en_o,
    output  wire                                                CAM_delete_o,

    output  wire                                                no_deletion_target_o,
    output  wire                                                no_write_space_o,
    output  wire                                                no_element_found_o,
    output  wire                                                key_already_present_o
);
localparam logic [1:0] NOTHING_OPERATION = 2'b00;
localparam logic [1:0] READ_OPERATION    = 2'b01;
localparam logic [1:0] WRITE_OPERATION   = 2'b10;
localparam logic [1:0] DELTE_OPERATION   = 2'b11;

logic                                           used_space_in_CAM;
wire                                            write_CAM;
wire                                            delete_CAM;

wire [KEY_WIDTH-1:0]                            read_key;
wire [DATA_WIDTH-1:0]                           read_data;
wire [KEY_WIDTH+DATA_WIDTH-1:0]                 read_content;
wire [NUMBER_OF_TABLES-1:0][BUCKET_SIZE-1:0]    same_key;
wire [NUMBER_OF_TABLES-1:0]                     delete;
wire [NUMBER_OF_TABLES-1:0]                     write;
wire [NUMBER_OF_TABLES-1:0]                     write_og;
wire [BUCKET_SIZE-1:0]                          write_specific  [NUMBER_OF_TABLES-1:0];
wire [BUCKET_SIZE-1:0]                          delete_specific [NUMBER_OF_TABLES-1:0];
wire [NUMBER_OF_TABLES-1:0]                     unary_valid;
wire                                            unary_or_same_key;
wire                                            no_write;
wire                                            con_is_read;
wire                                            con_is_write;
wire                                            con_is_del;

wire [DATA_WIDTH-1:0]       possible_correct_read_data     [NUMBER_OF_TABLES:0];


genvar i,j;
generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        for (j = 0; j < BUCKET_SIZE ; j++ ) begin
            assign same_key[i][j] = (key_i == read_out_content_i[i][((DATA_WIDTH+KEY_WIDTH)*(j+1)-1):(DATA_WIDTH+KEY_WIDTH)*j+DATA_WIDTH] && valid_flags_0_i[i][j]) ? 1'b1 : 1'b0;
        end
    end
endgenerate
assign unary_or_same_key = (|same_key) | CAM_valid_i;

generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++) begin
        assign unary_valid[i] = &valid_flags_0_i[i];
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        if (i == 0) begin
            assign write_og[0] = (!unary_valid[i]) ? 1'b1 : 1'b0; 
        end else begin
            assign write_og[i] = ((!unary_valid[i]) && (~|write_og[i-1:0])) ? 1'b1 : 1'b0;
        end
        for (j = 0; j < BUCKET_SIZE ; j++ ) begin
            if (i == 0) begin
                assign write_specific[0][j] = (!valid_flags_0_i[0][j]) ? 1'b1 : 1'b0;
                assign delete_specific[0][j] = same_key[0][j];
            end else begin
                assign write_specific[i][j] = ((!valid_flags_0_i[i][j]) && (~|write_og[i-1:0])) ? 1'b1 : 1'b0;
                assign delete_specific[i][j] = same_key[i][j];
            end
        end       
        assign write[i] = (write_og[i]) & delete_write_read_i == WRITE_OPERATION && (~unary_or_same_key);
        assign delete[i] = (|delete_specific[i] && delete_write_read_i == DELTE_OPERATION) ? 1'b1 : 1'b0;
        assign write_en_o[i] = (write[i] || delete[i]) ? 1'b1 : 1'b0;
        assign write_valid_flag_o[i] = write_specific[i];
    end
endgenerate

// insert the correct data into the vectors that get send back to the memory to be saved
generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        for (j = 0; j < BUCKET_SIZE ; j++ ) begin
            assign write_content_o[i][((DATA_WIDTH+KEY_WIDTH)*(j+1)-1):(DATA_WIDTH+KEY_WIDTH)*j] = (write_specific[i][j]) ? {key_i, data_i} : read_out_content_i[i][((DATA_WIDTH+KEY_WIDTH)*(j+1)-1):(DATA_WIDTH+KEY_WIDTH)*j];
        end
        assign hash_adr_o[i]  = hash_adr_i[i];
    end
endgenerate


raw_mulitplexer_buckets #(
    .BUCKET_WITDH((KEY_WIDTH+DATA_WIDTH)),
    .BUCKET_SIZE(BUCKET_SIZE),
    .DATA_LINES(NUMBER_OF_TABLES)
) read_multiplexer_data(
    .data_in(read_out_content_i),
    .sel(same_key),                 //this code assumes that only one same_key signal can be 1 at each point in time
    .data_out(read_content)
);
assign read_data = (CAM_valid_i) ? CAM_data_i : read_content[DATA_WIDTH-1:0];   //decide whether use CAM data or memory data (assumption: cam_valid_i => no usefull data in memories)
//assign read_data_o = {unary_or_same_key, con_is_write, con_is_read, con_is_del, read_data[DATA_WIDTH-5:0]};
assign read_data_o = read_data[DATA_WIDTH-1:0];

always @(posedge clk) begin
    if (reset == 1) begin
        used_space_in_CAM <= 0;
    end else if (clk_en == 1) begin
        if (write_CAM == 1) begin
            used_space_in_CAM <= used_space_in_CAM + 1;
        end else if (delete_CAM == 1) begin
            used_space_in_CAM <= used_space_in_CAM - 1;
        end
    end
end

assign CAM_key_o = key_i;
assign CAM_data_o = data_i;
assign write_CAM = (~(|write_og)) & delete_write_read_i == WRITE_OPERATION & used_space_in_CAM != CAM_SIZE;
assign delete_CAM = (|unary_or_same_key) & (~(|delete)) & delete_write_read_i == DELTE_OPERATION;
assign CAM_write_en_o = write_CAM;
assign CAM_delete_o = delete_CAM;





assign no_deletion_target_o = (~unary_or_same_key) & con_is_del;
assign no_write_space_o = no_write & con_is_write;
assign no_element_found_o = (~unary_or_same_key) & con_is_read;
assign key_already_present_o = unary_or_same_key & con_is_write;
//assign read_success_o = (delete_write_read_i == READ_OPERATION && (~no_element_found_o)) ? 1'b1 : 1'b0;
//assign write_success_o = (delete_write_read_i == WRITE_OPERATION && (~key_already_present_o) || ~(no_write_space_o)) ? 1'b1 : 1'b0;
//assign delete_success_o = (delete_write_read_i == READ_OPERATION && (~no_deletion_target_o)) ? 1'b1 : 1'b0;

assign valid_o = (delete_write_read_i == NOTHING_OPERATION) ? 1'b0 : 1'b1;
assign con_is_write = (delete_write_read_i == WRITE_OPERATION) ? 1'b1 : 1'b0;
assign con_is_read = (delete_write_read_i == READ_OPERATION) ? 1'b1 : 1'b0;
assign con_is_del = (delete_write_read_i == DELTE_OPERATION) ? 1'b1 : 1'b0;
assign no_write = (~((|write) | write_CAM));



endmodule