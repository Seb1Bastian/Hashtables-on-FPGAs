module controller #(parameter KEY_WIDTH = 2,
                    parameter DATA_WIDTH = 32,
                    parameter NUMBER_OF_TABLES = 3,
                    parameter integer HASH_TABLE_MAX_SIZE = 2,
                    parameter CAM_SIZE = 64
                    )(
    input   logic                           clk,
    input   logic                           clk_en,
    input   logic                           reset,
    input   logic [KEY_WIDTH-1:0]           key_i,
    input   logic [DATA_WIDTH-1:0]          data_i,
    input   logic [HASH_TABLE_MAX_SIZE-1:0] hash_adr_i          [NUMBER_OF_TABLES-1:0],
    input   logic [1:0]                     delete_write_read_i,      // 00 = do nothing | 01 = read | 10 = write | 11 = delete
    input   logic [KEY_WIDTH-1:0]           read_out_keys_i     [NUMBER_OF_TABLES-1:0],
    input   logic [DATA_WIDTH-1:0]          read_out_data_i     [NUMBER_OF_TABLES-1:0],
    input   logic [HASH_TABLE_MAX_SIZE-1:0] read_out_hash_adr_i [NUMBER_OF_TABLES-2:0], // von i nach i+1
    input   logic                           valid_flags_0_i     [NUMBER_OF_TABLES-1:0],
    input   logic                           valid_flags_1_i     [NUMBER_OF_TABLES-1:1],

    input   logic [DATA_WIDTH-1:0]          CAM_data_i,
    input   logic                           CAM_valid_i,

    output  wire                            write_en_o          [NUMBER_OF_TABLES-1:0],
    output  wire                            write_shift_o       [NUMBER_OF_TABLES-2:0],
    output  wire                            write_valid_flag_o  [NUMBER_OF_TABLES-1:0],
    output  wire [KEY_WIDTH-1:0]            keys_o              [NUMBER_OF_TABLES-1:0],
    output  wire [DATA_WIDTH-1:0]           data_o              [NUMBER_OF_TABLES-1:0],
    output  wire [HASH_TABLE_MAX_SIZE-1:0]  hash_adr_o          [NUMBER_OF_TABLES-1:0],
    output  wire [DATA_WIDTH-1:0]           read_data_o,
    output  wire                            valid_o,

    output  wire [KEY_WIDTH-1:0]            CAM_key_o,
    output  wire [DATA_WIDTH-1:0]           CAM_data_o,
    output  wire                            CAM_write_en_o,
    output  wire                            CAM_delete_o,

    output  wire                            no_deletion_target_o,
    output  wire                            no_write_space_o,
    output  wire                            no_element_found_o,
    output  wire                            key_already_present_o
);
localparam logic [1:0] NOTHING_OPERATION = 2'b00;
localparam logic [1:0] READ_OPERATION    = 2'b01;
localparam logic [1:0] WRITE_OPERATION   = 2'b10;
localparam logic [1:0] DELTE_OPERATION   = 2'b11;

logic                       used_space_in_CAM;
wire                        write_CAM;
wire                        delete_CAM;

wire [KEY_WIDTH-1:0]        read_key;
wire [DATA_WIDTH-1:0]       read_data;
wire [NUMBER_OF_TABLES-1:0] same_key;
wire [NUMBER_OF_TABLES-1:0] delete;
wire [NUMBER_OF_TABLES-1:0] write;
wire [NUMBER_OF_TABLES-1:0] write_og;
wire [NUMBER_OF_TABLES-1:0] write_shift;
wire                        unary_or_same_key;
wire                        no_write;
wire                        con_is_read;
wire                        con_is_write;
wire                        con_is_del;

wire [DATA_WIDTH-1:0]       possible_correct_read_data     [NUMBER_OF_TABLES:0];


genvar i;
generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        assign same_key[i] = (key_i == read_out_keys_i[i][KEY_WIDTH-1:0] && valid_flags_0_i[i]) ? 1'b1 : 1'b0;
    end
