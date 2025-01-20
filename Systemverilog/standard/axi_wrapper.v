module axi_wrapper #(parameter KEY_WIDTH = 4,
                     parameter DATA_WIDTH = 26,
                     parameter NUMBER_OF_TABLES = 3,
                     parameter BUCKET_SIZE = 2,
                     parameter CAM_SIZE = 8)
( 
    input clk,
    input reset,
    input [2+DATA_WIDTH+KEY_WIDTH-1:0] data_i,
    input ready_i,
    input valid_i,
    output ready_o,
    output valid_o,
    output [2+DATA_WIDTH+KEY_WIDTH-1:0] data_o );
    
wire [31:0] inbetween_data;


hash_table #( .KEY_WIDTH(KEY_WIDTH),
              .DATA_WIDTH(DATA_WIDTH),
              .NUMBER_OF_TABLES(NUMBER_OF_TABLES),
              .BUCKET_SIZE(BUCKET_SIZE),
              .CAM_SIZE(CAM_SIZE)) 
the_table ( 
    .clk(clk),
    .reset(reset),
    .key_in(data_i[DATA_WIDTH+KEY_WIDTH-1:DATA_WIDTH]),
    .data_in(data_i[DATA_WIDTH-1:0]),
    .delete_write_read_i(data_i[DATA_WIDTH+KEY_WIDTH+2-1:DATA_WIDTH+KEY_WIDTH]),
    .ready_i(ready_i),
    .valid_i(valid_i),
    .ready_o(ready_o),
    .valid_o(valid_o),
    .read_data_o(inbetween_data[DATA_WIDTH-1:0]),
    .no_deletion_target_o(inbetween_data[28]),
    .no_write_space_o(inbetween_data[29]),
    .no_element_found_o(inbetween_data[30]),
    .key_already_present_o(inbetween_data[31]));
    
assign inbetween_data[27:DATA_WIDTH] = 14'b11111111111111;
assign data_o = inbetween_data;
endmodule