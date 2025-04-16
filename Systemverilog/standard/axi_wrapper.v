module axi_wrapper #(parameter KEY_WIDTH = 5,
                     parameter DATA_WIDTH = 25,
                     parameter KEEP_WIDTH = ($ceil(KEY_WIDTH+DATA_WIDTH+2)/8),
                     parameter NUMBER_OF_TABLES = 8,
                     parameter HASH_TABLE_MAX_SIZE = 5,
                     //parameter [32*NUMBER_OF_TABLES-1:0] HASH_TABLE_SIZE = {257'h00000005000000050000000500000005},
                     parameter BUCKET_SIZE = 2,
                     parameter CAM_SIZE = 8)
( 
    input clk,
    input reset,
    input [(NUMBER_OF_TABLES*HASH_TABLE_MAX_SIZE*KEY_WIDTH)-1:0] matrixes_i,
    input [2+DATA_WIDTH+KEY_WIDTH-1:0] data_i,
    input ready_i,
    input valid_i,
    input last_i,
    input [KEEP_WIDTH-1:0] keep_i,
    output ready_o,
    output valid_o,
    output last_o,
    output [KEEP_WIDTH-1:0] keep_o,
    output [2+DATA_WIDTH+KEY_WIDTH-1:0] data_o );

localparam [(32 * NUMBER_OF_TABLES) - 1 : 0] SIZES = {NUMBER_OF_TABLES{HASH_TABLE_MAX_SIZE}}; //because vivado sucks (only 256 bit parameter allowed)
wire [KEY_WIDTH+DATA_WIDTH+1:0] inbetween_data;


hash_table #( .KEY_WIDTH(KEY_WIDTH),
              .DATA_WIDTH(DATA_WIDTH),
              .KEEP_WIDTH(KEEP_WIDTH),
              .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
              .HASH_TABLE_MAX_SIZE(HASH_TABLE_MAX_SIZE),
              .HASH_TABLE_SIZES(SIZES),
              .BUCKET_SIZE(BUCKET_SIZE),
              .CAM_SIZE(CAM_SIZE)) 
the_table ( 
    .clk(clk),
    .reset(reset),
    .matrixes_i(matrixes_i),
    .key_in(data_i[DATA_WIDTH+KEY_WIDTH-1:DATA_WIDTH]),
    .data_in(data_i[DATA_WIDTH-1:0]),
    .delete_write_read_i(data_i[DATA_WIDTH+KEY_WIDTH+2-1:DATA_WIDTH+KEY_WIDTH]),
    .ready_i(ready_i),
    .valid_i(valid_i),
    .last_i(last_i),
    .keep_i(keep_i),
    .ready_o(ready_o),
    .valid_o(valid_o),
    .last_o(last_o),
    .keep_o(keep_o),
    .read_data_o(inbetween_data[DATA_WIDTH-1:0]),
    .no_deletion_target_o(inbetween_data[KEY_WIDTH+DATA_WIDTH-2]),
    .no_write_space_o(inbetween_data[KEY_WIDTH+DATA_WIDTH-1]),
    .no_element_found_o(inbetween_data[KEY_WIDTH+DATA_WIDTH]),
    .key_already_present_o(inbetween_data[KEY_WIDTH+DATA_WIDTH+1]));
    
assign inbetween_data[DATA_WIDTH+KEY_WIDTH-3: DATA_WIDTH] = {(KEY_WIDTH-2){1'b0}};
assign data_o = inbetween_data;
endmodule