endgenerate
assign unary_or_same_key = (|same_key) | CAM_valid_i;

generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        if (i == 0) begin
            assign write_og[0] = (!valid_flags_0_i[i] || ((!valid_flags_1_i[i+1]) && valid_flags_0_i[i+1])) ? 1'b1 : 1'b0;
        end else if (i < NUMBER_OF_TABLES-1) begin
            assign write_og[i] = ((!valid_flags_0_i[i] || ((!valid_flags_1_i[i+1]) && valid_flags_0_i[i+1])) && (~|write_og[i-1:0])) ? 1'b1 : 1'b0;
        end else begin
            assign write_og[i] = ((!valid_flags_0_i[i]) && (~|write_og[i-1:0])) ? 1'b1 : 1'b0;
        end        
        if (i == 0) begin
            assign write_shift[0] = 1'b0;
        end else begin
            assign write_shift[i] = ((valid_flags_0_i[i-1] & write_og[i-1]));
        end
        assign write[i] = (write_og[i] | write_shift[i]) & delete_write_read_i == WRITE_OPERATION && (~unary_or_same_key);
        assign delete[i] = (same_key[i] && delete_write_read_i == DELTE_OPERATION) ? 1'b1 : 1'b0;
        assign write_en_o[i] = (write[i] || delete[i]) ? 1'b1 : 1'b0;
        assign write_valid_flag_o[i] = write[i];
    end
endgenerate

generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        if (i == 0) begin
            assign keys_o[i] = key_i;
            assign data_o[i] = data_i;
            assign hash_adr_o[i]  = hash_adr_i[i];
        end else begin
            assign keys_o[i] = (write_shift[i] == 1'b1) ? read_out_keys_i[i-1] : key_i;
            assign data_o[i] = (write_shift[i] == 1'b1) ? read_out_data_i[i-1] : data_i;
            assign hash_adr_o[i]  = (write_shift[i] == 1'b1) ? read_out_hash_adr_i[i-1] : hash_adr_i[i];
        end
    end
endgenerate

raw_mulitplexer #(
    .DATA_WIDTH(KEY_WIDTH),
    .DATA_LINES(NUMBER_OF_TABLES)
) read_multiplexer_key(
    .data_in(read_out_keys_i),
    .sel(same_key),                 //this code assumes that only one same_key signal can be 1 at each point in time
    .data_out(read_key)
);
/*generate
    for (i = 0; i < NUMBER_OF_TABLES ; i++ ) begin
        assign possible_correct_read_data[i] = 
endgenerate*/

raw_mulitplexer #(
    .DATA_WIDTH(DATA_WIDTH),
    .DATA_LINES(NUMBER_OF_TABLES+1)
) read_multiplexer_data(
    .data_in({CAM_data_i, read_out_data_i}),
    .sel({CAM_valid_i, same_key}),                 //this code assumes that only one same_key signal can be 1 at each point in time
    .data_out(read_data)
);

assign read_data_o = {unary_or_same_key, con_is_write, con_is_read, con_is_del, read_data[DATA_WIDTH-5:0]};
//assign read_data_o = read_key_data[DATA_WIDTH-1:0];
/*assign no_deletion_target_o = ((!unary_or_same_key) && (delete_write_read_i == DELTE_OPERATION)) ? 1'b1 : 1'b0;
assign no_write_space_o = ((~|write) && (delete_write_read_i == WRITE_OPERATION)) ? 1'b1 : 1'b0;
assign no_element_found_o = ((!unary_or_same_key) && (delete_write_read_i == READ_OPERATION)) ? 1'b1 : 1'b0;
assign key_already_present_o = ((unary_or_same_key) && (delete_write_read_i == WRITE_OPERATION)) ? 1'b1 : 1'b0;
*/

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
assign no_write = (~(|write));
assign write_shift_o = { << { write_shift[NUMBER_OF_TABLES-1:1]}};



endmodule